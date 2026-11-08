const std = @import("std");

// Target list: statically linked Linux binaries (musl) for x86, x86_64, and aarch64.
const targets = [_]std.Target.Query{
    .{ .cpu_arch = .x86, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .musl },
};

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    // Build one executable per target and install all of them in zig-out/bin.
    // Output names follow the pattern: hello-<arch>-<os>
    for (targets) |query| {
        const resolved = b.resolveTargetQuery(query);
        const arch = @tagName(resolved.result.cpu.arch);
        const os = @tagName(resolved.result.os.tag);

        const exe = b.addExecutable(.{
            .name = b.fmt("hello-{s}-{s}", .{ arch, os }),
            .root_source_file = b.path("src/main.zig"),
            .target = resolved,
            .optimize = optimize,
        });

        b.installArtifact(exe);
    }
}
