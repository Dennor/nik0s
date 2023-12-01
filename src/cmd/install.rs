use crate::cluster::Cluster;
use crate::cmd::Error;
use std::process::Command;
use tempfile::tempdir;

fn validateNodeName(cluster: &Cluster, node: &str) -> Result<(), Error> {
    let parts: Vec<&str> = node.split('.').collect();
    let invalid_node_name_err = || Error::InvalidNodeName(node.to_string());
    let cluster_name = parts.get(2).ok_or_else(invalid_node_name_err)?;
    let pool_name = parts.get(1).ok_or_else(invalid_node_name_err)?;
    let node_name = parts.get(0).ok_or_else(invalid_node_name_err)?;
    if *cluster_name != cluster.name
        && cluster
            .pools()
            .get(*pool_name)
            .map(|p| p.nodes.get(*node_name))
            .is_some()
    {
        Ok(())
    } else {
        Err(invalid_node_name_err())
    }
}

pub fn install_cluster_node(
    cluster: &Cluster,
    node: &str,
    script: Option<String>,
) -> Result<(), Error> {
    let tmpdir = tempdir()?;
    Command::new("").args(["/C", "echo hello"]).output()?;
    print!("{:?}", cluster);
    print!("{:?}", node);
    Ok(())
}

pub fn install_cluster_pool(cluster: &Cluster, pool: &str) -> Result<(), String> {
    print!("{:?}", cluster);
    print!("{:?}", cluster.pools());
    print!("{:?}", pool);
    Ok(())
}

pub fn install_cluster(cluster: &Cluster) -> Result<(), String> {
    print!("{:?}", cluster);
    Ok(())
}
