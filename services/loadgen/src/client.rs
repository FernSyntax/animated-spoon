//! Load-generator configuration and command planning.
//!
//! Kept separate from the run loop so scenarios can be unit tested.
use clap::Parser;
use kd_proto::command_payload::Action;
use kd_proto::*;
use rand::rngs::StdRng;
use rand::Rng;
use serde_json::{json, Value};

#[derive(Parser, Debug)]
pub struct Args {
    #[arg(long, default_value = "http://localhost:8080")]
    pub(crate) gateway: String,
    #[arg(long, default_value = "realm-a")]
    pub(crate) realm: String,
    #[arg(long, default_value_t = 20)]
    pub(crate) clients: usize,
    #[arg(long, default_value_t = 60)]
    pub(crate) duration: u64,
    #[arg(long, default_value_t = 2)]
    pub(crate) actions_per_sec: u64,
    #[arg(long, default_value = "mixed")]
    pub(crate) scenario: String,
    #[arg(long, default_value_t = 1337)]
    pub(crate) seed: u64,
    #[arg(long)]
    pub(crate) prefix: Option<String>,
}

#[derive(Default)]
pub struct Stats {
    pub(crate) accepted: u64,
    pub(crate) rejected: u64,
    pub(crate) errors: u64,
    pub(crate) latencies: Vec<f64>,
    pub(crate) reconnects: u64,
    pub(crate) samples: Vec<String>,
    pub(crate) reject_codes: std::collections::BTreeMap<String, u64>,
}

pub async fn setup_account(
    http: &reqwest::Client,
    base: &str,
    realm: &str,
    username: &str,
) -> anyhow::Result<String> {
    let _ = http
        .post(format!("{base}/auth/register"))
        .json(&json!({"username":username,"password":"loadtest-password","display_name":username}))
        .send()
        .await?;
    let login: Value = http
        .post(format!("{base}/auth/login"))
        .json(&json!({"username":username,"password":"loadtest-password"}))
        .send()
        .await?
        .json()
        .await?;
    let token = login
        .get("token")
        .and_then(|v| v.as_str())
        .ok_or_else(|| anyhow::anyhow!("no token: {login}"))?
        .to_string();
    let _ = http
        .post(format!("{base}/realms/{realm}/join"))
        .bearer_auth(&token)
        .send()
        .await?;
    let _ = http
        .post(format!("{base}/bootstrap"))
        .json(&json!({"token":token,"realm_id":realm,"chunks":[[0,0],[1,0],[0,1],[1,1]]}))
        .send()
        .await?
        .json::<Value>()
        .await?;
    Ok(token)
}

pub fn next_command(
    rng: &mut StdRng,
    i: usize,
    scenario: &str,
    seq: u64,
    realm: &str,
    city: Option<&str>,
    seed: u64,
) -> (SubmitCommandRequest, &'static str) {
    let id = format!("{}-{}-{:08x}", scenario, i, seq);
    let cid = city.unwrap_or("").to_string();
    let pos_x = rng.gen_range(0..64);
    let pos_y = rng.gen_range(0..64);
    let (action, label) = if city.is_none() && seq < 5 {
        (
            Action::CreateCity(CreateCityCmd {
                name: format!("Settle-{i}"),
                pos: Some(Vec2 {
                    x: (200 + (seed % 50) * 20 + ((i as u64) % 10) * 3) as i32,
                    y: (200 + (seed % 50) * 20 + (((i / 10) as u64) % 10) * 3) as i32,
                }),
            }),
            "create_city",
        )
    } else if scenario == "idle" {
        (
            Action::Chat(ChatCmd {
                scope: "world".into(),
                text: format!("idle {seq}"),
                target_id: String::new(),
            }),
            "chat",
        )
    } else {
        match rng.gen_range(0..10) {
            0..=2 => (
                Action::UpgradeBuilding(UpgradeBuildingCmd {
                    city_id: cid,
                    building: ["farm", "lumber_mill", "quarry"][rng.gen_range(0..3)].into(),
                }),
                "upgrade",
            ),
            3 => (
                Action::StartResearch(StartResearchCmd {
                    tech: ["agriculture", "forestry", "pathfinding"][rng.gen_range(0..3)].into(),
                }),
                "research",
            ),
            4..=5 => (
                Action::TrainTroops(TrainTroopsCmd {
                    city_id: cid,
                    unit: ["infantry", "ranged", "scout"][rng.gen_range(0..3)].into(),
                    tier: 1,
                    count: 1,
                }),
                "train",
            ),
            6 => (
                Action::ScoutTile(ScoutTileCmd {
                    pos: Some(Vec2 { x: pos_x, y: pos_y }),
                }),
                "scout",
            ),
            7 => (
                Action::Chat(ChatCmd {
                    scope: "world".into(),
                    text: format!("loadgen {seq}"),
                    target_id: String::new(),
                }),
                "chat",
            ),
            8 => (
                Action::Gather(GatherCmd {
                    city_id: cid,
                    node_id: format!("node:{}:{}", pos_x, pos_y),
                }),
                "gather",
            ),
            _ => (
                Action::AttackMonster(AttackMonsterCmd {
                    city_id: cid,
                    monster_id: format!("monster:{}:{}", pos_x, pos_y),
                }),
                "monster",
            ),
        }
    };
    (
        SubmitCommandRequest {
            realm_id: realm.into(),
            principal_player_id: String::new(),
            command_id: id,
            payload: Some(CommandPayload {
                action: Some(action),
            }),
        },
        label,
    )
}

pub fn find_city_id(v: &Value) -> Option<String> {
    if let Some(cities) = v.get("cities").and_then(|x| x.as_array()) {
        if let Some(id) = cities
            .first()
            .and_then(|c| c.get("id"))
            .and_then(|x| x.as_str())
        {
            return Some(id.to_string());
        }
    }
    for value in v.as_object().map(|o| o.values()).into_iter().flatten() {
        if let Some(found) = find_city_id(value) {
            return Some(found);
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;
    use rand::SeedableRng;

    #[test]
    fn first_commands_settle_a_city_when_none_is_owned() {
        let mut rng = StdRng::seed_from_u64(42);
        let (cmd, label) = next_command(&mut rng, 0, "mixed", 0, "realm-a", None, 7);
        assert_eq!(label, "create_city");
        assert!(matches!(
            cmd.payload.unwrap().action,
            Some(Action::CreateCity(_))
        ));
    }

    #[test]
    fn idle_scenario_never_mutates_gameplay() {
        let mut rng = StdRng::seed_from_u64(1);
        for seq in 0..10 {
            let (_, label) = next_command(
                &mut rng,
                seq,
                "idle",
                seq as u64,
                "realm-a",
                Some("city-1"),
                7,
            );
            assert_eq!(label, "chat");
        }
    }

    #[test]
    fn city_id_is_found_in_nested_state() {
        let state: Value =
            serde_json::from_str(r#"{"state":{"cities":[{"id":"city-9","name":"A"}]}}"#).unwrap();
        assert_eq!(find_city_id(&state).as_deref(), Some("city-9"));
        assert_eq!(find_city_id(&serde_json::json!({})), None);
    }
}
