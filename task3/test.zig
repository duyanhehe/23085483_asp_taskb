const std = @import("std");

const Fiber = @import("fiber.zig").Fiber;
const Scheduler = @import("scheduler.zig").Scheduler;
const yield = @import("scheduler.zig").yield;

// global scheduler
var s: Scheduler = undefined;

// func f1
fn f1() noreturn {
    const dp = s.get_data().?;
    // output "fiber 1 before"
    std.debug.print("fiber 1 before: {d}\n", .{dp.*});
    // increment shared data
    dp.* += 1;
    // call yield
    yield();
    // output "fiber 1 after"
    std.debug.print("fiber 1 after: {d}\n", .{dp.*});
    // call fiber_exit
    s.fiber_exit();
}

// func f2
fn f2() noreturn {
    const dp = s.get_data().?;
    // output "fiber 2"
    std.debug.print("fiber 2: {d}\n", .{dp.*});
    // fiber_exit
    s.fiber_exit();
}

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    s = Scheduler.init(alloc);
    @import("scheduler.zig").SCHED = &s;

    var d: i32 = 10;
    const dp: *i32 = &d;

    // set f2 to be fiber with func 2
    var fib2 = try Fiber.init(alloc, f2, dp);
    // set f1 to be fiber with func 1
    var fib1 = try Fiber.init(alloc, f1, dp);

    // call s method spawn with address of f1
    s.spawn(&fib1);
    // call s method spawn with address of f2
    s.spawn(&fib2);

    // call s method do_it
    s.do_it();

    fib1.deinit(alloc);
    fib2.deinit(alloc);
    s.deinit();
}
