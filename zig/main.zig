const std = @import("std");
const ep = @import("expr_parser.zig");

pub fn main(init: std.process.Init) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try init.minimal.args.toSlice(allocator);
    defer allocator.free(args);

    if (args.len < 2) {
        std.debug.print("Usage: zephyr-zig <expr>\n", .{});
        std.process.exit(1);
    }

    // Простой пример: парсим выражение "1 + 2 * 3"
    const tokens = [_]ep.Token{
        .{ .type = .Number, .value = "1" },
        .{ .type = .Plus, .value = "+" },
        .{ .type = .Number, .value = "2" },
        .{ .type = .Star, .value = "*" },
        .{ .type = .Number, .value = "3" },
        .{ .type = .Eof, .value = "" },
    };

    var parser = ep.Parser.init(allocator, &tokens);
    const expr = try parser.parse();
    const cpp = try ep.emit_cpp(allocator, expr);
    defer allocator.free(cpp);

    std.debug.print("C++: {s}\n", .{cpp});
}const std = @import("std");
const ep = @import("expr_parser.zig");

pub fn main(init: std.process.Init) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try init.minimal.args.toSlice(allocator);
    defer allocator.free(args);

    if (args.len < 2) {
        std.debug.print("Usage: zephyr-zig <expr>\n", .{});
        std.process.exit(1);
    }

    // Простой пример: парсим выражение "1 + 2 * 3"
    const tokens = [_]ep.Token{
        .{ .type = .Number, .value = "1" },
        .{ .type = .Plus, .value = "+" },
        .{ .type = .Number, .value = "2" },
        .{ .type = .Star, .value = "*" },
        .{ .type = .Number, .value = "3" },
        .{ .type = .Eof, .value = "" },
    };

    var parser = ep.Parser.init(allocator, &tokens);
    const expr = try parser.parse();
    const cpp = try ep.emit_cpp(allocator, expr);
    defer allocator.free(cpp);

    std.debug.print("C++: {s}\n", .{cpp});
}
