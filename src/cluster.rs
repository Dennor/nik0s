use serde::{Deserialize, Serialize};
use std::cmp::Ordering;
use std::collections::HashMap;
use std::net::IpAddr;

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CA {
    pub key: String,
    pub crt: String,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Master {
    pub ca: HashMap<String, CA>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Address {
    pub address: IpAddr,
    pub prefix_length: u8,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Route {
    pub address: IpAddr,
    pub prefix_length: u8,
    pub via: Option<IpAddr>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct IFaceIPConfig {
    pub addresses: Vec<Address>,
    pub routes: Vec<Route>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct IFace {
    pub dhcp: Option<bool>,
    pub ipv4: Option<IFaceIPConfig>,
    pub ipv6: Option<IFaceIPConfig>,
    pub link: String,
    pub vlan: Option<u16>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Network {
    pub public: IFace,
    pub private: Option<IFace>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Node {
    pub join_token: Option<String>,
    pub master: Option<Master>,
    pub labels: Option<HashMap<String, String>>,
    pub network: Network,
}

impl Node {
    pub fn is_master(&self) -> bool {
        self.master.is_some()
    }
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Pool {
    pub kind: String,
    pub join_token: Option<String>,
    pub nodes: HashMap<String, Node>,
}

impl Pool {
    pub fn master(&self) -> Option<&Node> {
        self.nodes.values().find(|el| el.is_master())
    }
    pub fn nodes(&self) -> Vec<String> {
        let mut keys = self.nodes.keys().cloned().collect::<Vec<String>>();
        keys.sort_by(|a, b| -> Ordering {
            if self.nodes.get(a).unwrap().is_master() {
                return Ordering::Greater;
            }
            if self.nodes.get(b).unwrap().is_master() {
                return Ordering::Less;
            }
            Ordering::Equal
        });
        keys
    }
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Cluster {
    pub api_host: IpAddr,
    pub api_port: u16,
    pub name: String,
    pub pools: HashMap<String, Pool>,
}

impl Cluster {
    pub fn new() -> Self {
        serde_json::from_slice(include_bytes!("cluster.json")).unwrap()
    }
    pub fn pools(&self) -> Vec<String> {
        let mut keys = self.pools.keys().cloned().collect::<Vec<String>>();
        keys.sort_by(|a, b| -> Ordering {
            if self.pools.get(a).unwrap().master().is_some() {
                return Ordering::Greater;
            }
            if self.pools.get(b).unwrap().master().is_some() {
                return Ordering::Less;
            }
            if self.pools.get(a).unwrap().kind == self.pools.get(b).unwrap().kind {
                return Ordering::Equal;
            }
            if self.pools.get(a).unwrap().kind == "controller" {
                return Ordering::Greater;
            }
            Ordering::Less
        });
        keys
    }
}
