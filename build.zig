const std = @import("std");

// Builds a single hello-world executable for the target given by -Dtarget.
// The full target matrix is driven by scripts/build-os.sh and the GitHub
// Actions workflow, so that each combination can fail independently.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Output names follow the pattern: hello-<arch>-<os>
    // (Windows targets get the .exe suffix automatically.)
    const arch = @tagName(target.result.cpu.arch);
    const os = @tagName(target.result.os.tag);

    const exe = b.addExecutable(.{
        .name = b.fmt("hello-{s}-{s}", .{ arch, os }),
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
}
