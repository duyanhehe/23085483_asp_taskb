const std = @import("std");

const Fiber = @import("fiber.zig").Fiber;
const Scheduler = @import("scheduler.zig").Scheduler;

// global scheduler
var s: Scheduler = undefined;

// fiber 1
fn func1() noreturn {
    const dp = s.get_data().?;
    std.debug.print("fiber 1: {d}\n", .{dp.*});
    dp.* += 1;
    s.fiber_exit();
}

// fiber 2
fn func2() noreturn {
    const dp = s.get_data().?;
    std.debug.print("fiber 2: {d}\n", .{dp.*});
    s.fiber_exit();
}

test "task2: scheduler runs fibers without yield" {
    const alloc = std.testing.allocator;

    s = Scheduler.init(alloc);

    var d: i32 = 10;
    const dp: *i32 = &d;

    var f1 = try Fiber.init(alloc, func1, dp);
    var f2 = try Fiber.init(alloc, func2, dp);

    defer {
        f1.deinit(alloc);
        f2.deinit(alloc);
        s.deinit();
    }

    // spawn order defines execution order
    s.spawn(&f1);
    s.spawn(&f2);

    s.do_it();

    try std.testing.expectEqual(@as(i32, 11), d);
}
