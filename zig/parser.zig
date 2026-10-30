const std = @import("std");
const lexer = @import("lexer.zig");

pub const Type = enum { I32, I64, F64, Bool, Str, Void };

pub const Expr = union(enum) {
    number: i64,
    string: []const u8,
    var_ref: []const u8,
    bin: struct { op: u8, lhs: *Expr, rhs: *Expr },
    call: struct { name: []const u8, args: []*Expr },
};

pub const Stmt = union(enum) {
    let_decl: struct { name: []const u8, ty: Type, value: *Expr, mutable: bool },
    return_stmt: ?*Expr,
    print: *Expr,
    expr: *Expr,
};

pub const Function = struct {
    name: []const u8,
    params: []Param,
    ret: Type,
    body: []Stmt,
};

pub const Param = struct { name: []const u8, ty: Type };

pub const Program = struct {
    functions: []Function,

    pub fn deinit(self: *Program, allocator: std.mem.Allocator) void {
        _ = self;
        _ = allocator;
    }
};

pub const Parser = struct {
    allocator: std.mem.Allocator,
    tokens: []lexer.Token,
    pos: usize = 0,

    pub fn init(allocator: std.mem.Allocator, tokens: []lexer.Token) Parser {
        return .{ .allocator = allocator, .tokens = tokens };
    }

    fn peek(self: *Parser) lexer.Token {
        return self.tokens[self.pos];
    }

    fn next(self: *Parser) lexer.Token {
        const t = self.tokens[self.pos];
        if (self.pos < self.tokens.len - 1) self.pos += 1;
        return t;
    }

    fn expect(self: *Parser, tt: lexer.TokenType) !lexer.Token {
        const t = self.next();
        if (t.type != tt) {
            std.debug.print("Expected {any}, got {any}\n", .{ tt, t.type });
            return error.ParseError;
        }
        return t;
    }

    fn parse_type(self: *Parser) !Type {
        const t = self.next();
        if (t.type != .Ident) return error.ParseError;
        if (std.mem.eql(u8, t.value, "i32")) return .I32;
        if (std.mem.eql(u8, t.value, "i64")) return .I64;
        if (std.mem.eql(u8, t.value, "f64")) return .F64;
        if (std.mem.eql(u8, t.value, "bool")) return .Bool;
        if (std.mem.eql(u8, t.value, "string")) return .Str;
        if (std.mem.eql(u8, t.value, "void")) return .Void;
        return error.ParseError;
    }

    fn parse_expr(self: *Parser) !*Expr {
        const expr = try self.allocator.create(Expr);
        const t = self.next();
        switch (t.type) {
            .Number => {
                const v = try std.fmt.parseInt(i64, t.value, 10);
                expr.* = .{ .number = v };
            },
            .String => {
                expr.* = .{ .string = t.value };
            },
            .Ident => {
                expr.* = .{ .var_ref = t.value };
            },
            else => return error.ParseError,
        }

        if (self.peek().type == .Plus) {
            _ = self.next();
            const rhs = try self.parse_expr();
            const bin = try self.allocator.create(Expr);
            bin.* = .{ .bin = .{ .op = '+', .lhs = expr, .rhs = rhs } };
            return bin;
        }
        return expr;
    }

    fn parse_stmt(self: *Parser) !Stmt {
        const t = self.peek();
        if (t.type == .Let or t.type == .Var) {
            const kw = self.next();
            const mutable = kw.type == .Var;
            const name = (try self.expect(.Ident)).value;
            _ = try self.expect(.Colon);
            const ty = try self.parse_type();
            const value = try self.parse_expr();
            _ = try self.expect(.Semicolon);
            return .{ .let_decl = .{ .name = name, .ty = ty, .value = value, .mutable = mutable } };
        }
        if (t.type == .Return) {
            _ = self.next();
            if (self.peek().type == .Semicolon) {
                _ = self.next();
                return .{ .return_stmt = null };
            }
            const e = try self.parse_expr();
            _ = try self.expect(.Semicolon);
            return .{ .return_stmt = e };
        }
        if (t.type == .Ident and std.mem.eql(u8, t.value, "print")) {
            _ = self.next();
            _ = try self.expect(.LParen);
            const e = try self.parse_expr();
            _ = try self.expect(.RParen);
            _ = try self.expect(.Semicolon);
            return .{ .print = e };
        }
        const e = try self.parse_expr();
        _ = try self.expect(.Semicolon);
        return .{ .expr = e };
    }

    fn parse_fn(self: *Parser) !Function {
        _ = try self.expect(.Fn);
        const name = (try self.expect(.Ident)).value;
        _ = try self.expect(.LParen);
        _ = try self.expect(.RParen);
        _ = try self.expect(.Arrow);
        const ret = try self.parse_type();
        _ = try self.expect(.LBrace);

        var body = std.ArrayList(Stmt).init(self.allocator);
        while (self.peek().type != .RBrace and self.peek().type != .Eof) {
            try body.append(try self.parse_stmt());
        }
        _ = try self.expect(.RBrace);

        return .{
            .name = name,
            .params = &.{},
            .ret = ret,
            .body = try body.toOwnedSlice(),
        };
    }

    pub fn parse(self: *Parser) !Program {
        var fns = std.ArrayList(Function).init(self.allocator);
        while (self.peek().type != .Eof) {
            try fns.append(try self.parse_fn());
        }
        return .{ .functions = try fns.toOwnedSlice() };
    }
};
