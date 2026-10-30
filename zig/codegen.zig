const std = @import("std");
const parser = @import("parser.zig");

fn type_to_cpp(t: parser.Type) []const u8 {
    return switch (t) {
        .I32 => "int32_t",
        .I64 => "int64_t",
        .F64 => "double",
        .Bool => "bool",
        .Str => "std::string",
        .Void => "void",
    };
}

fn emit_expr(out: *std.ArrayList(u8), e: *parser.Expr) !void {
    switch (e.*) {
        .number => |n| try out.writer().print("{d}", .{n}),
        .string => |s| try out.writer().print("\"{s}\"", .{s}),
        .var_ref => |v| try out.writer().print("{s}", .{v}),
        .bin => |b| {
            try out.append('(');
            try emit_expr(out, b.lhs);
            try out.appendSlice(" + ");
            try emit_expr(out, b.rhs);
            try out.append(')');
        },
        .call => |c| {
            try out.writer().print("{s}(", .{c.name});
            for (c.args, 0..) |a, i| {
                if (i > 0) try out.appendSlice(", ");
                try emit_expr(out, a);
            }
            try out.append(')');
        },
    }
}

fn emit_stmt(out: *std.ArrayList(u8), s: parser.Stmt) !void {
    switch (s) {
        .let_decl => |d| {
            try out.writer().print("  {s} {s} = ", .{ type_to_cpp(d.ty), d.name });
            try emit_expr(out, d.value);
            try out.appendSlice(";\n");
        },
        .return_stmt => |r| {
            try out.appendSlice("  return");
            if (r) |e| {
                try out.append(' ');
                try emit_expr(out, e);
            }
            try out.appendSlice(";\n");
        },
        .print => |e| {
            try out.appendSlice("  std::cout << ");
            try emit_expr(out, e);
            try out.appendSlice(" << std::endl;\n");
        },
        .expr => |e| {
            try out.appendSlice("  ");
            try emit_expr(out, e);
            try out.appendSlice(";\n");
        },
    }
}

pub fn generate(allocator: std.mem.Allocator, prog: parser.Program) ![]u8 {
    var out = std.ArrayList(u8).init(allocator);
    errdefer out.deinit();

    try out.appendSlice("#include <iostream>\n#include <string>\n#include <cstdint>\n\n");

    for (prog.functions) |f| {
        try out.writer().print("{s} {s}() {{\n", .{ type_to_cpp(f.ret), f.name });
        for (f.body) |s| try emit_stmt(&out, s);
        try out.appendSlice("}\n\n");
    }

    return out.toOwnedSlice();
}
