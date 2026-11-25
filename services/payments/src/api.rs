//! HTTP layer: checkout, dev stub, and the signed Stripe webhook.

use crate::{
    catalog,
    config::Config,
    signature,
    store::{Payment, Store},
};
use axum::{
    body::Bytes,
    extract::{Path, State},
    http::{HeaderMap, StatusCode},
    response::{IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::{
    sync::Arc,
    time::{SystemTime, UNIX_EPOCH},
};

#[derive(Clone)]
pub struct AppState {
    pub config: Arc<Config>,
    pub store: Store,
    pub http: reqwest::Client,
}

impl AppState {
    pub fn new(config: Config, store: Store, http: reqwest::Client) -> Self {
        Self {
            config: Arc::new(config),
            store,
            http,
        }
    }
}

pub fn router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(|| async { "ok" }))
        .route("/checkout", post(checkout))
        .route("/webhook/stripe", post(stripe_webhook))
        // Dev-only convenience endpoint; returns 404 in production mode.
        .route("/stub-checkout/{id}", get(stub_checkout))
        .route("/admin/reconcile", post(reconcile))
        .with_state(state)
}

/// Re-check payments whose webhook may have been missed while the service was
/// down. With the dev stub every pending payment is treated as paid; in live
/// mode each Stripe Checkout Session is queried and only `payment_status=paid`
/// is fulfilled. Fulfillment remains idempotent.
pub async fn reconcile(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Json<serde_json::Value>, ApiError> {
    if let Some(secret) = &state.config.internal_secret {
        let provided = headers
            .get("x-kd-internal")
            .and_then(|v| v.to_str().ok())
            .unwrap_or("");
        if provided != secret {
            return Err(ApiError::new(
                StatusCode::UNAUTHORIZED,
                "invalid internal credential",
            ));
        }
    }
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis() as i64;
    let pending = state.store.pending_ids(now - 5_000).await?;
    let checked = pending.len();
    let mut fulfilled = 0;
    for id in pending {
        let paid = match state.config.stripe_secret_key.as_deref() {
            None => true,
            Some(secret) => {
                let session_id = state
                    .store
                    .get_payment(&id)
                    .await
                    .and_then(|p| p.stripe_session_id)
                    .ok_or_else(|| {
                        ApiError::new(StatusCode::BAD_REQUEST, "payment has no Stripe session id")
                    })?;
                stripe_session_is_paid(&state, secret, &session_id).await?
            }
        };
        if paid && state.store.complete_payment(&id).await?.newly_granted {
            fulfilled += 1;
        }
    }
    Ok(Json(json!({"checked": checked, "fulfilled": fulfilled})))
}

async fn stripe_session_is_paid(
    state: &AppState,
    secret: &str,
    session_id: &str,
) -> Result<bool, ApiError> {
    let url = format!(
        "{}/v1/checkout/sessions/{}",
        state.config.stripe_api_base, session_id
    );
    let response = state
        .http
        .get(url)
        .bearer_auth(secret)
        .send()
        .await
        .map_err(|e| ApiError::new(StatusCode::BAD_GATEWAY, e.to_string()))?;
    if !response.status().is_success() {
        return Err(ApiError::new(
            StatusCode::BAD_GATEWAY,
            format!("Stripe session lookup failed: {}", response.status()),
        ));
    }
    let body: serde_json::Value = response
        .json()
        .await
        .map_err(|e| ApiError::new(StatusCode::BAD_GATEWAY, e.to_string()))?;
    Ok(body["payment_status"] == "paid")
}

#[derive(Debug, Deserialize)]
pub struct CheckoutRequest {
    pub account_id: String,
    pub sku: String,
}

#[derive(Debug, Serialize)]
pub struct CheckoutResponse {
    pub payment_id: String,
    pub checkout_url: String,
    pub provider: &'static str,
}

#[derive(Debug)]
pub struct ApiError {
    status: StatusCode,
    message: String,
}

impl ApiError {
    fn new(status: StatusCode, message: impl Into<String>) -> Self {
        Self {
            status,
            message: message.into(),
        }
    }
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        (self.status, Json(json!({ "error": self.message }))).into_response()
    }
}

