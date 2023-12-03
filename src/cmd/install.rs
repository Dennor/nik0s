use crate::cluster::Cluster;
use crate::cmd::Error;
use crate::flake::Flake;
use std::net::IpAddr;
use std::process::Command;
use tempfile::tempdir;

pub struct InstallCMD {
    pub cluster: Cluster,
    pub flake: Flake,
    pub user_flake: String,
    pub worker_script: Option<String>,
    pub controller_script: Option<String>,
    pub user: Option<String>,
}

fn split_nixos_configuration(nixos_configuration: &str) -> Result<(&str, &str, &str, &str), Error> {
    let [flake, node_fqdn] = nixos_configuration
        .split('#')
        .collect::<Vec<&str>>()
        .try_into()
        .map_err(|_| Error::InvalidNixosConfiguration(nixos_configuration.to_string()))?;
    let [node_name, pool_name, cluster_name] = node_fqdn
        .split('.')
        .collect::<Vec<&str>>()
        .try_into()
        .map_err(|_| Error::InvalidNixosConfiguration(nixos_configuration.to_string()))?;
    Ok((flake, node_name, pool_name, cluster_name))
}

fn new_install_target(user: &str, target: &IpAddr) -> String {
    let addr = target.to_string();
    let mut install_target = String::with_capacity(user.len() + addr.len() + 1);
    install_target.push_str(user);
    install_target.push_str("@");
    install_target.push_str(addr.as_str());
    install_target
}

impl InstallCMD {
    fn get_script(&self, nixos_configuration: &str) -> Result<Option<&str>, Error> {
        let (_, _, pool_name, _) = split_nixos_configuration(nixos_configuration)?;
        Ok(self
            .cluster
            .pools
            .get(pool_name)
            .and_then(|pool| match pool.kind.as_str() {
                "controller" => self.controller_script.as_ref().map(|s| s.as_str()),
                _ => self.worker_script.as_ref().map(|s| s.as_str()),
            }))
    }
    fn validate_nixos_configuration(&self, nixos_configuration: &str) -> Result<(), Error> {
        let (_, node_name, pool_name, cluster_name) =
            split_nixos_configuration(nixos_configuration)?;
        match cluster_name != self.cluster.name
            && self
                .cluster
                .pools
                .get(pool_name)
                .map(|p| p.nodes.get(node_name))
                .is_some()
        {
            true => Ok(()),
            _ => Err(Error::InvalidNodeName(nixos_configuration.to_string())),
        }
    }

    pub fn nixos_configuration(
        &self,
        nixos_configuration: &str,
        target: &IpAddr,
    ) -> Result<(), Error> {
        self.validate_nixos_configuration(nixos_configuration)?;
        let tmpdir = tempdir()?;
        let tmpdir_path = tmpdir.path().to_str().unwrap();
        let user = self.user.as_ref().map(|s| s.as_str()).unwrap_or("root");
        let install_target = new_install_target(user, target);
        let mut args = [
            "run",
            "github:numtide/nixos-anywhere",
            "--",
            "--flake",
            nixos_configuration,
            install_target.as_str(),
        ]
        .to_vec();
        let script = self.get_script(nixos_configuration)?;
        match script {
            Some(script) => {
                let mut extra_files = ["--extra-files", tmpdir_path].to_vec();
                args.append(&mut extra_files);
                Command::new(script).current_dir(tmpdir.path()).spawn()?;
            }
            _ => {}
        }
        Command::new("nix").args(args).spawn()?;
        Ok(())
    }
    pub fn node(&self, flake: &str, pool_name: &str, node_name: &str) -> Result<(), Error> {
        let public_addr = self
            .cluster
            .pools
            .get(pool_name)
            .and_then(|p| p.nodes.get(node_name))
            .map(|node| &node.network.public)
            .and_then(|p| p.ipv4.as_ref().or(p.ipv6.as_ref()))
            .and_then(|iface| iface.addresses.get(0))
            .ok_or_else(|| Error::AddressNotFound(pool_name.to_string(), node_name.to_string()))?;
        let mut nixos_configuration = String::with_capacity(
            flake.len() + self.cluster.name.len() + pool_name.len() + node_name.len() + 3,
        );
        nixos_configuration.push_str(flake);
        nixos_configuration.push_str("#");
        nixos_configuration.push_str(node_name);
        nixos_configuration.push_str(".");
        nixos_configuration.push_str(pool_name);
        nixos_configuration.push_str(".");
        nixos_configuration.push_str(&self.cluster.name);
        self.nixos_configuration(nixos_configuration.as_str(), &public_addr.address)
    }

    pub fn pool(&self, flake: &str, pool_name: &str) -> Result<(), Error> {
        let pool = self
            .cluster
            .pools
            .get(pool_name)
            .ok_or_else(|| Error::InvalidPoolName(pool_name.to_string()))?;
        for node in pool.nodes.keys() {
            self.node(flake, pool_name, node)?;
        }
        Ok(())
    }

    pub fn cluster(&self, flake: &str) -> Result<(), Error> {
        for pool in self.cluster.pools.keys() {
            self.pool(flake, pool)?;
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::test::eq_tests;
    eq_tests!(split_nixos_configuration_string,
        splits_configuration:
            Ok(("flake", "node", "pool", "cluster")),
            split_nixos_configuration("flake#node.pool.cluster"),
        requires_flake:
            Err(Error::InvalidNixosConfiguration("node.pool.cluster".to_string())),
            split_nixos_configuration("node.pool.cluster"),
        requires_node_fqdn:
            Err(Error::InvalidNixosConfiguration("flake#not-a-node-fqdn".to_string())),
            split_nixos_configuration("flake#not-a-node-fqdn"),
    );
}
