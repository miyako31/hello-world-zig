const std = @import("std");

pub fn main() !void {
    // Write "Hello, World!" to standard output.
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, World!\n", .{});
}
