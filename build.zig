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

    // Create executable for task1c
    const exe_task1c = b.addExecutable(.{
        .name = "task1c",
        .root_module = module_task1c,
    });

    // Link with the context library
    exe_task1c.linkLibC();
    exe_task1c.addObjectFile(b.path("lib/libcontext.a"));
    exe_task1c.addIncludePath(b.path("lib"));

    b.installArtifact(exe_task1c);

    // Create run steps for task 1a, 1b, 1c
    const run_task1a = b.addRunArtifact(exe_task1a);
    const run_task1a_step = b.step("run-task1a", "Run task1a");
    run_task1a_step.dependOn(&run_task1a.step);

    const run_task1b = b.addRunArtifact(exe_task1b);
    const run_task1b_step = b.step("run-task1b", "Run task1b");
    run_task1b_step.dependOn(&run_task1b.step);

    const run_task1c = b.addRunArtifact(exe_task1c);
    const run_task1c_step = b.step("run-task1c", "Run task1c");
    run_task1c_step.dependOn(&run_task1c.step);

    // Create root module for task2
    const module_task2 = b.addModule("task2", .{
        .root_source_file = b.path("task2/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create executable for task2
    const exe_task2 = b.addExecutable(.{
        .name = "task2",
        .root_module = module_task2,
    });

    // Link with the context library
    exe_task2.linkLibC();
    exe_task2.addObjectFile(b.path("lib/libcontext.a"));
    exe_task2.addIncludePath(b.path("lib"));

    b.installArtifact(exe_task2);

    // Create root module for task2 test
    const module_task2_test = b.addModule("task2test", .{
        .root_source_file = b.path("task2/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create executable for task2 test
    const exe_task2_test = b.addExecutable(.{
        .name = "task2test",
        .root_module = module_task2_test,
    });

    // Link with the context library
    exe_task2_test.linkLibC();
    exe_task2_test.addObjectFile(b.path("lib/libcontext.a"));
    exe_task2_test.addIncludePath(b.path("lib"));

    b.installArtifact(exe_task2_test);

    // Create run step for task2
    const run_task2 = b.addRunArtifact(exe_task2);
    const run_task2_step = b.step("run-task2", "Run task2");
    run_task2_step.dependOn(&run_task2.step);

    const run_task2_test = b.addRunArtifact(exe_task2_test);
    const run_task2_test_step = b.step("test-task2", "Test task2");
    run_task2_test_step.dependOn(&run_task2_test.step);
}
