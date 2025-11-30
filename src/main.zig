const std = @import("std");
const allocator = std.heap.wasm_allocator;

const markdown = @import("markdown.zig");

var output_buffer: std.ArrayListUnmanaged(u8) = .empty;

export fn alloc(len: usize) [*]u8 {
    const ptr = allocator.alloc(u8, len) catch @panic("OOM");
    return ptr.ptr;
}

export fn free(ptr: [*]u8, len: usize) void {
    allocator.free(ptr[0..len]);
}

export fn get_output_len() usize {
    return output_buffer.items.len;
}

export fn get_output_ptr() [*]const u8 {
    return output_buffer.items.ptr;
}

export fn render(ptr: [*]u8, len: usize) u8 {
    const input = ptr[0..len];
    defer allocator.free(input);

    output_buffer.clearRetainingCapacity();

    renderImpl(input) catch |err| {
        const err_msg = std.fmt.allocPrint(allocator, "Render Error: {s}", .{@errorName(err)}) catch "Unknown OOM Error";
        output_buffer.appendSlice(allocator, err_msg) catch {};
        return 1;
    };

    return 0;
}

export fn free_output_buffer() void {
    output_buffer.clearAndFree(allocator);
}

fn renderImpl(input: []const u8) !void {
    var parser = try markdown.Parser.init(allocator);
    defer parser.deinit();

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trimRight(u8, line, "\r");
        try parser.feedLine(trimmed);
    }

    var doc = try parser.endInput();
    defer doc.deinit(allocator);

    try doc.render(output_buffer.writer(allocator));
}
