//! Stripe-ready payments service for the gem/item shop.
//!
//! The service is deliberately split into small, pure-ish pieces so the money
//! paths can be tested without network access:
//!
//! * [`catalog`] maps SKUs to prices and grants (pure).
//! * [`signature`] verifies Stripe webhook signatures (pure, constant-time).
//! * [`store`] owns payment and idempotency state in PostgreSQL (production) or
//!   in memory (dev-only fallback when no database URL is configured).
//! * [`api`] wires the HTTP layer and the Stripe REST client.
//!
//! See `docs/PAYMENTS.md` for configuration and the remaining production
//! requirements.

pub mod api;
pub mod catalog;
pub mod config;
pub mod signature;
pub mod store;

#[cfg(test)]
mod tests {
    use crate::{api, catalog, config::Config, signature, store::Store};
    use axum::{
        body::{to_bytes, Body},
        http::{Request, StatusCode},
    };
    use serde_json::{json, Value};
    use tower::ServiceExt;

    fn state() -> api::AppState {
        api::AppState::new(Config::for_test(), Store::new(), reqwest::Client::new())
    }

    async fn call(app: axum::Router, req: Request<Body>) -> (StatusCode, Value) {
        let resp = app.oneshot(req).await.expect("router service failed");
        let status = resp.status();
        let bytes = to_bytes(resp.into_body(), 64 * 1024)
            .await
            .expect("read response body");
        let body = if bytes.is_empty() {
            Value::Null
        } else {
            serde_json::from_slice(&bytes).expect("response is JSON")
        };
        (status, body)
    }

    #[test]
    fn signature_verification_accepts_valid_and_rejects_invalid() {
        let secret = "whsec_test_secret";
        let body = br#"{"type":"checkout.session.completed"}"#;
        let timestamp = "1700000000";
        let sig = signature::sign(secret, timestamp, body);
        let header = format!("t={timestamp},v1={sig}");

        // Correct signature over the exact raw body.
        assert!(signature::verify_signature(secret, &header, body).is_ok());

        // Body changed after signing (the classic tampering case).
        let tampered = br#"{"type":"checkout.session.completed","credits":999999}"#;
        assert!(signature::verify_signature(secret, &header, tampered).is_err());

        // Signature changed, wrong secret, missing timestamp, missing v1.
        let flipped = format!(
            "{}{}",
            if sig.starts_with('0') { "1" } else { "0" },
            &sig[1..]
        );
        assert!(
            signature::verify_signature(secret, &format!("t={timestamp},v1={flipped}"), body)
                .is_err()
        );
        assert!(signature::verify_signature("wrong-secret", &header, body).is_err());
        assert!(signature::verify_signature(secret, &format!("v1={sig}"), body).is_err());
        assert!(signature::verify_signature(secret, &format!("t={timestamp}"), body).is_err());
    }

    #[tokio::test]
    async fn fulfillment_is_idempotent_by_payment_id() {
        let store = Store::new();
        let payment = store
            .create_payment("account-1", catalog::GEMS_1000)
            .await
            .expect("create payment");

        let first = store
            .complete_payment(&payment.id)
            .await
            .expect("first fulfillment");
        assert!(first.newly_granted);
        assert_eq!(first.grant["sku"], catalog::GEMS_1000);
        assert_eq!(first.grant["credits"], 1000);

        // Replaying the same webhook / hitting the stub again must not re-grant.
        let replay = store
            .complete_payment(&payment.id)
            .await
            .expect("replayed fulfillment");
        assert!(!replay.newly_granted);
        assert_eq!(first.grant, replay.grant);
        assert_eq!(store.fulfilled_count().await, 1);

        // A different payment is a different grant.
        let other = store
            .create_payment("account-2", catalog::GEMS_1000)
            .await
            .expect("create second payment");
        assert!(
            store
                .complete_payment(&other.id)
                .await
                .expect("second fulfillment")
                .newly_granted
        );
        assert_eq!(store.fulfilled_count().await, 2);
    }

    #[tokio::test]
    async fn unknown_sku_is_rejected() {
        assert!(catalog::fulfill("p-1", "a-1", "not_a_sku").is_err());
        assert!(catalog::unit_amount_cents("not_a_sku").is_err());

        // Checkout refuses to create a payment for an unknown SKU.
        let store = Store::new();
        assert!(store.create_payment("a-1", "not_a_sku").await.is_err());
    }

    #[tokio::test]
    async fn checkout_requires_signed_account_when_secret_is_configured() {
        let mut cfg = Config::for_test();
        cfg.internal_secret = Some("internal-secret".into());
        let app = api::router(api::AppState::new(
            cfg,
            Store::new(),
            reqwest::Client::new(),
        ));
        let body =
            || Body::from(json!({"account_id": "victim", "sku": catalog::GEMS_1000}).to_string());

        let (status, _) = call(
            app.clone(),
            Request::builder()
                .method("POST")
                .uri("/checkout")
                .header("content-type", "application/json")
                .body(body())
                .unwrap(),
        )
        .await;
        assert_eq!(
            status,
            StatusCode::UNAUTHORIZED,
            "unsigned account must be rejected"
        );

        let signature = signature::sign_account("internal-secret", "victim");
        let (status, payload) = call(
            app,
            Request::builder()
                .method("POST")
                .uri("/checkout")
                .header("content-type", "application/json")
                .header("x-kd-account-signature", signature)
                .body(body())
                .unwrap(),
        )
        .await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(payload["provider"], "stub");
    }

