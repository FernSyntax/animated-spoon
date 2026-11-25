//! The shop catalog and the pure fulfillment rule.
//!
//! Adding a SKU here is the only place needed to make it purchasable (plus a
//! matching price in the Stripe dashboard, if you use explicit price IDs in a
//! future revision). Unknown SKUs are rejected everywhere, including at
//! checkout, so a player can never pay for something we cannot grant.

use anyhow::{bail, Result};
use serde_json::{json, Value};

pub const GEMS_1000: &str = "gems_1000";
pub const GEMS_5000: &str = "gems_5000";
pub const STARTER_PACK: &str = "starter_pack";

#[derive(Clone, Copy, Debug)]
struct SkuInfo {
    name: &'static str,
    unit_amount_cents: u64,
    credits: u64,
}

fn sku_info(sku: &str) -> Result<SkuInfo> {
    Ok(match sku {
        GEMS_1000 => SkuInfo {
            name: "1,000 Gems",
            unit_amount_cents: 999,
            credits: 1000,
        },
        GEMS_5000 => SkuInfo {
            name: "5,000 Gems",
            unit_amount_cents: 3999,
            credits: 5000,
        },
        STARTER_PACK => SkuInfo {
            name: "Starter Pack",
            unit_amount_cents: 499,
            credits: 500,
        },
        other => bail!("unknown sku: {other}"),
    })
}

/// Stripe `unit_amount` (minor units, USD cents) for a SKU.
pub fn unit_amount_cents(sku: &str) -> Result<u64> {
    Ok(sku_info(sku)?.unit_amount_cents)
}

/// Pure fulfillment rule: map a paid payment to the JSON grant delivered to
/// the game. It has no I/O and no state — the idempotency check lives in
/// [`crate::store`], so this is safe to call (and test) in isolation.
pub fn fulfill(payment_id: &str, account_id: &str, sku: &str) -> Result<Value> {
    let info = sku_info(sku)?;
    Ok(json!({
        "payment_id": payment_id,
        "account_id": account_id,
        "sku": sku,
        "credits": info.credits,
    }))
}

/// Product name sent to Stripe's `price_data.product_data.name` field.
pub(crate) fn product_name(sku: &str) -> Result<&'static str> {
    Ok(sku_info(sku)?.name)
}