impl From<anyhow::Error> for ApiError {
    fn from(error: anyhow::Error) -> Self {
        ApiError::new(StatusCode::INTERNAL_SERVER_ERROR, error.to_string())
    }
}

pub async fn checkout(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(req): Json<CheckoutRequest>,
) -> Result<Json<CheckoutResponse>, ApiError> {
    if req.account_id.trim().is_empty() {
        return Err(ApiError::new(
            StatusCode::BAD_REQUEST,
            "account_id must not be empty",
        ));
    }
    // Deployments that share the gateway's secret require proof that the
    // account id came from an authenticated caller, not from the browser.
    if let Some(secret) = &state.config.internal_secret {
        let provided = headers
            .get("x-kd-account-signature")
            .and_then(|v| v.to_str().ok())
            .unwrap_or("");
        signature::verify_account(secret, &req.account_id, provided)
            .map_err(|e| ApiError::new(StatusCode::UNAUTHORIZED, e.to_string()))?;
    }
    let payment = state
        .store
        .create_payment(&req.account_id, &req.sku)
        .await
        .map_err(|e| ApiError::new(StatusCode::BAD_REQUEST, e.to_string()))?;

    let (checkout_url, provider) = match state.config.stripe_secret_key.as_deref() {
        Some(secret) => (
            create_stripe_session(&state, secret, &payment).await?,
            "stripe",
        ),
        None => (
            format!(
                "{}/stub-checkout/{}",
                state.config.public_base_url, payment.id
            ),
            "stub",
        ),
    };
    tracing::info!(payment_id = %payment.id, sku = %payment.sku, provider, "checkout created");

    Ok(Json(CheckoutResponse {
        payment_id: payment.id,
        checkout_url,
        provider,
    }))
}

#[derive(Deserialize)]
struct StripeSession {
    id: Option<String>,
    url: String,
}

/// Create a hosted Stripe Checkout Session using the REST API directly (no
/// third-party SDK). All values are form-encoded as Stripe expects.
async fn create_stripe_session(
    state: &AppState,
    secret: &str,
    payment: &Payment,
) -> Result<String, ApiError> {
    let unit_amount = catalog::unit_amount_cents(&payment.sku)
        .map_err(|e| ApiError::new(StatusCode::BAD_REQUEST, e.to_string()))?;
    let name = catalog::product_name(&payment.sku)
        .map_err(|e| ApiError::new(StatusCode::BAD_REQUEST, e.to_string()))?;
    let form: Vec<(&str, String)> = vec![
        ("mode", "payment".to_string()),
        ("client_reference_id", payment.id.clone()),
        ("line_items[0][quantity]", "1".to_string()),
        ("line_items[0][price_data][currency]", "usd".to_string()),
        (
            "line_items[0][price_data][unit_amount]",
            unit_amount.to_string(),
        ),
        (
            "line_items[0][price_data][product_data][name]",
            name.to_string(),
        ),
        ("success_url", state.config.stripe_success_url.clone()),
        ("cancel_url", state.config.stripe_cancel_url.clone()),
    ];

    let response = state
        .http
        .post(format!(
            "{}/v1/checkout/sessions",
            state.config.stripe_api_base
        ))
        .bearer_auth(secret)
        .form(&form)
        .send()
        .await
        .map_err(|e| {
            ApiError::new(
                StatusCode::BAD_GATEWAY,
                format!("Stripe request failed: {e}"),
            )
        })?;
    let status = response.status();
    let body = response.text().await.unwrap_or_default();
    if !status.is_success() {
        tracing::error!(%status, %body, "Stripe checkout session creation failed");
        return Err(ApiError::new(
            StatusCode::BAD_GATEWAY,
            format!("Stripe returned {status}"),
        ));
    }
    let session: StripeSession = serde_json::from_str(&body).map_err(|e| {
        ApiError::new(
            StatusCode::BAD_GATEWAY,
            format!("Stripe returned an unexpected response: {e}"),
        )
    })?;
    if let Some(id) = session.id.as_deref() {
        state.store.set_stripe_session_id(&payment.id, id).await;
    }
    Ok(session.url)
}

#[derive(Debug, Deserialize)]
struct StripeEvent {
    #[serde(rename = "type")]
    event_type: String,
    data: EventData,
}

#[derive(Debug, Deserialize)]
struct EventData {
    object: SessionObject,
}

