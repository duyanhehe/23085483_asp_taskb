const std = @import("std");

// -------------------- Context Definition --------------------
pub const Context = extern struct {
    rip: ?*u64,
    rsp: ?*u64,
    rbx: ?*u64 = null,
    rbp: ?*u64 = null,
    r12: ?*u64 = null,
    r13: ?*u64 = null,
    r14: ?*u64 = null,
    r15: ?*u64 = null,
};

extern fn get_context(c: [*c]Context) i32;
extern fn set_context(c: [*c]Context) void;

// -------------------- Fiber Class --------------------
pub const Fiber = struct {
    const stack_size = 4096;

    context_: Context,
    stack_mem: []u8,
    stack_bottom_: [*]u8,
    stack_top_: [*]u8,
    data_: ?*i32,

    /// constructor
    pub fn init(
        alloc: std.mem.Allocator,
        func: *const fn () noreturn,
        data: ?*i32,
    ) !Fiber {
        const mem = try alloc.alloc(u8, stack_size);

        var self = Fiber{
            .context_ = undefined,
            .stack_mem = mem,
            .stack_bottom_ = mem.ptr,
            .stack_top_ = undefined,
            .data_ = data,
        };

        // stack grows DOWNWARD
        var sp: usize = @intFromPtr(mem.ptr) + stack_size;

        // align to 16 bytes
        sp = sp & ~(@as(usize, 16 - 1));

        // subtract 128 red-zone
        sp -= 128;

        self.stack_top_ = @ptrFromInt(sp);

        // initialize the fiber context
        self.context_.rip = @ptrFromInt(@intFromPtr(func));
        self.context_.rsp = @ptrFromInt(@intFromPtr(self.stack_top_));

        return self;
    }

    // destructor
    pub fn deinit(self: *Fiber, alloc: std.mem.Allocator) void {
        alloc.free(self.stack_mem);
    }

    // accessor
    pub fn getContext(self: *Fiber) *Context {
        return &self.context_;
    }
};
