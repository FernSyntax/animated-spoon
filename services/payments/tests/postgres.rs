//! Real-PostgreSQL integration tests. Run with:
//!   KD_TEST_PAYMENTS_DB=postgres://kd:kd@localhost:15433/kd_payments_test \
//!     cargo test -p payments -- --include-ignored

use payments::{catalog, store::Store};

fn db_url() -> String {
    std::env::var("KD_TEST_PAYMENTS_DB").expect("KD_TEST_PAYMENTS_DB must be set for these tests")
}

#[tokio::test]
#[ignore = "requires KD_TEST_PAYMENTS_DB"]
async fn payment_survives_new_store_and_replay_does_not_regrant() {
    let url = db_url();
    let store = Store::connect(&url).await.expect("connect to test DB");
    let payment = store
        .create_payment("db-restart-account", catalog::GEMS_1000)
        .await
        .expect("create payment");
    let first = store
        .complete_payment(&payment.id)
        .await
        .expect("first fulfillment");
    assert!(first.newly_granted);
    assert_eq!(first.grant["credits"], 1000);

    let reopened = Store::connect(&url).await.expect("reopen store on same DB");
    let persisted = reopened
        .get_payment(&payment.id)
        .await
        .expect("payment row survived restart");
    assert_eq!(persisted.account_id, "db-restart-account");
    assert_eq!(persisted.sku, catalog::GEMS_1000);

    let replay = reopened
        .complete_payment(&payment.id)
        .await
        .expect("replayed fulfillment after restart");
    assert!(!replay.newly_granted);
    assert_eq!(replay.grant, first.grant);
}

#[tokio::test]
#[ignore = "requires KD_TEST_PAYMENTS_DB"]
async fn two_concurrent_completions_grant_once() {
    let url = db_url();
    let store = Store::connect(&url).await.expect("connect to test DB");
    let payment = store
        .create_payment("db-concurrent-account", catalog::GEMS_5000)
        .await
        .expect("create payment");

    let a_store = store.clone();
    let b_store = store.clone();
    let a_id = payment.id.clone();
    let b_id = payment.id.clone();
    let (first, second) = tokio::join!(
        async move { a_store.complete_payment(&a_id).await.expect("completion A") },
        async move { b_store.complete_payment(&b_id).await.expect("completion B") },
    );

    assert_ne!(first.newly_granted, second.newly_granted);
    assert_eq!(first.grant, second.grant);
    assert_eq!(first.grant["credits"], 5000);

    let replay = store
        .complete_payment(&payment.id)
        .await
        .expect("replay after concurrent completions");
    assert!(!replay.newly_granted);
    assert_eq!(replay.grant, first.grant);
}
