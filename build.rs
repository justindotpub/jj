use std::env;
use std::process::Command;

fn main() {
    let pkg_version = env::var("CARGO_PKG_VERSION").unwrap_or_else(|_| "0.0.0".into());
    let is_preview = env::var("JJ_PREVIEW").ok().filter(|v| v != "0" && !v.is_empty()).is_some();

    // Prefer CI-provided SHA, else try git, else unknown
    let sha = env::var("GITHUB_SHA")
        .ok()
        .map(|s| s.chars().take(7).collect::<String>())
        .or_else(|| short_git_sha().ok())
        .unwrap_or_else(|| "unknown".into());

    let version = if is_preview {
        format!("{}-preview+{}", pkg_version, sha)
    } else {
        pkg_version
    };

    println!("cargo:rustc-env=JJ_VERSION={}", version);
}

fn short_git_sha() -> Result<String, Box<dyn std::error::Error>> {
    let output = Command::new("git")
        .args(["rev-parse", "--short", "HEAD"]) 
        .output()?;
    if output.status.success() {
        Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
    } else {
        Err("git not available".into())
    }
}

