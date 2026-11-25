//! Stripe webhook signature verification.
//!
//! Stripe signs the exact bytes of the request body together with the
//! timestamp from the `Stripe-Signature` header:
//!
//! ```text
//! signature = HMAC-SHA256(secret, "{timestamp}.{raw_body}")
//! header    = t={timestamp},v1={hex_signature},...
//! ```
//!
//! Comparison is constant-time via [`subtle`]. The raw body must therefore be
//! passed straight from the HTTP extractor — re-serializing parsed JSON would
//! change the bytes and break verification.

use anyhow::{bail, Context, Result};
use hmac::{Hmac, Mac};
use sha2::Sha256;
use subtle::ConstantTimeEq;

type HmacSha256 = Hmac<Sha256>;

/// Verify the cryptographic signature only (no timestamp freshness check).
pub fn verify_signature(secret: &str, header: &str, body: &[u8]) -> Result<()> {
    let (timestamp, signatures) = parse_header(header)?;
    check_hmac(secret, &timestamp, body, &signatures)
}

/// Verify the signature and reject stale timestamps. This is what the webhook
/// endpoint uses: an attacker who captured a valid signed request cannot replay
/// it indefinitely.
pub fn verify_signature_with_tolerance(
    secret: &str,
    header: &str,
    body: &[u8],
    now_secs: u64,
    tolerance_secs: u64,
) -> Result<()> {
    let (timestamp, signatures) = parse_header(header)?;
    let signed_at: u64 = timestamp
        .parse()
        .context("Stripe-Signature has a malformed timestamp")?;
    let skew = now_secs.abs_diff(signed_at);
    if skew > tolerance_secs {
        bail!("Stripe-Signature timestamp is outside the allowed window");
    }
    check_hmac(secret, &timestamp, body, &signatures)
}

fn parse_header(header: &str) -> Result<(String, Vec<String>)> {
    let mut timestamp = None;
    let mut signatures = Vec::new();
    for part in header.split(',') {
        let Some((key, value)) = part.trim().split_once('=') else {
            continue;
        };
        match key {
            "t" => timestamp = Some(value.trim().to_string()),
            "v1" => signatures.push(value.trim().to_ascii_lowercase()),
            _ => {} // v0 and future schemes are ignored.
        }
    }
    let timestamp = timestamp.context("Stripe-Signature is missing the t= timestamp")?;
    if timestamp.is_empty() {
        bail!("Stripe-Signature has an empty t= timestamp");
    }
    if signatures.is_empty() {
        bail!("Stripe-Signature is missing a v1 signature");
    }
    Ok((timestamp, signatures))
}

fn check_hmac(secret: &str, timestamp: &str, body: &[u8], signatures: &[String]) -> Result<()> {
    let mut mac = HmacSha256::new_from_slice(secret.as_bytes())
        .context("invalid Stripe webhook secret length")?;
    mac.update(format!("{timestamp}.").as_bytes());
    mac.update(body);
    let expected = hex_encode(&mac.finalize().into_bytes());

    // Compare every provided signature without short-circuiting: this keeps
    // the comparison constant-time regardless of which value matches.
    let mut matched = 0u8;
    for candidate in signatures {
        let equal: bool = expected.as_bytes().ct_eq(candidate.as_bytes()).into();
        matched |= u8::from(equal);
    }
    if matched == 0 {
        bail!("Stripe-Signature does not match the request body");
    }
    Ok(())
}

/// Sign an account id with the shared internal secret. The gateway (which
/// already authenticates the user) sends this header with checkout requests so
/// a caller cannot mint a payment for somebody else's account.
pub fn sign_account(secret: &str, account_id: &str) -> String {
    let mut mac =
        HmacSha256::new_from_slice(secret.as_bytes()).expect("HMAC accepts any key length");
    mac.update(account_id.as_bytes());
    hex_encode(&mac.finalize().into_bytes())
}

/// Constant-time verification of the account signature header.
pub fn verify_account(secret: &str, account_id: &str, signature_hex: &str) -> Result<()> {
    let expected = sign_account(secret, account_id);
    if bool::from(expected.as_bytes().ct_eq(signature_hex.as_bytes())) {
        Ok(())
    } else {
        bail!("invalid account signature")
    }
}

fn hex_encode(bytes: &[u8]) -> String {
    use std::fmt::Write as _;
    let mut out = String::with_capacity(bytes.len() * 2);
    for byte in bytes {
        // Writing into a String cannot fail; ignore the fmt::Result.
        let _ = write!(out, "{byte:02x}");
    }
    out
}

/// Produce a signature for tests and for local manual webhook simulation.
#[cfg(test)]
pub(crate) fn sign(secret: &str, timestamp: &str, body: &[u8]) -> String {
    let mut mac = HmacSha256::new_from_slice(secret.as_bytes()).expect("secret length");
    mac.update(format!("{timestamp}.").as_bytes());
    mac.update(body);
    hex_encode(&mac.finalize().into_bytes())
}
