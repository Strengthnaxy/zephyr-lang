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

fn emit_expr(out: *std.ArrayList(u8), allocator: std.mem.Allocator, e: *parser.Expr) !void {
    switch (e.*) {
        .number => |n| try out.writer(allocator).print("{d}", .{n}),
        .string => |s| try out.writer(allocator).print("\"{s}\"", .{s}),
        .var_ref => |v| try out.writer(allocator).print("{s}", .{v}),
        .bin => |b| {
            try out.append(allocator, '(');
            try emit_expr(out, allocator, b.lhs);
            try out.appendSlice(allocator, " + ");
            try emit_expr(out, allocator, b.rhs);
            try out.append(allocator, ')');
        },
        .call => |c| {
            try out.writer(allocator).print("{s}(", .{c.name});
            for (c.args, 0..) |a, i| {
                if (i > 0) try out.appendSlice(allocator, ", ");
                try emit_expr(out, allocator, a);
            }
            try out.append(allocator, ')');
        },
    }
}

fn emit_stmt(out: *std.ArrayList(u8), allocator: std.mem.Allocator, s: parser.Stmt) !void {
    switch (s) {
        .let_decl => |d| {
            try out.writer(allocator).print("  {s} {s} = ", .{ type_to_cpp(d.ty), d.name });
            try emit_expr(out, allocator, d.value);
            try out.appendSlice(allocator, ";\n");
        },
        .return_stmt => |r| {
            try out.appendSlice(allocator, "  return");
            if (r) |e| {
                try out.append(allocator, ' ');
                try emit_expr(out, allocator, e);
            }
            try out.appendSlice(allocator, ";\n");
        },
        .print => |e| {
            try out.appendSlice(allocator, "  std::cout << ");
            try emit_expr(out, allocator, e);
            try out.appendSlice(allocator, " << std::endl;\n");
        },
        .expr => |e| {
            try out.appendSlice(allocator, "  ");
            try emit_expr(out, allocator, e);
            try out.appendSlice(allocator, ";\n");
        },
    }
}

pub fn generate(allocator: std.mem.Allocator, prog: parser.Program) ![]u8 {
    var out = std.ArrayList(u8).empty;
    errdefer out.deinit(allocator);

    try out.appendSlice(allocator, "#include <iostream>\n#include <string>\n#include <cstdint>\n\n");

    for (prog.functions) |f| {
        try out.writer(allocator).print("{s} {s}() {{\n", .{ type_to_cpp(f.ret), f.name });
        for (f.body) |s| try emit_stmt(&out, allocator, s);
        try out.appendSlice(allocator, "}\n\n");
    }

    return out.toOwnedSlice(allocator);
}