#[derive(Debug, Deserialize)]
struct SessionObject {
    id: Option<String>,
    client_reference_id: Option<String>,
    payment_status: Option<String>,
}

/// Signature verification + fulfillment. Kept separate so the handler can
/// simply render whatever error comes back.
pub async fn stripe_webhook(
    State(state): State<AppState>,
    headers: HeaderMap,
    body: Bytes,
) -> Response {
    handle_webhook(state, headers, body)
        .await
        .unwrap_or_else(|error| error.into_response())
}

async fn handle_webhook(
    state: AppState,
    headers: HeaderMap,
    body: Bytes,
) -> Result<Response, ApiError> {
    let secret = state
        .config
        .stripe_webhook_secret
        .as_deref()
        .ok_or_else(|| {
            ApiError::new(
                StatusCode::SERVICE_UNAVAILABLE,
                "KD_STRIPE_WEBHOOK_SECRET is not configured",
            )
        })?;
    let signature_header = headers
        .get("Stripe-Signature")
        .and_then(|value| value.to_str().ok())
        .ok_or_else(|| ApiError::new(StatusCode::BAD_REQUEST, "missing Stripe-Signature header"))?;
    let now_secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|e| ApiError::new(StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .as_secs();
    signature::verify_signature_with_tolerance(
        secret,
        signature_header,
        &body,
        now_secs,
        state.config.webhook_tolerance_secs,
    )
    .map_err(|e| ApiError::new(StatusCode::BAD_REQUEST, format!("invalid signature: {e}")))?;

    // Parse only *after* verification, and always over the untouched raw body.
    let event: StripeEvent = serde_json::from_slice(&body)
        .map_err(|e| ApiError::new(StatusCode::BAD_REQUEST, format!("invalid event JSON: {e}")))?;
    if event.event_type != "checkout.session.completed" {
        return Ok((
            StatusCode::OK,
            Json(json!({ "received": true, "fulfilled": false, "reason": "ignored event type" })),
        )
            .into_response());
    }
    let session = event.data.object;
    let Some(payment_id) = session.client_reference_id.filter(|id| !id.is_empty()) else {
        return Err(ApiError::new(
            StatusCode::BAD_REQUEST,
            "checkout session is missing client_reference_id",
        ));
    };

    match state.store.complete_payment(&payment_id).await {
        Ok(outcome) => {
            tracing::info!(
                payment_id = %payment_id,
                session_id = ?session.id,
                payment_status = ?session.payment_status,
                newly_granted = outcome.newly_granted,
                "checkout.session.completed fulfilled"
            );
            Ok((
                StatusCode::OK,
                Json(json!({
                    "received": true,
                    "fulfilled": true,
                    "payment_id": payment_id,
                    "newly_granted": outcome.newly_granted,
                    "grant": outcome.grant,
                })),
            )
                .into_response())
        }
        Err(error) => {
            // Acknowledge to avoid an endless Stripe retry storm. Failures are
            // logged but not persisted for reconciliation yet (see PAYMENTS.md).
            tracing::error!(payment_id = %payment_id, error = %error, "cannot fulfill webhook; acknowledging");
            Ok((
                StatusCode::OK,
                Json(json!({
                    "received": true,
                    "fulfilled": false,
                    "reason": "payment could not be fulfilled",
                })),
            )
                .into_response())
        }
    }
}

/// DEV ONLY: GET this URL to pretend the player completed payment. It funnels
/// through the exact same `complete_payment` path as a real webhook.
pub async fn stub_checkout(
    State(state): State<AppState>,
    Path(payment_id): Path<String>,
) -> Response {
    if state.config.stripe_secret_key.is_some() {
        return ApiError::new(
            StatusCode::NOT_FOUND,
            "stub checkout is disabled when a Stripe secret key is configured",
        )
        .into_response();
    }
    match state.store.complete_payment(&payment_id).await {
        Ok(outcome) => (
            StatusCode::OK,
            Json(json!({
                "payment_id": payment_id,
                "newly_granted": outcome.newly_granted,
                "grant": outcome.grant,
                "note": "DEV STUB: no real money was charged",
            })),
        )
            .into_response(),
        Err(error) => ApiError::new(StatusCode::NOT_FOUND, error.to_string()).into_response(),
    }
}
