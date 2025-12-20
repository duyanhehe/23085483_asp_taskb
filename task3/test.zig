const std = @import("std");

const Fiber = @import("fiber.zig").Fiber;
const Scheduler = @import("scheduler.zig").Scheduler;
const yield = @import("scheduler.zig").yield;

// global scheduler
var s: Scheduler = undefined;

// fiber 1
fn f1() noreturn {
    const dp = s.get_data().?;
    std.debug.print("fiber 1 before: {d}\n", .{dp.*});
    dp.* += 1;
    yield();
    std.debug.print("fiber 1 after: {d}\n", .{dp.*});
    s.fiber_exit();
}

// fiber 2
fn f2() noreturn {
    const dp = s.get_data().?;
    std.debug.print("fiber 2: {d}\n", .{dp.*});
    s.fiber_exit();
}

test "task3 fiber with yield" {
    const alloc = std.testing.allocator;

    s = Scheduler.init(alloc);
    @import("scheduler.zig").SCHED = &s;

    var d: i32 = 10;
    const dp: *i32 = &d;

    var fib1 = try Fiber.init(alloc, f1, dp);
    var fib2 = try Fiber.init(alloc, f2, dp);

    defer {
        fib1.deinit(alloc);
        fib2.deinit(alloc);
        s.deinit();
    }

    // call s method spawn with address of f1
    s.spawn(&fib1);
    s.spawn(&fib2);

    s.do_it();

    // optional correctness check
    try std.testing.expectEqual(@as(i32, 11), d);
}
