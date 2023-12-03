use std::io;

#[derive(Debug)]
pub struct IoError(io::Error);

#[derive(PartialEq, Debug)]
pub enum Error {
    IoError(IoError),
    InvalidNixosConfiguration(String),
    InvalidNodeName(String),
    InvalidPoolName(String),
    AddressNotFound(String, String),
}

impl From<io::Error> for Error {
    fn from(error: io::Error) -> Self {
        Error::IoError(IoError(error))
    }
}

impl PartialEq for IoError {
    fn eq(&self, other: &Self) -> bool {
        self.0.to_string() == other.0.to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::test::eq_tests;
    eq_tests!(io_error_partial_eq,
        equal_by_message:
            true,
            IoError(io::Error::new(io::ErrorKind::Other, "somerr"))
                .eq(&IoError(io::Error::new(io::ErrorKind::Other, "somerr"))),
        not_equal_by_message:
            false,
            IoError(io::Error::new(io::ErrorKind::Other, "someerr"))
                .eq(&IoError(io::Error::new(io::ErrorKind::Other, "someothererr"))),
    );
    eq_tests!(io_error_converts,
        from_io:
            Error::IoError(IoError(io::Error::new(io::ErrorKind::Other, "someerr"))),
            Error::from(io::Error::new(io::ErrorKind::Other, "someerr")),
    );
}
