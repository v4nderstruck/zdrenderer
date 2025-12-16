const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vkBootstrap = b.addModule("vkBootstrap", .{
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    vkBootstrap.addCSourceFiles(.{
        .files = &.{
            "VkBootstrap.cpp",
        },
        .flags = &.{
            "-std=c++17",
            "-Wall",
            "-Wextra",
        },
        .root = b.path("cpp/vkBootstrap"),
    });

    const exe = b.addExecutable(.{
        .name = "zdrenderer",
        .root_module = b.createModule(
            .{
                .root_source_file = b.path("src/main.zig"),
                .target = target,
                .optimize = optimize,
                .link_libcpp = true,
            },
        ),
    });

    exe.root_module.linkSystemLibrary("SDL3", .{ .preferred_link_mode = .static });
    exe.root_module.linkSystemLibrary("vulkan", .{ .preferred_link_mode = .dynamic });
    exe.root_module.addImport("vkBootstrap", vkBootstrap);
    exe.root_module.addLibraryPath(b.path("thirdparty/install/lib/"));
    exe.root_module.addIncludePath(b.path("thirdparty/install/include/"));
    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
