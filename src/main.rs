use clap::{Parser, Subcommand};
use clap_complete::{Shell, generate};
use self_update;
use std::io;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Says hello
    Say {
        /// The name to say hello to
        #[arg(short, long)]
        name: Option<String>,
    },
    /// Generate shell completions
    Generate {
        /// The shell to generate for
        #[arg(value_enum)]
        shell: Shell,
    },
    /// Update the CLI to the latest version
    Update,
}

fn main() {
    let cli = Cli::parse();

    // Check for updates in the background
    check_for_updates();

    match &cli.command {
        Commands::Say { name } => {
            let name = name.as_deref().unwrap_or("World");
            println!("Hello, {}!", name);
        }
        Commands::Generate { shell } => {
            generate_completions(*shell);
        }
        Commands::Update => {
            if let Err(e) = update() {
                println!("Error updating: {}", e);
            }
        }
    }
}

fn generate_completions(shell: Shell) {
    let mut cmd = <Cli as clap::CommandFactory>::command();
    let cmd_name = cmd.get_name().to_string();
    generate(shell, &mut cmd, cmd_name, &mut io::stdout());
}

fn check_for_updates() {
    std::thread::spawn(move || {
        if let Ok(status) = self_update::backends::github::Update::configure()
            .repo_owner("justin")
            .repo_name("jj")
            .bin_name("jj")
            .current_version(self_update::cargo_crate_version!())
            .build()
        {
            if let Ok(status) = status.update_extended() {
                if status.updated() {
                    println!("A new version is available! Run `jj update` to install it.");
                }
            }
        }
    });
}

fn update() -> Result<(), Box<dyn ::std::error::Error>> {
    let status = self_update::backends::github::Update::configure()
        .repo_owner("justindotpub")
        .repo_name("jj")
        .bin_name("jj")
        .show_download_progress(true)
        .current_version(self_update::cargo_crate_version!())
        .build()?
        .update()?;
    println!("Update status: `{}`!", status.version());
    Ok(())
}
