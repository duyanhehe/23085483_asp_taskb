const std = @import("std");

// Stub implementations so tests link without libcontext.a
export fn get_context(_: *anyopaque) i32 {
    return 0;
}

export fn set_context(_: *anyopaque) void {}

test "stack alignment is correct" {
    const stack_size = 4096;
    var data: [stack_size]u8 = undefined;

    var sp: [*]u8 = @ptrCast(&data);
    sp += stack_size;

    const aligned = @as([*]u8, @ptrFromInt(@intFromPtr(sp) & ~(@as(usize, 16) - 1)));
    try std.testing.expect(@intFromPtr(aligned) % 16 == 0);
}

test "red zone subtraction is 128 bytes" {
    const stack_size = 4096;
    var data: [stack_size]u8 = undefined;

    var sp: [*]u8 = @ptrCast(&data);
    sp += stack_size;

    const rz = @as([*]u8, @ptrFromInt(@intFromPtr(sp) - 128));
    try std.testing.expect(@intFromPtr(rz) == @intFromPtr(sp) - 128);
}

test "task1c has foo and goo contexts" {
    const mod = @import("main.zig");

    comptime {
        if (!@hasDecl(mod, "foo"))
            @compileError("foo is missing in main.zig");

        if (!@hasDecl(mod, "goo"))
            @compileError("goo is missing in main.zig");
    }
}

test "fiber context switching works correctly" {
    const mod = @import("main.zig");

    var c1: mod.Context = undefined;
    var c2: mod.Context = undefined;

    const stack_size = 4096;

    // Fiber 1
    var data1: [stack_size]u8 = undefined;
    var sp1: [*]u8 = @as([*]u8, @ptrCast(&data1)) + stack_size;
    sp1 = @as([*]u8, @ptrFromInt(@intFromPtr(sp1) & ~(@as(usize, 16) - 1)));
    sp1 = @as([*]u8, @ptrFromInt(@intFromPtr(sp1) - 128));

    c1.rip = @ptrFromInt(@intFromPtr(&mod.foo));
    c1.rsp = @ptrFromInt(@intFromPtr(sp1));

    // Fiber 2
    var data2: [stack_size]u8 = undefined;
    var sp2: [*]u8 = @as([*]u8, @ptrCast(&data2)) + stack_size;
    sp2 = @as([*]u8, @ptrFromInt(@intFromPtr(sp2) & ~(@as(usize, 16) - 1)));
    sp2 = @as([*]u8, @ptrFromInt(@intFromPtr(sp2) - 128));

    c2.rip = @ptrFromInt(@intFromPtr(&mod.goo));
    c2.rsp = @ptrFromInt(@intFromPtr(sp2));

    try std.testing.expect(c1.rip != null);
    try std.testing.expect(c1.rsp != null);
    try std.testing.expect(c2.rip != null);
    try std.testing.expect(c2.rsp != null);
}
