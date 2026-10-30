use crate::lexer::{Token, TokenType};
use crate::ast::Expr;

pub struct ExprParser {
    tokens: Vec<Token>,
    pos: usize,
}

impl ExprParser {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self { tokens, pos: 0 }
    }

    pub fn parse(&mut self) -> Result<Expr, String> {
        self.parse_add()
    }

    fn peek(&self) -> &Token { &self.tokens[self.pos] }

    fn next(&mut self) -> Token {
        let t = self.tokens[self.pos].clone();
        if self.pos < self.tokens.len() - 1 { self.pos += 1; }
        t
    }

    fn parse_add(&mut self) -> Result<Expr, String> {
        let mut lhs = self.parse_mul()?;
        while matches!(self.peek().kind, TokenType::Plus | TokenType::Minus) {
            let op = if self.next().kind == TokenType::Plus { '+' } else { '-' };
            let rhs = self.parse_mul()?;
            lhs = Expr::Bin { op, lhs: Box::new(lhs), rhs: Box::new(rhs) };
        }
        Ok(lhs)
    }

    fn parse_mul(&mut self) -> Result<Expr, String> {
        let mut lhs = self.parse_prim()?;
        while matches!(self.peek().kind, TokenType::Star | TokenType::Slash) {
            let op = if self.next().kind == TokenType::Star { '*' } else { '/' };
            let rhs = self.parse_prim()?;
            lhs = Expr::Bin { op, lhs: Box::new(lhs), rhs: Box::new(rhs) };
        }
        Ok(lhs)
    }

    fn parse_prim(&mut self) -> Result<Expr, String> {
        let t = self.next();
        match t.kind {
            TokenType::Number => Ok(Expr::Number(t.value.parse().map_err(|e| format!("{e}"))?)),
            TokenType::Ident => Ok(Expr::VarRef(t.value)),
            TokenType::LParen => {
                let e = self.parse()?;
                self.next();
                Ok(e)
            }
            other => Err(format!("Parse error at {other:?}")),
        }
    }
}

pub fn emit_cpp(expr: &Expr) -> String {
    match expr {
        Expr::Number(n) => n.to_string(),
        Expr::VarRef(v) => v.clone(),
        Expr::Bin { op, lhs, rhs } => format!("({} {} {})", emit_cpp(lhs), op, emit_cpp(rhs)),
    }
}
