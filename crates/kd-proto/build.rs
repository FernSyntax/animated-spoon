use std::path::PathBuf;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let manifest = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR")?);
    let repo = manifest.parent().unwrap().parent().unwrap();
    let proto = repo.join("proto").join("kd.proto");
    let out = PathBuf::from(std::env::var("OUT_DIR")?);

    println!("cargo:rerun-if-changed={}", proto.display());
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .compile_protos(&[proto], &[repo.join("proto")])?;

    // Keep generated files available for inspection/reproducibility under target/gen.
    let _ = out;
    Ok(())
}
