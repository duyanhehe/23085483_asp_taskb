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

    // Create run steps for each program
    const run_task1a = b.addRunArtifact(exe_task1a);
    const run_task1a_step = b.step("run-task1a", "Run task1a");
    run_task1a_step.dependOn(&run_task1a.step);
}
