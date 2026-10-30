const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const codegen = @import("codegen.zig");

pub fn main(init: std.process.Init) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const io = init.io;

    const args = try init.minimal.args.toSlice(allocator);
    defer allocator.free(args);

    if (args.len < 4) {
        std.debug.print("Usage: zephyr <input.zph> -o <output>\n", .{});
        std.process.exit(1);
    }

    const input_path = args[1];
    const output_base = args[3];

    const cwd = std.Io.Dir.cwd();
    const source = try cwd.readFileAlloc(io, input_path, allocator, .unlimited);
    defer allocator.free(source);

    var lex = lexer.Lexer.init(allocator, source);
    const tokens = lex.tokenize() catch |err| {
        std.debug.print("Lexer error: {}\n", .{err});
        std.process.exit(1);
    };
    defer allocator.free(tokens);

    var par = parser.Parser.init(allocator, tokens);
    const ast = par.parse() catch |err| {
        std.debug.print("Parser error: {}\n", .{err});
        std.process.exit(1);
    };
    defer ast.deinit(allocator);

    const cpp_code = codegen.generate(allocator, ast) catch |err| {
        std.debug.print("Codegen error: {}\n", .{err});
        std.process.exit(1);
    };
    defer allocator.free(cpp_code);

    const cpp_path = try std.fmt.allocPrint(allocator, "{s}.cpp", .{output_base});
    defer allocator.free(cpp_path);

    try cwd.writeFile(io, .{ .sub_path = cpp_path, .data = cpp_code });

    var child = std.process.Child.init(
        &.{ "g++", "-std=c++17", cpp_path, "-o", output_base },
        allocator,
    );
    try child.spawn();
    const term = try child.wait();
    if (term.Exited != 0) {
        std.debug.print("g++ failed with code {}\n", .{term.Exited});
        std.process.exit(1);
    }
}
