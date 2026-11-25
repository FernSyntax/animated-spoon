//! Argon2id password hashing and revocable JWT session tokens.
use argon2::password_hash::{
    rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString,
};
use argon2::{Argon2, Params};
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, Algorithm, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
/// JWT payload: account id plus revocable session metadata.
pub struct Claims {
    pub sub: String, // account id
    pub jti: String, // session id (matches sessions table for revocation)
    pub iat: i64,
    pub exp: i64,
    pub iss: String,
}

/// Password hashing and JWT signing/verification. Cloneable for use in shared state.
pub struct Auth {
    secret: String,
}

impl Auth {
    pub fn new(secret: String) -> Self {
        Self { secret }
    }

    pub fn hash_password(password: &str) -> anyhow::Result<String> {
        // Argon2id, memory-hard, vetted parameters.
        let params = Params::new(19_456, 2, 1, None).map_err(|e| anyhow::anyhow!(e.to_string()))?;
        let argon = Argon2::new(argon2::Algorithm::Argon2id, argon2::Version::V0x13, params);
        let salt = SaltString::generate(&mut OsRng);
        let h = argon
            .hash_password(password.as_bytes(), &salt)
            .map_err(|e| anyhow::anyhow!(e.to_string()))?;
        Ok(h.to_string())
    }

    pub fn verify_password(hash: &str, password: &str) -> bool {
        let parsed = match PasswordHash::new(hash) {
            Ok(p) => p,
            Err(_) => return false,
        };
        Argon2::default()
            .verify_password(password.as_bytes(), &parsed)
            .is_ok()
    }

    pub fn issue(
        &self,
        account_id: &str,
        session_id: &str,
        ttl_secs: i64,
    ) -> anyhow::Result<String> {
        let now = Utc::now().timestamp();
        let claims = Claims {
            sub: account_id.to_string(),
            jti: session_id.to_string(),
            iat: now,
            exp: now + ttl_secs,
            iss: "kd-control-plane".into(),
        };
        Ok(encode(
            &Header::new(Algorithm::HS256),
            &claims,
            &EncodingKey::from_secret(self.secret.as_bytes()),
        )?)
    }

    pub fn validate(&self, token: &str) -> anyhow::Result<Claims> {
        let mut v = Validation::new(Algorithm::HS256);
        // jsonwebtoken defaults to a 60s leeway; a revocable session must expire
        // exactly when its `exp` says so.
        v.leeway = 0;
        v.set_required_spec_claims(&["exp", "iss", "sub"]);
        v.set_issuer(&["kd-control-plane"]);
        let data = decode::<Claims>(token, &DecodingKey::from_secret(self.secret.as_bytes()), &v)?;
        Ok(data.claims)
    }

    pub fn new_session_id() -> String {
        Uuid::new_v4().to_string()
    }

    pub fn token_live_for(ttl_secs: i64) -> i64 {
        (Utc::now() + Duration::seconds(ttl_secs)).timestamp()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn argon2_hashes_verify_and_reject_wrong_password() {
        let hash = Auth::hash_password("correct horse battery staple").unwrap();
        assert!(hash.starts_with("$argon2id$"));
        assert!(Auth::verify_password(&hash, "correct horse battery staple"));
        assert!(!Auth::verify_password(&hash, "wrong password"));
        assert!(!Auth::verify_password("not a hash", "anything"));
        // Salting means the same password hashes differently each time.
        let other = Auth::hash_password("correct horse battery staple").unwrap();
        assert_ne!(hash, other);
    }

    #[test]
    fn jwt_roundtrip_preserves_account_and_session() {
        let auth = Auth::new("test-secret".into());
        let token = auth.issue("acct-1", "session-1", 3600).unwrap();
        let claims = auth.validate(&token).unwrap();
        assert_eq!(claims.sub, "acct-1");
        assert_eq!(claims.jti, "session-1");
        assert_eq!(claims.iss, "kd-control-plane");
        assert!(claims.exp > claims.iat);
    }

    #[test]
    fn expired_and_wrongly_signed_tokens_are_rejected() {
        let auth = Auth::new("test-secret".into());
        let expired = auth.issue("acct-1", "session-1", -10).unwrap();
        assert!(auth.validate(&expired).is_err());

        let other = Auth::new("different-secret".into());
        let foreign = other.issue("acct-1", "session-1", 3600).unwrap();
        assert!(auth.validate(&foreign).is_err());
        assert!(auth.validate("not-a-jwt").is_err());
    }

    #[test]
    fn issuer_is_enforced() {
        let now = Utc::now().timestamp();
        let rogue = Claims {
            sub: "acct-1".into(),
            jti: "session-1".into(),
            iat: now,
            exp: now + 3600,
            iss: "evil-issuer".into(),
        };
        let token = encode(
            &Header::new(Algorithm::HS256),
            &rogue,
            &EncodingKey::from_secret(b"test-secret"),
        )
        .unwrap();
        let auth = Auth::new("test-secret".into());
        assert!(auth.validate(&token).is_err());
    }

    #[test]
    fn session_ids_are_unique() {
        assert_ne!(Auth::new_session_id(), Auth::new_session_id());
    }
}
