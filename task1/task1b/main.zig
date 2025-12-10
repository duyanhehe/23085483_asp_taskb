// Task 1b: Fiber context switching

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

// func foo
pub fn foo() noreturn { //cannot return to main as they have different stack
    // output "you called foo"
    std.debug.print("you called foo\n", .{});
    // call function exit
    std.process.exit(0);
}

// func main
pub fn main() void {
    // allocate space for stack
    // data is an array of 4096 characters
    const stack_size = 4096;
    var data: [stack_size]u8 = undefined;

    // stacks grow downwards
    // sp is a pointer to characters
    var sp: [*]u8 = @ptrCast(&data);
    // set sp to be data PLUS 4096
    sp += stack_size;

    // create and empty context c
    var c: Context = undefined;
    // set rip of c to foo
    c.rip = @ptrCast(@alignCast(@constCast(&foo)));
    // set rsp of c to sp
    c.rsp = @ptrCast(@alignCast(sp));

    // call set_context with c
    set_context(@ptrCast(&c));
}
