const std = @import("std");

pub const Expr = union(enum) {
    number: i64,
    var_ref: []const u8,
    bin: struct { op: u8, lhs: *Expr, rhs: *Expr },
};

pub const TokenType = enum { Number, Ident, Plus, Minus, Star, Slash, LParen, RParen, Eof };
pub const Token = struct { type: TokenType, value: []const u8 };

pub const Parser = struct {
    allocator: std.mem.Allocator,
    tokens: []const Token,
    pos: usize = 0,

    pub fn init(allocator: std.mem.Allocator, tokens: []const Token) Parser {
        return .{ .allocator = allocator, .tokens = tokens };
    }

    fn peek(self: *Parser) Token { return self.tokens[self.pos]; }
    fn next(self: *Parser) Token {
        const t = self.tokens[self.pos];
        if (self.pos < self.tokens.len - 1) self.pos += 1;
        return t;
    }

    pub fn parse(self: *Parser) !*Expr { return self.parse_add(); }

    fn parse_add(self: *Parser) !*Expr {
        var lhs = try self.parse_mul();
        while (self.peek().type == .Plus or self.peek().type == .Minus) {
            const op = self.next().type;
            const rhs = try self.parse_mul();
            const e = try self.allocator.create(Expr);
            e.* = .{ .bin = .{ .op = if (op == .Plus) '+' else '-', .lhs = lhs, .rhs = rhs } };
            lhs = e;
        }
        return lhs;
    }

    fn parse_mul(self: *Parser) !*Expr {
        var lhs = try self.parse_prim();
        while (self.peek().type == .Star or self.peek().type == .Slash) {
            const op = self.next().type;
            const rhs = try self.parse_prim();
            const e = try self.allocator.create(Expr);
            e.* = .{ .bin = .{ .op = if (op == .Star) '*' else '/', .lhs = lhs, .rhs = rhs } };
            lhs = e;
        }
        return lhs;
    }

    fn parse_prim(self: *Parser) !*Expr {
        const t = self.next();
        switch (t.type) {
            .Number => {
                const e = try self.allocator.create(Expr);
                e.* = .{ .number = try std.fmt.parseInt(i64, t.value, 10) };
                return e;
            },
            .Ident => {
                const e = try self.allocator.create(Expr);
                e.* = .{ .var_ref = t.value };
                return e;
            },
            .LParen => {
                const e = try self.parse();
                _ = self.next();
                return e;
            },
            else => return error.ParseError,
        }
    }
};

pub fn emit_cpp(allocator: std.mem.Allocator, e: *Expr) ![]u8 {
    var out: std.Io.Writer.Allocating = .init(allocator);
    errdefer out.deinit();
    try emit_into(&out, e);
    return out.toOwnedSlice();
}

fn emit_into(out: *std.Io.Writer.Allocating, e: *Expr) !void {
    switch (e.*) {
        .number => |n| try out.writer.print("{d}", .{n}),
        .var_ref => |v| try out.writer.print("{s}", .{v}),
        .bin => |b| {
            try out.writer.writeByte('(');
            try emit_into(out, b.lhs);
            try out.writer.print(" {c} ", .{b.op});
            try emit_into(out, b.rhs);
            try out.writer.writeByte(')');
        },
    }
}
