use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Locked {
    rev: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Node {
    locked: Option<Locked>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Flake {
    nodes: HashMap<String, Node>,
}
impl Flake {
    pub fn new() -> Self {
        serde_json::from_slice(include_bytes!("../flake.lock")).unwrap()
    }
}
