// Task 1c: Multiple fiber context switching

const std = @import("std");
const builtin = @import("builtin");

// Define the Context struct to match the C library
const Context = extern struct {
    rip: ?*u64,
    rsp: ?*u64,
    rbx: ?*u64,
    rbp: ?*u64,
    r12: ?*u64,
    r13: ?*u64,
    r14: ?*u64,
    r15: ?*u64,
};

// Import the C library functions
extern fn get_context(c: [*c]Context) i32;
extern fn set_context(c: [*c]Context) void;

// second fiber context
var c2: Context = undefined;
// func goo
fn goo() noreturn {
    std.debug.print("you entered goo\n", .{});
    std.process.exit(0);
}

// func foo
fn foo() noreturn {
    std.debug.print("you called foo\n", .{});
    set_context(@ptrCast(&c2)); // switch fibers
    std.process.exit(1);
}

// func main
pub fn main() void {
    // allocate space for stack
    // data is an array of 4096 characters
    const stack_size = 4096;

    // ---------fiber 1 (foo)--------
    var data: [stack_size]u8 = undefined;
    // stacks grow downwards
    // sp is a pointer to characters
    var sp: [*]u8 = @ptrCast(&data);
    // set sp to be data PLUS 4096
    sp += stack_size;
    // set sp to sp AND -16L
    sp = @ptrFromInt(@intFromPtr(sp) & ~(@as(usize, 16) - 1));
    // set sp to sp MINUS 128
    sp = @ptrFromInt(@intFromPtr(sp) - 128);

    // create and empty context c
    var c: Context = undefined;
    // set rip of c to foo
    c.rip = @ptrCast(@alignCast(@constCast(&foo)));
    // set rsp of c to sp
    c.rsp = @ptrCast(@alignCast(sp));

    //  -------fiber 2 (goo)--------
    var data2: [stack_size]u8 = undefined;
    var sp2: [*]u8 = @ptrCast(&data2);
    sp2 += stack_size;

    sp2 = @ptrFromInt(@intFromPtr(sp2) & ~(@as(usize, 16) - 1));
    sp2 = @ptrFromInt(@intFromPtr(sp2) - 128);

    // set rip of c2 to goo
    c2.rip = @ptrCast(@alignCast(@constCast(&goo)));
    c2.rsp = @ptrCast(@alignCast(sp2));

    // call set_context with c
    set_context(@ptrCast(&c));
}
