macro_rules! eq_tests {
    ($suite:ident, $($name:ident: $a:expr, $b:expr,)*) => {
        mod $suite {
            use super::*;
            use pretty_assertions::assert_eq;
            $(
                #[test]
                fn $name() {
                    assert_eq!($a, $b);
                }
            )*
        }
    }
}
pub(crate) use eq_tests;
