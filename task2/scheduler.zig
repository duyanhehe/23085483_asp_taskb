const std = @import("std");
const Fiber = @import("fiber.zig").Fiber;
const Context = @import("fiber.zig").Context;

extern fn get_context(c: [*c]Context) i32;
extern fn set_context(c: [*c]Context) void;

// -------------------- Global Scheduler Pointer --------------------
pub var SCHED: *Scheduler = undefined;

// -------------------- Scheduler Class --------------------
pub const Scheduler = struct {
    allocator: std.mem.Allocator,
    fibers_: std.ArrayListUnmanaged(*Fiber),
    context: Context,
    current_: ?*Fiber = null,

    pub fn init(allocator: std.mem.Allocator) Scheduler {
        return Scheduler{
            .allocator = allocator,
            .fibers_ = .{}, // unmanaged arraylist starts empty
            .context = undefined,
            .current_ = null,
        };
    }

    pub fn deinit(self: *Scheduler) void {
        self.fibers_.deinit(self.allocator); // free internal memory
    }

    pub fn spawn(self: *Scheduler, f: *Fiber) void {
        self.fibers_.append(self.allocator, f) catch unreachable;
    }

    // RETURNS pointer passed to fiber OR null
    pub fn get_data(self: *Scheduler) ?*i32 {
        if (self.current_) |fiber| {
            return fiber.data_;
        }
        return null;
    }

    pub fn do_it(self: *Scheduler) void {
        // save current context
        _ = get_context(@ptrCast(&self.context));

        if (self.fibers_.items.len == 0)
            return;

        var f = self.fibers_.orderedRemove(0);
        self.current_ = f;

        const c = f.getContext();
        set_context(c); // jump into fiber
    }

    // Called inside a fiber when it finishes
    pub fn fiber_exit(self: *Scheduler) noreturn {
        self.current_ = null;
        set_context(&self.context);
        unreachable;
    }
};

// -------------------- Global API Functions --------------------
pub fn spawn(f: *Fiber) void {
    SCHED.spawn(f);
}

pub fn do_it() void {
    SCHED.do_it();
}

pub fn fiber_exit() noreturn {
    SCHED.fiber_exit();
}
