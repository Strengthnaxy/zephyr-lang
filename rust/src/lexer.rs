#[derive(Debug, Clone, PartialEq)]
pub enum TokenType {
    Ident, Number, String,
    Fn, Let, Var, Return, If, Else, While,
    LParen, RParen, LBrace, RBrace,
    Colon, Semicolon, Arrow,
    Plus, Minus, Star, Slash,
    Assign, EqEq, BangEq, Lt, Gt, Le, Ge,
    Eof,
}

#[derive(Debug, Clone)]
pub struct Token {
    pub kind: TokenType,
    pub value: String,
}

pub struct Lexer<'a> {
    src: &'a [u8],
    pos: usize,
}

impl<'a> Lexer<'a> {
    pub fn new(src: &'a str) -> Self {
        Self { src: src.as_bytes(), pos: 0 }
    }

    fn peek(&self) -> Option<u8> { self.src.get(self.pos).copied() }

    fn advance(&mut self) -> Option<u8> {
        let c = self.peek()?;
        self.pos += 1;
        Some(c)
    }

    pub fn tokenize(mut self) -> Result<Vec<Token>, String> {
        let mut out = Vec::new();
        while let Some(c) = self.peek() {
            if c.is_ascii_whitespace() { self.advance(); continue; }
            if c == b'/' && self.src.get(self.pos + 1) == Some(&b'/') {
                while let Some(ch) = self.advance() {
                    if ch == b'\n' { break; }
                }
                continue;
            }
            if c.is_ascii_alphabetic() || c == b'_' {
                let start = self.pos;
                while let Some(ch) = self.peek() {
                    if !ch.is_ascii_alphanumeric() && ch != b'_' { break; }
                    self.advance();
                }
                let word = std::str::from_utf8(&self.src[start..self.pos]).unwrap();
                let kind = match word {
                    "fn" => TokenType::Fn,
                    "let" => TokenType::Let,
                    "var" => TokenType::Var,
                    "return" => TokenType::Return,
                    "if" => TokenType::If,
                    "else" => TokenType::Else,
                    "while" => TokenType::While,
                    _ => TokenType::Ident,
                };
                out.push(Token { kind, value: word.to_string() });
                continue;
            }
            if c.is_ascii_digit() {
                let start = self.pos;
                while let Some(ch) = self.peek() {
                    if !ch.is_ascii_digit() { break; }
                    self.advance();
                }
                out.push(Token {
                    kind: TokenType::Number,
                    value: std::str::from_utf8(&self.src[start..self.pos]).unwrap().to_string(),
                });
                continue;
            }
            if c == b'"' {
                self.advance();
                let start = self.pos;
                while let Some(ch) = self.peek() {
                    if ch == b'"' { break; }
                    self.advance();
                }
                let s = std::str::from_utf8(&self.src[start..self.pos]).unwrap().to_string();
                self.advance();
                out.push(Token { kind: TokenType::String, value: s });
                continue;
            }
            let ch = self.advance().unwrap();
            let kind = match ch {
                b'(' => TokenType::LParen,
                b')' => TokenType::RParen,
                b'{' => TokenType::LBrace,
                b'}' => TokenType::RBrace,
                b':' => TokenType::Colon,
                b';' => TokenType::Semicolon,
                b'+' => TokenType::Plus,
                b'-' => TokenType::Minus,
                b'*' => TokenType::Star,
                b'/' => TokenType::Slash,
                b'=' => TokenType::Assign,
                _ => return Err(format!("Unknown char: {}", ch as char)),
            };
            out.push(Token { kind, value: (ch as char).to_string() });
        }
        out.push(Token { kind: TokenType::Eof, value: String::new() });
        Ok(out)
    }
}
