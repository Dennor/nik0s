use serde::{Deserialize, Serialize};
use std::cmp::Ordering;
use std::collections::HashMap;
use std::net::IpAddr;

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CA {
    pub key: String,
    pub crt: String,
}

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Master {
    pub ca: HashMap<String, CA>,
}

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Address {
    pub address: IpAddr,
    pub prefix_length: u8,
}

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Route {
    pub address: IpAddr,
    pub prefix_length: u8,
    pub via: Option<IpAddr>,
}

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct IFaceIPConfig {
    pub addresses: Vec<Address>,
    pub routes: Vec<Route>,
}

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct IFace {
    pub dhcp: Option<bool>,
    pub ipv4: Option<IFaceIPConfig>,
    pub ipv6: Option<IFaceIPConfig>,
    pub link: String,
    pub vlan: Option<u16>,
}

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Network {
    pub public: IFace,
    pub private: Option<IFace>,
}

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
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

impl PartialOrd for Node {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for Node {
    fn cmp(&self, other: &Self) -> Ordering {
        match (self.is_master(), other.is_master()) {
            (true, false) => Ordering::Greater,
            (false, true) => Ordering::Less,
            _ => Ordering::Equal,
        }
    }
}

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Pool {
    pub kind: String,
    pub nodes: HashMap<String, Node>,
}

impl Pool {
    pub fn master(&self) -> Option<&Node> {
        self.nodes.values().find(|el| el.is_master())
    }
    pub fn node_names(&self) -> Vec<String> {
        let mut keys = self.nodes.keys().cloned().collect::<Vec<String>>();
        keys.sort_by(|a, b| -> Ordering {
            // Flipped compare to get node names in descending order
            self.nodes.get(b).unwrap().cmp(self.nodes.get(a).unwrap())
        });
        keys
    }
}

impl PartialOrd for Pool {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for Pool {
    fn cmp(&self, other: &Self) -> Ordering {
        match (
            self.master().is_some(),
            other.master().is_some(),
            self.kind.as_str(),
            other.kind.as_str(),
        ) {
            (true, false, _, _) => Ordering::Greater,
            (false, true, _, _) => Ordering::Less,
            (_, _, "controller", "worker") => Ordering::Greater,
            (_, _, "worker", "controller") => Ordering::Less,
            _ => Ordering::Equal,
        }
    }
}

#[derive(Eq, PartialEq, Debug, Serialize, Deserialize)]
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
    pub fn pool_names(&self) -> Vec<String> {
        let mut keys = self.pools.keys().cloned().collect::<Vec<String>>();
        keys.sort_by(|a, b| -> Ordering {
            // Flipped compare to get pool names in descending order
            self.pools.get(b).unwrap().cmp(self.pools.get(a).unwrap())
        });
        keys
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::test::eq_tests;
    use std::collections::HashMap;
    use std::net::{IpAddr, Ipv4Addr};
    eq_tests!(cluster_new,
        cluster_new:
            Cluster {
                api_host: IpAddr::V4(Ipv4Addr::new(1, 1, 1, 1)),
                api_port: 6443,
                name: "test-cluster".to_string(),
                pools: HashMap::from([
                    ("workers-0".to_string(), Pool {
                        kind: "worker".to_string(),
                        nodes: HashMap::from([
                            ("worker-2".to_string(), Node {
                                join_token: Some("/run/secrets/jointoken".to_string()),
                                master: None,
                                labels: Some(HashMap::from([
                                    ("openebs.io/engine".to_string(), "mayastor".to_string()),
                                ])),
                                network: Network {
                                    public: IFace {
                                        dhcp: None,
                                        ipv4: Some(IFaceIPConfig {
                                            addresses: vec![
                                                Address {
                                                    address: IpAddr::V4(Ipv4Addr::new(4, 4, 4, 4)),
                                                    prefix_length: 32,
                                                 },
                                            ],
                                            routes: vec![
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(172, 31, 1, 1)),
                                                    prefix_length: 32,
                                                    via: None,
                                                },
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0)),
                                                    prefix_length: 0,
                                                    via: Some(IpAddr::V4(Ipv4Addr::new(172, 31, 1, 1))),
                                                },
                                            ],
                                        }),
                                        ipv6: Some(IFaceIPConfig {
                                            addresses: vec![],
                                            routes: vec![],
                                         }),
                                        link: "enp1s0".to_string(),
                                        vlan: None,
                                    },
                                    private: Some(IFace {
                                        dhcp: None,
                                        ipv4: Some(IFaceIPConfig {
                                            addresses: vec![
                                                Address {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 5)),
                                                    prefix_length: 32,
                                                },
                                            ],
                                            routes: vec![
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 1)),
                                                    prefix_length: 32,
                                                    via: None,
                                                },
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 0)),
                                                    prefix_length: 8,
                                                    via: Some(IpAddr::V4(Ipv4Addr::new(10, 0, 0, 1))),
                                                 },
                                            ],
                                        }),
                                        ipv6: Some(IFaceIPConfig {
                                            addresses: vec![],
                                            routes: vec![],
                                        }),
                                        link: "enp2s0".to_string(),
                                        vlan: None,
                                    }),
                                },
                             }),
                            ("worker-0".to_string(), Node {
                                join_token: Some("/run/secrets/jointoken".to_string()),
                                master: None,
                                labels: Some(HashMap::from([
                                    ("openebs.io/engine".to_string(), "mayastor".to_string()),
                                ])),
                                network: Network {
                                    public: IFace {
                                        dhcp: None,
                                        ipv4: Some(IFaceIPConfig {
                                            addresses: vec![
                                                Address {
                                                    address: IpAddr::V4(Ipv4Addr::new(2, 2, 2, 2)),
                                                    prefix_length: 32,
                                                 },
                                            ],
                                            routes: vec![
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(172, 31, 1, 1)),
                                                    prefix_length: 32,
                                                    via: None,
                                                },
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0)),
                                                    prefix_length: 0,
                                                    via: Some(IpAddr::V4(Ipv4Addr::new(172, 31, 1, 1))),
                                                },
                                            ],
                                        }),
                                        ipv6: Some(IFaceIPConfig {
                                            addresses: vec![],
                                            routes: vec![],
                                         }),
                                        link: "enp1s0".to_string(),
                                        vlan: None,
                                    },
                                    private: Some(IFace {
                                        dhcp: None,
                                        ipv4: Some(IFaceIPConfig {
                                            addresses: vec![
                                                Address {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 3)),
                                                    prefix_length: 32,
                                                },
                                            ],
                                            routes: vec![
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 1)),
                                                    prefix_length: 32,
                                                    via: None,
                                                },
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 0)),
                                                    prefix_length: 8,
                                                    via: Some(IpAddr::V4(Ipv4Addr::new(10, 0, 0, 1))),
                                                 },
                                            ],
                                        }),
                                        ipv6: Some(IFaceIPConfig {
                                            addresses: vec![],
                                            routes: vec![],
                                        }),
                                        link: "enp2s0".to_string(),
                                        vlan: None,
                                    }),
                                },
                             }),
                            ("worker-1".to_string(), Node {
                                join_token: Some("/run/secrets/jointoken".to_string()),
                                master: None,
                                labels: Some(HashMap::from([
                                    ("openebs.io/engine".to_string(), "mayastor".to_string()),
                                ])),
                                network: Network {
                                    public: IFace {
                                        dhcp: None,
                                        ipv4: Some(IFaceIPConfig {
                                            addresses: vec![
                                                Address {
                                                    address: IpAddr::V4(Ipv4Addr::new(3, 3, 3, 3)),
                                                    prefix_length: 32,
                                                 },
                                            ],
                                            routes: vec![
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(172, 31, 1, 1)),
                                                    prefix_length: 32,
                                                    via: None,
                                                },
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0)),
                                                    prefix_length: 0,
                                                    via: Some(IpAddr::V4(Ipv4Addr::new(172, 31, 1, 1))),
                                                },
                                            ],
                                        }),
                                        ipv6: Some(IFaceIPConfig {
                                            addresses: vec![],
                                            routes: vec![],
                                         }),
                                        link: "enp1s0".to_string(),
                                        vlan: None,
                                    },
                                    private: Some(IFace {
                                        dhcp: None,
                                        ipv4: Some(IFaceIPConfig {
                                            addresses: vec![
                                                Address {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 4)),
                                                    prefix_length: 32,
                                                },
                                            ],
                                            routes: vec![
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 1)),
                                                    prefix_length: 32,
                                                    via: None,
                                                },
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 0)),
                                                    prefix_length: 8,
                                                    via: Some(IpAddr::V4(Ipv4Addr::new(10, 0, 0, 1))),
                                                 },
                                            ],
                                        }),
                                        ipv6: Some(IFaceIPConfig {
                                            addresses: vec![],
                                            routes: vec![],
                                        }),
                                        link: "enp2s0".to_string(),
                                        vlan: None,
                                    }),
                                },
                             }),
                        ]),
                    }),
                    ("controllers-0".to_string(), Pool {
                        kind: "controller".to_string(),
                        nodes: HashMap::from([
                            ("controller-0".to_string(), Node {
                                join_token: None,
                                master: Some(Master{
                                    ca: HashMap::from([
                                        ("/var/lib/k0s/pki/ca".to_string(), CA{
                                            key: "/run/secrets/ca.key".to_string(),
                                            crt: "/run/secrets/ca.crt".to_string(),
                                        }),
                                    ]),
                                }),
                                labels: Some(HashMap::new()),
                                network: Network {
                                    public: IFace {
                                        dhcp: None,
                                        ipv4: Some(IFaceIPConfig {
                                            addresses: vec![
                                                Address {
                                                    address: IpAddr::V4(Ipv4Addr::new(1, 1, 1, 1)),
                                                    prefix_length: 32,
                                                 },
                                            ],
                                            routes: vec![
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(172, 31, 1, 1)),
                                                    prefix_length: 32,
                                                    via: None,
                                                },
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0)),
                                                    prefix_length: 0,
                                                    via: Some(IpAddr::V4(Ipv4Addr::new(172, 31, 1, 1))),
                                                },
                                            ],
                                        }),
                                        ipv6: Some(IFaceIPConfig {
                                            addresses: vec![],
                                            routes: vec![],
                                         }),
                                        link: "enp1s0".to_string(),
                                        vlan: None,
                                    },
                                    private: Some(IFace {
                                        dhcp: None,
                                        ipv4: Some(IFaceIPConfig {
                                            addresses: vec![
                                                Address {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 2)),
                                                    prefix_length: 32,
                                                },
                                            ],
                                            routes: vec![
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 1)),
                                                    prefix_length: 32,
                                                    via: None,
                                                },
                                                Route {
                                                    address: IpAddr::V4(Ipv4Addr::new(10, 0, 0, 0)),
                                                    prefix_length: 8,
                                                    via: Some(IpAddr::V4(Ipv4Addr::new(10, 0, 0, 1))),
                                                 },
                                            ],
                                        }),
                                        ipv6: Some(IFaceIPConfig {
                                            addresses: vec![],
                                            routes: vec![],
                                        }),
                                        link: "enp2s0".to_string(),
                                        vlan: None,
                                    }),
                                },
                             }),
                        ]),
                    }),
                ]),
            },
            Cluster::new(),
    );
    eq_tests!(cluster_pool_names,
        returns_pool_names_with_hierarchy_order:
            vec!["master_pool", "controller_pool", "worker_pool"],
            Cluster {
                api_host: IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)),
                api_port: 0,
                name: "".to_string(),
                pools: HashMap::from([
                    ("worker_pool".to_string(), Pool{
                        kind: "worker".to_string(),
                        nodes: HashMap::new(),
                    }),
                    ("master_pool".to_string(), Pool{
                        kind: "controller".to_string(),
                        nodes: HashMap::from([
                            ("master_node".to_string(), Node{
                                master: Some(Master{
                                    ca: HashMap::new(),
                                }),
                                join_token: None,
                                labels: None,
                                network: Network {
                                    public: IFace {
                                        dhcp: None,
                                        ipv4: None,
                                        ipv6: None,
                                        link: "".to_string(),
                                        vlan: None,
                                     },
                                    private: None,
                                },
                            }),
                        ]),
                    }),
                    ("controller_pool".to_string(), Pool{
                        kind: "controller".to_string(),
                        nodes: HashMap::new(),
                    }),
                ]),
            }.pool_names(),
    );
    eq_tests!(pool_node_names,
        returns_node_names_with_hierarchy_order:
            vec!["master_node", "other_node"],
            Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("other_node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                    ("master_node".to_string(), Node{
                        master: Some(Master{
                            ca: HashMap::new(),
                        }),
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }.node_names(),
    );
    eq_tests!(node_partial_ord,
        partial_ord_nodes:
            Some(Ordering::Less),
            Node{
                master: None,
                join_token: None,
                labels: None,
                network: Network {
                    public: IFace {
                        dhcp: None,
                        ipv4: None,
                        ipv6: None,
                        link: "".to_string(),
                        vlan: None,
                     },
                    private: None,
                },
            }.partial_cmp(
            &Node{
                master: Some(Master{
                    ca: HashMap::new(),
                }),
                join_token: None,
                labels: None,
                network: Network {
                    public: IFace {
                        dhcp: None,
                        ipv4: None,
                        ipv6: None,
                        link: "".to_string(),
                        vlan: None,
                     },
                    private: None,
                },
            }),
    );
    eq_tests!(node_ord,
        node_ord_right_master:
            Ordering::Less,
            Node{
                master: None,
                join_token: None,
                labels: None,
                network: Network {
                    public: IFace {
                        dhcp: None,
                        ipv4: None,
                        ipv6: None,
                        link: "".to_string(),
                        vlan: None,
                     },
                    private: None,
                },
            }.cmp(
            &Node{
                master: Some(Master{
                    ca: HashMap::new(),
                }),
                join_token: None,
                labels: None,
                network: Network {
                    public: IFace {
                        dhcp: None,
                        ipv4: None,
                        ipv6: None,
                        link: "".to_string(),
                        vlan: None,
                     },
                    private: None,
                },
            }),
        node_ord_left_master:
            Ordering::Greater,
            Node{
                master: Some(Master{
                    ca: HashMap::new(),
                }),
                join_token: None,
                labels: None,
                network: Network {
                    public: IFace {
                        dhcp: None,
                        ipv4: None,
                        ipv6: None,
                        link: "".to_string(),
                        vlan: None,
                     },
                    private: None,
                },
            }.cmp(
            &Node{
                master: None,
                join_token: None,
                labels: None,
                network: Network {
                    public: IFace {
                        dhcp: None,
                        ipv4: None,
                        ipv6: None,
                        link: "".to_string(),
                        vlan: None,
                     },
                    private: None,
                },
            }),
        node_ord_regular:
            Ordering::Equal,
            Node{
                master: None,
                join_token: None,
                labels: None,
                network: Network {
                    public: IFace {
                        dhcp: None,
                        ipv4: None,
                        ipv6: None,
                        link: "".to_string(),
                        vlan: None,
                     },
                    private: None,
                },
            }.cmp(
            &Node{
                master: None,
                join_token: None,
                labels: None,
                network: Network {
                    public: IFace {
                        dhcp: None,
                        ipv4: None,
                        ipv6: None,
                        link: "".to_string(),
                        vlan: None,
                     },
                    private: None,
                },
            }),
    );
    eq_tests!(pool_partial_ord,
        returns_pool_partial_ord:
            Some(Ordering::Greater),
            Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("master_node".to_string(), Node{
                        master: Some(Master{
                            ca: HashMap::new(),
                        }),
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }.partial_cmp(&Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }),

    );
    eq_tests!(pool_ord,
        returns_left_pool_with_master_greater:
            Ordering::Greater,
            Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("master_node".to_string(), Node{
                        master: Some(Master{
                            ca: HashMap::new(),
                        }),
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }.cmp(&Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }),
        returns_right_pool_with_master_less:
            Ordering::Less,
            Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("master_node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }.cmp(&Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("node".to_string(), Node{
                        master: Some(Master{
                            ca: HashMap::new(),
                        }),
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }),
        returns_left_controller_right_worker_greater:
            Ordering::Greater,
            Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("master_node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }.cmp(&Pool {
                kind: "worker".to_string(),
                nodes: HashMap::from([
                    ("node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }),
        returns_left_worker_right_controller_less:
            Ordering::Less,
            Pool {
                kind: "worker".to_string(),
                nodes: HashMap::from([
                    ("master_node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }.cmp(&Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }),
        returns_controllers_equal:
            Ordering::Equal,
            Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("master_node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }.cmp(&Pool {
                kind: "controller".to_string(),
                nodes: HashMap::from([
                    ("node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }),
        returns_workers_equal:
            Ordering::Equal,
            Pool {
                kind: "worker".to_string(),
                nodes: HashMap::from([
                    ("master_node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }.cmp(&Pool {
                kind: "worker".to_string(),
                nodes: HashMap::from([
                    ("node".to_string(), Node{
                        master: None,
                        join_token: None,
                        labels: None,
                        network: Network {
                            public: IFace {
                                dhcp: None,
                                ipv4: None,
                                ipv6: None,
                                link: "".to_string(),
                                vlan: None,
                             },
                            private: None,
                        },
                    }),
                ]),
            }),
    );
}
