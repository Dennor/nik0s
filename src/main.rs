use clap::Parser;
use nik0s::cluster::Cluster;
use nik0s::cmd::*;
fn main() {
    let cluster = Cluster::new();
    let args = Cli::parse();
    match args.command {
        Commands::Install(install) => {
            let install_cmd = install.command.unwrap_or(InstallCommands::Cluster);
            match install_cmd {
                InstallCommands::Cluster => install_cluster(&cluster).unwrap(),
                InstallCommands::Pool { pool } => install_cluster_pool(&cluster, &pool).unwrap(),
                InstallCommands::Node { node } => {
                    install_cluster_node(&cluster, &node, None).unwrap()
                }
            }
        }
    }
}
