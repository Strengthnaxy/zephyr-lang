const std = @import("std");

pub const TokenType = enum {
    Ident, Number, String,
    Fn, Let, Var, Return,
    LParen, RParen, LBrace, RBrace,
    Colon, Semicolon, Arrow,
    Plus, Minus, Star, Slash,
    Assign,
    Eof,
};

pub const Token = struct {
    type: TokenType,
    value: []const u8,
};

pub const Lexer = struct {
    allocator: std.mem.Allocator,
    source: []const u8,
    pos: usize = 0,

    pub fn init(allocator: std.mem.Allocator, source: []const u8) Lexer {
        return .{ .allocator = allocator, .source = source };
    }

    fn peek(self: *Lexer) ?u8 {
        if (self.pos >= self.source.len) return null;
        return self.source[self.pos];
    }

    fn advance(self: *Lexer) ?u8 {
        const c = self.peek() orelse return null;
        self.pos += 1;
        return c;
    }

    pub fn tokenize(self: *Lexer) ![]Token {
        var tokens = std.ArrayList(Token).empty;
        errdefer tokens.deinit(self.allocator);

        while (true) {
            const c = self.peek() orelse break;

            if (std.ascii.isWhitespace(c)) {
                _ = self.advance();
                continue;
            }

            if (c == '/' and self.pos + 1 < self.source.len and self.source[self.pos + 1] == '/') {
                while (self.peek()) |ch| {
                    if (ch == '\n') break;
                    _ = self.advance();
                }
                continue;
            }

            if (std.ascii.isAlphabetic(c) or c == '_') {
                const start = self.pos;
                while (self.peek()) |ch| {
                    if (!std.ascii.isAlphanumeric(ch) and ch != '_') break;
                    _ = self.advance();
                }
                const word = self.source[start..self.pos];
                const tt: TokenType = if (std.mem.eql(u8, word, "fn")) .Fn
                    else if (std.mem.eql(u8, word, "let")) .Let
                    else if (std.mem.eql(u8, word, "var")) .Var
                    else if (std.mem.eql(u8, word, "return")) .Return
                    else .Ident;
                try tokens.append(self.allocator, .{ .type = tt, .value = word });
                continue;
            }

            if (std.ascii.isDigit(c)) {
                const start = self.pos;
                while (self.peek()) |ch| {
                    if (!std.ascii.isDigit(ch)) break;
                    _ = self.advance();
                }
                try tokens.append(self.allocator, .{ .type = .Number, .value = self.source[start..self.pos] });
                continue;
            }

            if (c == '"') {
                _ = self.advance();
                const start = self.pos;
                while (self.peek()) |ch| {
                    if (ch == '"') break;
                    _ = self.advance();
                }
                const s = self.source[start..self.pos];
                _ = self.advance();
                try tokens.append(self.allocator, .{ .type = .String, .value = s });
                continue;
            }

            _ = self.advance();
            const tt: TokenType = switch (c) {
                '(' => .LParen, ')' => .RParen,
                '{' => .LBrace, '}' => .RBrace,
                ':' => .Colon, ';' => .Semicolon,
                '+' => .Plus, '-' => blk: {
                    if (self.peek() == '>') {
                        _ = self.advance();
                        break :blk .Arrow;
                    }
                    break :blk .Minus;
                },
                '*' => .Star, '/' => .Slash,
                '=' => .Assign,
                else => {
                    std.debug.print("Unknown char: {c}\n", .{c});
                    return error.LexError;
                },
            };
            try tokens.append(self.allocator, .{ .type = tt, .value = self.source[self.pos - 1 .. self.pos] });
        }

        try tokens.append(self.allocator, .{ .type = .Eof, .value = "" });
        return tokens.toOwnedSlice(self.allocator);
    }
};
