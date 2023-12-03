mod error;
mod install;
use std::net::IpAddr;

use clap::{Args, Parser, Subcommand};
pub use error::*;
pub use install::*;

#[derive(Debug, Parser)]
#[command(name = "nik0s")]
#[command(about = "nik0s cluster kit helper", long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Debug, Args)]
pub struct ClusterArgs {}

#[derive(Debug, Args)]
#[command(arg_required_else_help = true)]
#[command(flatten_help = true)]
pub struct InstallArgs {
    #[command(subcommand)]
    pub command: Option<InstallCommands>,
}

#[derive(Debug, Subcommand)]
pub enum InstallCommands {
    /// Install whole cluster.
    Cluster { flake: String },
    /// Install a pool.
    #[command(arg_required_else_help = true)]
    Pool { flake: String, pool: String },
    /// Install a node.
    #[command(arg_required_else_help = true)]
    Node {
        flake: String,
        pool: String,
        node: String,
    },
    /// Install a specific configuration from a flake.
    #[command(arg_required_else_help = true)]
    NixosConfiguration {
        nixos_configuration: String,
        target: IpAddr,
    },
}

#[derive(Debug, Subcommand)]
pub enum Commands {
    /// Install commands. Warning, commands here destroy existing data on
    /// targets.
    Install(InstallArgs),
}
