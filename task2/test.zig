const std = @import("std");

const Fiber = @import("fiber.zig").Fiber;
const Scheduler = @import("scheduler.zig").Scheduler;

//  global scheduler
var s: Scheduler = undefined;

// func func1
fn func1() noreturn {
    // output "fiber 1"
    // std.debug.print("fiber 1\n", .{});
    // set dp to get_data
    const dp = s.get_data().?;
    // output "fiber 1: " *dp
    std.debug.print("fiber 1: {d}\n", .{dp.*});
    // set *dp to *dp PLUS 1
    dp.* += 1;
    // call fiber exit
    s.fiber_exit();
}

// func func2
fn func2() noreturn {
    // set dp to get_data
    const dp = s.get_data().?;
    // output "fiber 2: " *dp
    std.debug.print("fiber 2: {d}\n", .{dp.*});
    // call fiber exit
    s.fiber_exit();
}

// func main:
pub fn main() !void {
    const alloc = std.heap.page_allocator;

    // global s is set to scheduler
    s = Scheduler.init(alloc);

    // set d to 10
    var d: i32 = 10;
    // set dp to address of d
    const dp: *i32 = &d;
    // set f2 to be fiber with func2, dp
    var f2 = try Fiber.init(alloc, func2, dp);
    // set f1 to be fiber with func1, dp
    var f1 = try Fiber.init(alloc, func1, dp);

    // call s method spawn with address of f1
    s.spawn(&f1);
    // call s method spawn with address of f2
    s.spawn(&f2);

    // call s method do_it
    s.do_it();

    // cleanup
    f1.deinit(alloc);
    f2.deinit(alloc);
    s.deinit();
}
