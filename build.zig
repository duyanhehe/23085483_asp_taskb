const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create root module for task1a
    const module_task1a = b.addModule("task1a", .{
        .root_source_file = b.path("task1/task1a/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create executable for task1a
    const exe_task1a = b.addExecutable(.{
        .name = "task1a",
        .root_module = module_task1a,
    });

    // Link with the context library
    exe_task1a.linkLibC();
    exe_task1a.addObjectFile(b.path("lib/libcontext.a"));
    exe_task1a.addIncludePath(b.path("lib"));

    b.installArtifact(exe_task1a);

    // Create root module for task1b
    const module_task1b = b.addModule("task1b", .{
        .root_source_file = b.path("task1/task1b/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create executable for task1b
    const exe_task1b = b.addExecutable(.{
        .name = "task1b",
        .root_module = module_task1b,
    });

    // Link with the context library
    exe_task1b.linkLibC();
    exe_task1b.addObjectFile(b.path("lib/libcontext.a"));
    exe_task1b.addIncludePath(b.path("lib"));

    b.installArtifact(exe_task1b);

    // Create root module for task1c
    const module_task1c = b.addModule("task1c", .{
        .root_source_file = b.path("task1/task1c/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create executable for task1b
    const exe_task1c = b.addExecutable(.{
        .name = "task1c",
        .root_module = module_task1c,
    });

    // Link with the context library
    exe_task1c.linkLibC();
    exe_task1c.addObjectFile(b.path("lib/libcontext.a"));
    exe_task1c.addIncludePath(b.path("lib"));

    b.installArtifact(exe_task1c);

    // Create run steps for each program
    const run_task1a = b.addRunArtifact(exe_task1a);
    const run_task1a_step = b.step("run-task1a", "Run task1a");
    run_task1a_step.dependOn(&run_task1a.step);

    const run_task1b = b.addRunArtifact(exe_task1b);
    const run_task1b_step = b.step("run-task1b", "Run task1b");
    run_task1b_step.dependOn(&run_task1b.step);

    const run_task1c = b.addRunArtifact(exe_task1c);
    const run_task1c_step = b.step("run-task1c", "Run task1c");
    run_task1c_step.dependOn(&run_task1c.step);
}
