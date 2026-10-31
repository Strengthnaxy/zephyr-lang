pub const Expr = union(enum) {
    number: i64,
    var_ref: []const u8,
    bin: struct { op: u8, lhs: *Expr, rhs: *Expr },
};
