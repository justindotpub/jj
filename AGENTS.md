# Repository Guidelines

## Project Structure & Module Organization
- Source: `src/main.rs` (single-binary CLI using `clap`).
- Package metadata: `Cargo.toml`; lockfile: `Cargo.lock`.
- Generated build artifacts: `target/` (ignored from commits).
- Shell completions: generated via `jj generate <shell>`

## Build, Test, and Development Commands
- Build: `cargo build` (add `--release` for optimized binary in `target/release/jj`).
- Run: `cargo run -- <args>` (e.g., `cargo run -- say --name Alice`).
- Test: `cargo test` (add tests under `src/` with `#[cfg(test)]` or `tests/`).
- Format: `cargo fmt --all` (check mode: `cargo fmt --all -- --check`).
- Lint: `cargo clippy -- -D warnings` (keep warnings at zero).

## Coding Style & Naming Conventions
- Rust edition: 2024; follow standard Rust style.
- Indentation: 4 spaces, no tabs; line width ~100.
- Naming: types/traits `PascalCase`, functions/modules/files `snake_case`, constants `SCREAMING_SNAKE_CASE`.
- Keep `main.rs` thin; move logic into functions to enable unit tests.

## Testing Guidelines
- Prefer unit tests near code (`#[cfg(test)] mod tests { ... }`).
- Use integration tests in `tests/` for CLI behaviors.
- Aim for meaningful coverage of command parsing and update paths.
- Run `cargo test` locally before pushing.

## Commit & Pull Request Guidelines
- Commits: clear, imperative subject (e.g., "add say subcommand help").
- Optional scope: `feat(cli): ...`, `fix(update): ...` is welcome but not required.
- PRs: include description, rationale, screenshots/terminal output when UX changes.
- Ensure `cargo fmt`, `clippy`, and tests pass; link related issues.

## Releases & CI
- GitHub Actions builds release binaries on tags matching `v*`.
- Cut a release by tagging: `git tag vX.Y.Z && git push origin vX.Y.Z`.
- The `self_update` backend targets `justindotpub/jj`; verify binaries after release.

## Security & Configuration Tips
- Do not commit secrets; CI uses `GITHUB_TOKEN` only.
- When modifying auto-update logic, prefer HTTPS and pinned repo/owner.
