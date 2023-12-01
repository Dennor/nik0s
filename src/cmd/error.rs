use std::io;

#[derive(Debug)]
pub enum Error {
    IoError(io::Error),
    InvalidNodeName(String),
}

impl From<io::Error> for Error {
    fn from(error: io::Error) -> Self {
        Error::IoError(error)
    }
}
