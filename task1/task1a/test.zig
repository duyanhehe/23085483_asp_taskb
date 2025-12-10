const std = @import("std");

test "Context struct field count and types" {
    const Context = @import("main.zig").Context;

    // Check number of fields
    try std.testing.expect(@typeInfo(Context).Struct.fields.len == 8);

    // Check that rip/rsp are optional pointers
    try std.testing.expect(@TypeOf(Context.rip) == ?*u64);
    try std.testing.expect(@TypeOf(Context.rsp) == ?*u64);
}

test "task1a x increments once" {
    var x: i32 = 0;
    x += 1;
    try std.testing.expectEqual(@as(i32, 1), x);
}

test "task1a has get_context and set_context declarations" {
    const main = @import("main.zig");

    comptime {
        if (!@hasDecl(main, "get_context"))
            @compileError("main.zig missing get_context decl");

        if (!@hasDecl(main, "set_context"))
            @compileError("main.zig missing set_context decl");
    }
}
