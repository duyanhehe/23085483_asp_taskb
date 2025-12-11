const std = @import("std");
const Fiber = @import("fiber.zig").Fiber;
const Scheduler = @import("scheduler.zig").Scheduler;
const spawn = @import("scheduler.zig").spawn;
const do_it = @import("scheduler.zig").do_it;
const fiber_exit = @import("scheduler.zig").fiber_exit;

var scheduler: Scheduler = undefined;

pub fn foo() noreturn {
    std.debug.print("Foo is running\n", .{});
    fiber_exit();
}

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    scheduler = Scheduler.init(alloc);

    @import("scheduler.zig").SCHED = &scheduler;

    // set f by creating fiber with foo
    var f = try Fiber.init(alloc, foo, null);
    spawn(&f);

    do_it(); // run fiber
}