    #[tokio::test]
    async fn reconciliation_fulfills_missed_webhooks_once() {
        let st = state();
        let app = api::router(st.clone());
        let created = st
            .store
            .create_payment("a-recon", catalog::GEMS_1000)
            .await
            .unwrap();
        assert_eq!(st.store.fulfilled_count().await, 0);
        assert_eq!(st.store.pending_ids(0).await.unwrap().len(), 1);

        let first = call(
            app.clone(),
            Request::builder()
                .method("POST")
                .uri("/admin/reconcile")
                .body(Body::empty())
                .unwrap(),
        )
        .await;
        assert_eq!(first.0, StatusCode::OK);
        assert_eq!(first.1["fulfilled"], 1, "missed payment must be granted");

        let second = call(
            app,
            Request::builder()
                .method("POST")
                .uri("/admin/reconcile")
                .body(Body::empty())
                .unwrap(),
        )
        .await;
        assert_eq!(
            second.1["fulfilled"], 0,
            "reconciliation must be idempotent"
        );
        assert!(
            !st.store
                .complete_payment(&created.id)
                .await
                .unwrap()
                .newly_granted
        );
    }

    #[tokio::test]
    async fn dev_stub_checkout_fulfills_and_is_replayable() {
        let app = api::router(state());
        let (status, body) = call(
            app.clone(),
            Request::builder()
                .method("POST")
                .uri("/checkout")
                .header("content-type", "application/json")
                .body(Body::from(
                    json!({"account_id": "a-1", "sku": catalog::GEMS_1000}).to_string(),
                ))
                .expect("checkout request"),
        )
        .await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(body["provider"], "stub");
        let url = body["checkout_url"].as_str().expect("checkout URL");
        assert!(url.starts_with("http://localhost:8080/stub-checkout/"));
        let path = url.trim_start_matches("http://localhost:8080").to_string();

        let (status, first) = call(
            app.clone(),
            Request::builder()
                .uri(&path)
                .body(Body::empty())
                .expect("stub GET"),
        )
        .await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(first["grant"]["credits"], 1000);
        assert!(first["newly_granted"].as_bool().unwrap());

        let (status, replay) = call(
            app,
            Request::builder()
                .uri(&path)
                .body(Body::empty())
                .expect("stub GET"),
        )
        .await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(replay["grant"], first["grant"]);
        assert!(!replay["newly_granted"].as_bool().unwrap());
    }

    #[tokio::test]
    async fn webhook_rejects_bad_signature_and_fulfills_good_one_once() {
        let mut cfg = Config::for_test();
        cfg.stripe_webhook_secret = Some("whsec_test_secret".into());
        let store = Store::new();
        let payment = store
            .create_payment("a-1", catalog::GEMS_1000)
            .await
            .expect("create payment");
        let app = api::router(api::AppState::new(
            cfg,
            store.clone(),
            reqwest::Client::new(),
        ));

        // A bad signature is rejected with 400 before any parsing/fulfillment.
        let (status, _) = call(
            app.clone(),
            Request::builder()
                .method("POST")
                .uri("/webhook/stripe")
                .header("content-type", "application/json")
                .header("Stripe-Signature", "t=1700000000,v1=deadbeef")
                .body(Body::from(b"{}".to_vec()))
                .expect("webhook request"),
        )
        .await;
        assert_eq!(status, StatusCode::BAD_REQUEST);
        assert_eq!(store.fulfilled_count().await, 0);

        // A correctly signed `checkout.session.completed` fulfills exactly once.
        let event = json!({
            "id": "evt_test",
            "type": "checkout.session.completed",
            "data": {"object": {
                "id": "cs_test",
                "client_reference_id": payment.id,
                "payment_status": "paid"
            }}
        });
        let raw = serde_json::to_vec(&event).expect("serialize event");
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .expect("system clock")
            .as_secs()
            .to_string();
        let header = format!(
            "t={now},v1={}",
            signature::sign("whsec_test_secret", &now, &raw)
        );
        for expected_new in [true, false] {
            let (status, body) = call(
                app.clone(),
                Request::builder()
                    .method("POST")
                    .uri("/webhook/stripe")
                    .header("content-type", "application/json")
                    .header("Stripe-Signature", &header)
                    .body(Body::from(raw.clone()))
                    .expect("webhook request"),
            )
            .await;
            assert_eq!(status, StatusCode::OK);
            assert_eq!(body["grant"]["credits"], 1000);
            assert_eq!(body["newly_granted"].as_bool().unwrap(), expected_new);
        }
        assert_eq!(store.fulfilled_count().await, 1);
    }
}
