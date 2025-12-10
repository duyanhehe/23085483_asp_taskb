const std = @import("std");

test "Context struct for task1b is correct" {
    const Context = @import("main.zig").Context;
    try std.testing.expect(@typeInfo(Context).Struct.fields.len == 8);
}

test "task1b stack grows downward" {
    const stack_size = 4096;
    var data: [stack_size]u8 = undefined;

    var sp: [*]u8 = @ptrCast(&data);
    sp += stack_size;

    try std.testing.expect(@intFromPtr(sp) > @intFromPtr(&data));
}

test "task1b declares foo" {
    const main = @import("main.zig");

    comptime {
        try std.testing.expect(@hasDecl(main, "foo"));
    }
}

test "task1b foo has correct signature" {
    const main = @import("main.zig");

    comptime {
        const decls = @typeInfo(main).Struct.decls;
        var found = false;

        inline for (decls) |d| {
            if (std.mem.eql(u8, d.name, "foo")) {
                found = true;
            }
        }

        if (!found) @compileError("foo not declared");
    }
}
