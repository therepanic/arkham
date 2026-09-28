const std = @import("std");
const translate_c = @import("translate_c");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const translate_c_dep = b.dependency("translate_c", .{});
    const translated: translate_c.Translator = .init(translate_c_dep, .{
        .c_source_file = b.path("../../include/c.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_system_libs = &.{
            .{
                .name = "glib-2.0",
                .options = .{
                    .use_pkg_config = .yes,
                },
            },
        },
    });
    translated.addSystemIncludePath(b.path("../../include"));

    const qemu_tracer = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "c",
                .module = translated.mod,
            },
        },
    });

    const lib = b.addLibrary(.{
        .name = "qemu_tracer",
        .linkage = .dynamic,
        .root_module = qemu_tracer,
    });

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/root.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{
                    .name = "qemu-tracer",
                    .module = qemu_tracer,
                },
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
