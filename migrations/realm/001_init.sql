-- Per-realm gameplay database. Every table is realm-scoped; a shard may host
-- several realms, so realm_id participates in keys and hot indexes.

CREATE TABLE IF NOT EXISTS realm_clock (
    realm_id TEXT PRIMARY KEY,
    offset_micros BIGINT NOT NULL DEFAULT 0,
    scale_permille BIGINT NOT NULL DEFAULT 1000
);

CREATE TABLE IF NOT EXISTS realm_state (
    realm_id TEXT PRIMARY KEY,
    version BIGINT NOT NULL DEFAULT 0,
    seed BIGINT NOT NULL,
    season_ends_at_ms BIGINT NOT NULL,
    content_version INT NOT NULL
);

CREATE TABLE IF NOT EXISTS realm_ownership (
    realm_id TEXT PRIMARY KEY,
    epoch BIGINT NOT NULL,
    owner_id TEXT NOT NULL,
    lease_until_ms BIGINT NOT NULL,
    updated_at_ms BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS players (
    realm_id TEXT NOT NULL,
    player_id UUID NOT NULL,
    account_id UUID NOT NULL,
    name TEXT NOT NULL,
    alliance_id TEXT,
    alliance_role TEXT,
    capital_city_id TEXT,
    created_at_ms BIGINT NOT NULL,
    PRIMARY KEY (realm_id, player_id),
    UNIQUE (realm_id, account_id)
);

CREATE TABLE IF NOT EXISTS cities (
    realm_id TEXT NOT NULL,
    city_id TEXT NOT NULL,
    player_id UUID NOT NULL,
    name TEXT NOT NULL,
    x INT NOT NULL,
    y INT NOT NULL,
    is_capital BOOLEAN NOT NULL DEFAULT false,
    town_hall_level INT NOT NULL DEFAULT 1,
    shield_until_ms BIGINT NOT NULL DEFAULT 0,
    food BIGINT NOT NULL DEFAULT 2000 CHECK (food >= 0),
    wood BIGINT NOT NULL DEFAULT 2000 CHECK (wood >= 0),
    stone BIGINT NOT NULL DEFAULT 1000 CHECK (stone >= 0),
    iron BIGINT NOT NULL DEFAULT 500 CHECK (iron >= 0),
    gold BIGINT NOT NULL DEFAULT 1000 CHECK (gold >= 0),
    rem_food BIGINT NOT NULL DEFAULT 0 CHECK (rem_food >= 0 AND rem_food < 1000000),
    rem_wood BIGINT NOT NULL DEFAULT 0 CHECK (rem_wood >= 0 AND rem_wood < 1000000),
    rem_stone BIGINT NOT NULL DEFAULT 0 CHECK (rem_stone >= 0 AND rem_stone < 1000000),
    rem_iron BIGINT NOT NULL DEFAULT 0 CHECK (rem_iron >= 0 AND rem_iron < 1000000),
    rem_gold BIGINT NOT NULL DEFAULT 0 CHECK (rem_gold >= 0 AND rem_gold < 1000000),
    busy_until_ms BIGINT NOT NULL DEFAULT 0,
    busy_command_id TEXT,
    busy_action TEXT NOT NULL DEFAULT '',
    last_accrued_ms BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (realm_id, city_id),
    UNIQUE (realm_id, x, y)
);
CREATE INDEX IF NOT EXISTS cities_player_idx ON cities(realm_id, player_id);
CREATE INDEX IF NOT EXISTS cities_pos_idx ON cities(realm_id, x, y);

CREATE TABLE IF NOT EXISTS buildings (
    realm_id TEXT NOT NULL,
    city_id TEXT NOT NULL,
    kind TEXT NOT NULL,
    level INT NOT NULL CHECK (level >= 0),
    PRIMARY KEY (realm_id, city_id, kind),
    FOREIGN KEY (realm_id, city_id) REFERENCES cities(realm_id, city_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS research (
    realm_id TEXT NOT NULL,
    player_id UUID NOT NULL,
    tech TEXT NOT NULL,
    level INT NOT NULL CHECK (level BETWEEN 0 AND 3),
    PRIMARY KEY (realm_id, player_id, tech)
);

CREATE TABLE IF NOT EXISTS troops (
    realm_id TEXT NOT NULL,
    city_id TEXT NOT NULL,
    unit TEXT NOT NULL,
    tier INT NOT NULL CHECK (tier BETWEEN 1 AND 3),
    count BIGINT NOT NULL DEFAULT 0 CHECK (count >= 0),
    wounded BIGINT NOT NULL DEFAULT 0 CHECK (wounded >= 0),
    PRIMARY KEY (realm_id, city_id, unit, tier),
    FOREIGN KEY (realm_id, city_id) REFERENCES cities(realm_id, city_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS items (
    realm_id TEXT NOT NULL,
    player_id UUID NOT NULL,
    item_key TEXT NOT NULL,
    qty BIGINT NOT NULL CHECK (qty >= 0),
    PRIMARY KEY (realm_id, player_id, item_key)
);

CREATE TABLE IF NOT EXISTS heroes (
    realm_id TEXT NOT NULL,
    player_id UUID NOT NULL,
    hero_key TEXT NOT NULL,
    level INT NOT NULL DEFAULT 1,
    xp BIGINT NOT NULL DEFAULT 0,
    assignment TEXT NOT NULL DEFAULT '',
    PRIMARY KEY (realm_id, player_id, hero_key)
);

CREATE TABLE IF NOT EXISTS entity_state (
    realm_id TEXT NOT NULL,
    id TEXT NOT NULL,
    kind TEXT NOT NULL,
    x INT NOT NULL,
    y INT NOT NULL,
    level INT NOT NULL,
    subtype TEXT NOT NULL,
    stock BIGINT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    hp BIGINT NOT NULL DEFAULT 0 CHECK (hp >= 0),
    owner_player_id UUID,
    respawn_at_ms BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (realm_id, id)
);
CREATE INDEX IF NOT EXISTS entity_pos_idx ON entity_state(realm_id, x, y);

CREATE TABLE IF NOT EXISTS marches (
    realm_id TEXT NOT NULL,
    id TEXT NOT NULL,
    player_id UUID NOT NULL,
    from_city_id TEXT NOT NULL,
    from_x INT NOT NULL,
    from_y INT NOT NULL,
    to_x INT NOT NULL,
    to_y INT NOT NULL,
    target_id TEXT NOT NULL DEFAULT '',
    mission TEXT NOT NULL,
    state TEXT NOT NULL,
    troops JSONB NOT NULL,
    hero TEXT NOT NULL DEFAULT '',
    resources JSONB NOT NULL DEFAULT '{}'::jsonb,
    depart_at_ms BIGINT NOT NULL,
    arrive_at_ms BIGINT NOT NULL,
    return_at_ms BIGINT NOT NULL DEFAULT 0,
    version BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (realm_id, id)
);
CREATE INDEX IF NOT EXISTS marches_player_idx ON marches(realm_id, player_id);
CREATE INDEX IF NOT EXISTS marches_arrival_idx ON marches(realm_id, state, arrive_at_ms);

CREATE TABLE IF NOT EXISTS scheduled_events (
    id UUID PRIMARY KEY,
    realm_id TEXT NOT NULL,
    due_at_ms BIGINT NOT NULL,
    priority INT NOT NULL DEFAULT 100,
    kind TEXT NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'pending',
    locked_by TEXT,
    attempts INT NOT NULL DEFAULT 0,
    created_at_ms BIGINT NOT NULL,
    processed_at_ms BIGINT NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS events_due_idx ON scheduled_events(realm_id, status, due_at_ms, priority, id);

CREATE TABLE IF NOT EXISTS commands (
    realm_id TEXT NOT NULL,
    principal_id UUID NOT NULL,
    command_id TEXT NOT NULL,
    payload_hash TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    result_json JSONB,
    created_at_ms BIGINT NOT NULL,
    updated_at_ms BIGINT NOT NULL,
    PRIMARY KEY (realm_id, principal_id, command_id)
);

CREATE TABLE IF NOT EXISTS outbox (
    id UUID PRIMARY KEY,
    realm_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    aggregate_id TEXT NOT NULL,
    pos_x INT,
    pos_y INT,
    owner_player_id UUID,
    is_private BOOLEAN NOT NULL DEFAULT false,
    visible_players JSONB NOT NULL DEFAULT '[]'::jsonb,
    payload JSONB NOT NULL,
    created_at_ms BIGINT NOT NULL,
    published_at_ms BIGINT NOT NULL DEFAULT 0,
    attempts INT NOT NULL DEFAULT 0,
    last_error TEXT
);
CREATE INDEX IF NOT EXISTS outbox_pending_idx ON outbox(realm_id, published_at_ms, created_at_ms);
CREATE INDEX IF NOT EXISTS outbox_aggregate_idx ON outbox(realm_id, aggregate_id);

CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY,
    realm_id TEXT NOT NULL,
    kind TEXT NOT NULL,
    participants JSONB NOT NULL,
    payload JSONB NOT NULL,
    created_at_ms BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS reports_realm_idx ON reports(realm_id, created_at_ms DESC);

CREATE TABLE IF NOT EXISTS alliances (
    realm_id TEXT NOT NULL,
    alliance_id TEXT NOT NULL,
    name TEXT NOT NULL,
    tag TEXT NOT NULL,
    leader_id UUID NOT NULL,
    created_at_ms BIGINT NOT NULL,
    PRIMARY KEY (realm_id, alliance_id),
    UNIQUE (realm_id, tag)
);

CREATE TABLE IF NOT EXISTS alliance_members (
    realm_id TEXT NOT NULL,
    alliance_id TEXT NOT NULL,
    player_id UUID NOT NULL,
    role TEXT NOT NULL DEFAULT 'member',
    joined_at_ms BIGINT NOT NULL,
    PRIMARY KEY (realm_id, alliance_id, player_id),
    FOREIGN KEY (realm_id, alliance_id) REFERENCES alliances(realm_id, alliance_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS alliance_invites (
    realm_id TEXT NOT NULL,
    alliance_id TEXT NOT NULL,
    player_id UUID NOT NULL,
    invited_by UUID NOT NULL,
    created_at_ms BIGINT NOT NULL,
    PRIMARY KEY (realm_id, alliance_id, player_id)
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY,
    realm_id TEXT NOT NULL,
    scope TEXT NOT NULL,
    target_id TEXT NOT NULL DEFAULT '',
    sender_id UUID NOT NULL,
    sender_name TEXT NOT NULL,
    text TEXT NOT NULL,
    created_at_ms BIGINT NOT NULL
);
CREATE INDEX IF NOT EXISTS chat_scope_idx ON chat_messages(realm_id, scope, target_id, created_at_ms DESC);

CREATE TABLE IF NOT EXISTS help_tasks (
    realm_id TEXT NOT NULL,
    id TEXT NOT NULL,
    player_id UUID NOT NULL,
    kind TEXT NOT NULL,
    reduced_ms BIGINT NOT NULL DEFAULT 0,
    helpers JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at_ms BIGINT NOT NULL,
    PRIMARY KEY (realm_id, id)
);

CREATE TABLE IF NOT EXISTS rallies (
    realm_id TEXT NOT NULL,
    rally_id TEXT NOT NULL,
    leader_id UUID NOT NULL,
    alliance_id TEXT NOT NULL,
    from_city_id TEXT NOT NULL,
    to_x INT NOT NULL,
    to_y INT NOT NULL,
    target_id TEXT NOT NULL,
    start_at_ms BIGINT NOT NULL,
    state TEXT NOT NULL DEFAULT 'forming',
    PRIMARY KEY (realm_id, rally_id)
);

CREATE TABLE IF NOT EXISTS rally_members (
    realm_id TEXT NOT NULL,
    rally_id TEXT NOT NULL,
    player_id UUID NOT NULL,
    troops JSONB NOT NULL,
    hero TEXT NOT NULL DEFAULT '',
    joined_at_ms BIGINT NOT NULL,
    PRIMARY KEY (realm_id, rally_id, player_id)
);

CREATE TABLE IF NOT EXISTS territory (
    realm_id TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    kind TEXT NOT NULL,
    x INT NOT NULL,
    y INT NOT NULL,
    owner_player_id UUID,
    owner_alliance_id TEXT,
    captured_at_ms BIGINT NOT NULL,
    PRIMARY KEY (realm_id, entity_id)
);

CREATE TABLE IF NOT EXISTS season_scores (
    realm_id TEXT NOT NULL,
    score_key TEXT NOT NULL,
    player_id UUID,
    alliance_id TEXT,
    score BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (realm_id, score_key)
);

-- --------------------------- time & fencing ---------------------------
CREATE OR REPLACE FUNCTION wall_now_ms() RETURNS BIGINT AS $$
    SELECT (extract(epoch from clock_timestamp()) * 1000)::BIGINT;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION clock_now_ms(p_realm TEXT) RETURNS BIGINT AS $$
    SELECT (extract(epoch from statement_timestamp()) * 1000)::BIGINT + COALESCE((SELECT offset_micros FROM realm_clock WHERE realm_id = p_realm), 0) / 1000;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION assert_ownership(p_realm TEXT, p_owner TEXT, p_epoch BIGINT) RETURNS void AS $$
DECLARE r realm_ownership%ROWTYPE;
BEGIN
    SELECT * INTO r FROM realm_ownership WHERE realm_id = p_realm FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'realm has no owner' USING ERRCODE = 'P0001'; END IF;
    IF r.owner_id <> p_owner OR r.epoch <> p_epoch THEN
        RAISE EXCEPTION 'stale fencing token: expected epoch % owner %, found % / %', p_epoch, p_owner, r.epoch, r.owner_id USING ERRCODE = 'P0002';
    END IF;
    IF r.lease_until_ms < wall_now_ms() THEN
        RAISE EXCEPTION 'ownership lease expired' USING ERRCODE = 'P0003';
    END IF;
END;
$$ LANGUAGE plpgsql;
