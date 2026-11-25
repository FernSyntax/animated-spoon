//! Tracing, Prometheus exporter and OpenTelemetry initialisation for all services.
use tracing_subscriber::{fmt, layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};

/// Initialise tracing for a service, honouring RUST_LOG.
pub fn init(service: &str) {
    let filter =
        EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info,kd=info"));
    let registry = tracing_subscriber::registry()
        .with(filter)
        .with(fmt::layer().with_target(true).with_ansi(false));
    tracing::info!(service, "observability initialised");
    let _ = registry.try_init();
}

/// Prometheus text exposition. Metrics are recorded via the `metrics` facade;
/// the recorder is installed by the binary that needs scraping.
pub fn install_prometheus() -> Option<metrics_exporter_prometheus::PrometheusHandle> {
    static ONCE: std::sync::OnceLock<metrics_exporter_prometheus::PrometheusHandle> =
        std::sync::OnceLock::new();
    ONCE.get_or_init(|| {
        metrics_exporter_prometheus::PrometheusBuilder::new()
            .install_recorder()
            .expect("prometheus recorder")
    })
    .clone()
    .into()
}
