const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const qemu_tracer = b.addModule("qemu-tracer", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addLibrary(.{ .name = "qemu_tracer", .linkage = .dynamic, .root_module = qemu_tracer });
    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/root.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "qemu-tracer", .module = qemu_tracer },
            },
        }),
    });
    const run_tests = b.addRunArtifact(tests);
    const install_lib = b.addInstallArtifact(lib, .{});
    install_lib.step.dependOn(&run_tests.step);
    b.getInstallStep().dependOn(&install_lib.step);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
