//! Runtime configuration, read from environment variables at startup.
//!
//! No `kd_common::Settings` dependency on purpose: this service is standalone
//! and must be runnable with only a couple of Stripe env vars (or none at all,
//! in which case it runs against the local stub provider).

use anyhow::{Context, Result};

#[derive(Clone, Debug)]
pub struct Config {
    /// Socket the HTTP server binds to.
    pub http_addr: String,
    /// Externally reachable base URL, used for the dev stub checkout link and
    /// as the fallback for Stripe's success/cancel URLs.
    pub public_base_url: String,
    /// Presence of this key is the production/dev switch. If absent, the
    /// service uses the local stub checkout provider and never calls Stripe.
    pub stripe_secret_key: Option<String>,
    /// Shared secret used to verify `Stripe-Signature` headers.
    pub stripe_webhook_secret: Option<String>,
    /// Max age of a signed webhook, in seconds (replay protection).
    pub webhook_tolerance_secs: u64,
    pub stripe_success_url: String,
    pub stripe_cancel_url: String,
    /// Overridable to point tests at a local mock of the Stripe REST API.
    pub stripe_api_base: String,
    /// When set, checkout requests must carry a signed account id.
    pub internal_secret: Option<String>,
}

impl Config {
    pub fn from_env() -> Result<Self> {
        let http_addr = env_or("KD_HTTP_ADDR", "0.0.0.0:8080");
        let public_base_url = trim_slash(env_or("KD_PUBLIC_BASE_URL", "http://localhost:8080"));
        let stripe_secret_key = non_empty_env("KD_STRIPE_SECRET_KEY");
        let stripe_webhook_secret = non_empty_env("KD_STRIPE_WEBHOOK_SECRET");
        let webhook_tolerance_secs = env_or("KD_STRIPE_WEBHOOK_TOLERANCE_SECS", "300")
            .parse()
            .context("KD_STRIPE_WEBHOOK_TOLERANCE_SECS must be a number of seconds")?;
        let stripe_success_url = non_empty_env("KD_STRIPE_SUCCESS_URL")
            .unwrap_or_else(|| format!("{public_base_url}/checkout/success"));
        let stripe_cancel_url = non_empty_env("KD_STRIPE_CANCEL_URL")
            .unwrap_or_else(|| format!("{public_base_url}/checkout/cancel"));
        let stripe_api_base = trim_slash(env_or("KD_STRIPE_API_BASE", "https://api.stripe.com"));
        let internal_secret = non_empty_env("KD_INTERNAL_SECRET");

        let config = Self {
            http_addr,
            public_base_url,
            stripe_secret_key,
            stripe_webhook_secret,
            webhook_tolerance_secs,
            stripe_success_url,
            stripe_cancel_url,
            stripe_api_base,
            internal_secret,
        };
        config.validate()?;
        Ok(config)
    }

    /// Fail fast on configurations that would silently weaken payment security.
    pub fn validate(&self) -> Result<()> {
        if self.stripe_secret_key.is_some() && self.stripe_webhook_secret.is_none() {
            anyhow::bail!("KD_STRIPE_WEBHOOK_SECRET is required in live mode");
        }
        if self.webhook_tolerance_secs == 0 {
            anyhow::bail!("KD_STRIPE_WEBHOOK_TOLERANCE_SECS must be greater than zero");
        }
        if self
            .stripe_secret_key
            .as_deref()
            .is_some_and(|key| key.starts_with("sk_live_"))
            && !self.public_base_url.starts_with("https://")
        {
            anyhow::bail!("live Stripe keys require an https KD_PUBLIC_BASE_URL (TLS termination)");
        }
        Ok(())
    }

    /// True when no Stripe secret key is configured: use the local stub flow.
    pub fn is_dev(&self) -> bool {
        self.stripe_secret_key.is_none()
    }

    /// Deterministic config for unit tests; never reads the process environment.
    #[cfg(test)]
    pub(crate) fn for_test() -> Self {
        Self {
            http_addr: "0.0.0.0:8080".into(),
            public_base_url: "http://localhost:8080".into(),
            stripe_secret_key: None,
            stripe_webhook_secret: None,
            webhook_tolerance_secs: 300,
            stripe_success_url: "http://localhost:8080/checkout/success".into(),
            stripe_cancel_url: "http://localhost:8080/checkout/cancel".into(),
            stripe_api_base: "https://api.stripe.com".into(),
            internal_secret: None,
        }
    }
}

fn env_or(key: &str, default: &str) -> String {
    non_empty_env(key).unwrap_or_else(|| default.to_string())
}

fn non_empty_env(key: &str) -> Option<String> {
    std::env::var(key)
        .ok()
        .map(|value| value.trim().to_string())
        .filter(|value| !value.is_empty())
}

fn trim_slash(value: String) -> String {
    value.trim_end_matches('/').to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn base() -> Config {
        Config {
            http_addr: "0.0.0.0:8080".into(),
            public_base_url: "https://shop.example.com".into(),
            stripe_secret_key: None,
            stripe_webhook_secret: None,
            webhook_tolerance_secs: 300,
            stripe_success_url: "https://shop.example.com/success".into(),
            stripe_cancel_url: "https://shop.example.com/cancel".into(),
            stripe_api_base: "https://api.stripe.com".into(),
            internal_secret: None,
        }
    }

    #[test]
    fn dev_config_is_valid() {
        assert!(base().validate().is_ok());
    }

    #[test]
    fn live_mode_requires_webhook_secret_and_tls() {
        let mut c = base();
        c.stripe_secret_key = Some("sk_test_x".into());
        assert!(
            c.validate().is_err(),
            "missing webhook secret must be rejected"
        );

        c.stripe_webhook_secret = Some("whsec_x".into());
        assert!(
            c.validate().is_ok(),
            "test keys may use http in development"
        );

        c.stripe_secret_key = Some("sk_live_x".into());
        c.public_base_url = "http://shop.example.com".into();
        assert!(c.validate().is_err(), "live keys must not use http");
    }

    #[test]
    fn zero_replay_window_is_rejected() {
        let mut c = base();
        c.webhook_tolerance_secs = 0;
        assert!(c.validate().is_err());
    }
}
