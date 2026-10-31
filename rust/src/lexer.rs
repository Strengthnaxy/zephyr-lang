#[derive(Debug, Clone, PartialEq)]
pub enum TokenType { Number, Ident, Plus, Minus, Star, Slash, LParen, RParen, Eof }

#[derive(Debug, Clone)]
pub struct Token { pub kind: TokenType, pub value: String }
