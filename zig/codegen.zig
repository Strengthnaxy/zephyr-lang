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

fn emit_expr(out: *std.Io.Writer.Allocating, e: *parser.Expr) !void {
    switch (e.*) {
        .number => |n| try out.writer.print("{d}", .{n}),
        .string => |s| try out.writer.print("\"{s}\"", .{s}),
        .var_ref => |v| try out.writer.print("{s}", .{v}),
        .bin => |b| {
            try out.writer.writeByte('(');
            try emit_expr(out, b.lhs);
            try out.writer.writeAll(" + ");
            try emit_expr(out, b.rhs);
            try out.writer.writeByte(')');
        },
        .call => |c| {
            try out.writer.print("{s}(", .{c.name});
            for (c.args, 0..) |a, i| {
                if (i > 0) try out.writer.writeAll(", ");
                try emit_expr(out, a);
            }
            try out.writer.writeByte(')');
        },
    }
}

fn emit_stmt(out: *std.Io.Writer.Allocating, s: parser.Stmt) !void {
    switch (s) {
        .let_decl => |d| {
            try out.writer.print("  {s} {s} = ", .{ type_to_cpp(d.ty), d.name });
            try emit_expr(out, d.value);
            try out.writer.writeAll(";\n");
        },
        .return_stmt => |r| {
            try out.writer.writeAll("  return");
            if (r) |e| {
                try out.writer.writeByte(' ');
                try emit_expr(out, e);
            }
            try out.writer.writeAll(";\n");
        },
        .print => |e| {
            try out.writer.writeAll("  std::cout << ");
            try emit_expr(out, e);
            try out.writer.writeAll(" << std::endl;\n");
        },
        .expr => |e| {
            try out.writer.writeAll("  ");
            try emit_expr(out, e);
            try out.writer.writeAll(";\n");
        },
    }
}

pub fn generate(allocator: std.mem.Allocator, prog: parser.Program) ![]u8 {
    var out: std.Io.Writer.Allocating = .init(allocator);
    errdefer out.deinit();

    try out.writer.writeAll("#include <iostream>\n#include <string>\n#include <cstdint>\n\n");

    for (prog.functions) |f| {
        try out.writer.print("{s} {s}() {{\n", .{ type_to_cpp(f.ret), f.name });
        for (f.body) |s| try emit_stmt(&out, s);
        try out.writer.writeAll("}\n\n");
    }

    return out.toOwnedSlice();
}
