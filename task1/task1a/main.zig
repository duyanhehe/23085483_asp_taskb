// Task 1a: get_context/set_context

const std = @import("std");

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
pub extern fn get_context(c: [*c]Context) i32;
pub extern fn set_context(c: [*c]Context) void;

// set x to 0
var x: i32 = 0;

pub fn main() void {
    // set c to get_context
    var c: Context = undefined;

    _ = get_context(@ptrCast(&c));

    // output "a message"
    std.debug.print("a message\n", .{});

    // if x == 0
    if (x == 0) {
        // set x to x PLUS 1
        x += 1;
        // call set_context with c
        set_context(@ptrCast(&c));
    }
}
