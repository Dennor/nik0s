use clap::Parser;
use nik0s::cluster::Cluster;
use nik0s::cmd::*;
use nik0s::flake::Flake;
fn main() {
    let args = Cli::parse();
    match args.command {
        Commands::Install(install) => {
            let install_cmd = install.command.unwrap();
            let install = InstallCMD {
                cluster: Cluster::new(),
                flake: Flake::new(),
                user_flake: "".to_string(),
                controller_script: None,
                worker_script: None,
                user: None,
            };
            match install_cmd {
                InstallCommands::Cluster { flake } => install.cluster(&flake).unwrap(),
                InstallCommands::Pool { flake, pool } => install.pool(&flake, &pool).unwrap(),
                InstallCommands::Node { flake, pool, node } => {
                    install.node(&flake, &pool, &node).unwrap()
                }
                InstallCommands::NixosConfiguration {
                    nixos_configuration,
                    target,
                } => install
                    .nixos_configuration(&nixos_configuration, &target)
                    .unwrap(),
            }
        }
    }
}
