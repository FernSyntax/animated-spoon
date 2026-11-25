//! Integer-only, time-based resource accrual with persisted fractional remainders.
//! No floats; no dependence on polling frequency.

/// Accrue resources for `elapsed_secs` given production scaled by 1000 per hour
/// and a persisted fractional remainder in micro-units (1_000_000 = 1 unit).
///
/// Returns `(new_units, new_remainder_micro)`.
pub fn accrue(
    current_units: i64,
    remainder_micro: i64,
    prod_scaled_per_hour: i64,
    elapsed_secs: i64,
    capacity: i64,
) -> (i64, i64) {
    if elapsed_secs <= 0 || prod_scaled_per_hour <= 0 {
        return (current_units.min(capacity), remainder_micro);
    }
    // micro-units produced per second, computed at 128-bit precision.
    let per_sec = (prod_scaled_per_hour as i128 * 1_000_000) / (1000 * 3600);
    let total = remainder_micro as i128 + per_sec * elapsed_secs as i128;
    let whole = total / 1_000_000;
    let rem = (total % 1_000_000) as i64;
    let capped = current_units.saturating_add(whole.min(i64::MAX as i128) as i64);
    if capped >= capacity {
        // Saturated storage discards production and the remainder.
        (capacity, 0)
    } else {
        (capped, rem)
    }
}

/// Duration (in seconds) after applying a speedup, rounded up but never below zero.
pub fn apply_speedup(remaining_secs: i64, speedup_secs: i64) -> i64 {
    (remaining_secs - speedup_secs).max(0)
}

/// Linear helper: cost of `count` units at a per-unit integer cost.
pub fn total_cost(per_unit: i64, count: u32) -> Option<i64> {
    per_unit.checked_mul(count as i64)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn exact_boundary_no_fraction_loss() {
        // 3600 scaled production/hour => 3600/1000 = 3.6 units/hour => 1 unit/1000s.
        let (v, r) = accrue(0, 0, 3600, 1000, 1_000_000);
        assert_eq!(v, 1);
        assert_eq!(r, 0);
    }

    #[test]
    fn fractional_remainder_is_persisted_and_resumes() {
        let (v1, r1) = accrue(0, 0, 3600, 500, 1_000_000);
        assert_eq!(v1, 0);
        assert!(r1 > 0);
        let (v2, _r2) = accrue(v1, r1, 3600, 500, 1_000_000);
        assert_eq!(v2, 1);
    }

    #[test]
    fn polling_frequency_does_not_change_result() {
        let (a, ar) = accrue(0, 0, 5000, 3600, 10_000_000);
        let mut v = 0;
        let mut r = 0;
        for _ in 0..3600 {
            let (nv, nr) = accrue(v, r, 5000, 1, 10_000_000);
            v = nv;
            r = nr;
        }
        assert_eq!((a, ar), (v, r));
    }

    #[test]
    fn capacity_saturates_and_discards_surplus() {
        let (v, r) = accrue(90, 0, 1_000_000, 3600, 100);
        assert_eq!(v, 100);
        assert_eq!(r, 0);
    }

    proptest::proptest! {
        #[test]
        fn accrual_never_negative_or_above_capacity(cur in 0i64..1000, rem in 0i64..1_000_000, prod in 0i64..100_000, secs in 0i64..100_000, cap in 500i64..2000) {
            let (v, r) = accrue(cur, rem, prod, secs, cap);
            assert!(v >= 0 && v <= cap);
            assert!((0..1_000_000).contains(&r));
        }
    }
}
