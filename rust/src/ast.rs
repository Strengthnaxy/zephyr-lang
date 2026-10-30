#[derive(Debug, Clone)]
pub enum Expr {
    Number(i64),
    VarRef(String),
    Bin { op: char, lhs: Box<Expr>, rhs: Box<Expr> },
}

#[derive(Debug, Clone)]
pub enum Stmt {
    Let { name: String, ty: String, value: Expr, mutable: bool },
    Return(Option<Expr>),
    Print(Expr),
}

#[derive(Debug, Clone)]
pub struct Function {
    pub name: String,
    pub params: Vec<(String, String)>,
    pub ret: String,
    pub body: Vec<Stmt>,
}

#[derive(Debug, Clone)]
pub struct Program {
    pub functions: Vec<Function>,
}
