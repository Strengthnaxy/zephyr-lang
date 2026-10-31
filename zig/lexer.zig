pub const TokenType = enum { number, ident, plus, minus, star, slash, lparen, rparen, eof };
pub const Token = struct { type: TokenType, value: []const u8 };
