#[derive(Debug, Clone)]
pub enum Expr {
    Number(i64),
    VarRef(String),
    Bin { op: char, lhs: Box<Expr>, rhs: Box<Expr> },
}
