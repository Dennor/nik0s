mod error;
mod install;
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
#[command(args_conflicts_with_subcommands = true)]
#[command(flatten_help = true)]
pub struct InstallArgs {
    #[command(subcommand)]
    pub command: Option<InstallCommands>,

    #[command(flatten)]
    pub cluster: ClusterArgs,
}

#[derive(Debug, Subcommand)]
pub enum InstallCommands {
    /// Install whole cluster.
    Cluster,
    /// Install a pool.
    #[command(arg_required_else_help = true)]
    Pool { pool: String },
    /// Install a node.
    #[command(arg_required_else_help = true)]
    Node { node: String },
}

#[derive(Debug, Subcommand)]
pub enum Commands {
    /// Install commands. By default install whole cluster. Warning, this destroys existing data on
    /// targets.
    Install(InstallArgs),
}
