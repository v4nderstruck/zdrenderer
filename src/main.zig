const std = @import("std");
const VKEngine = @import("vk/Engine.zig");

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}).init;
    defer if (alloc.deinit() == .leak) {
        @panic("leaked memory");
    };

    var engine = VKEngine.init(alloc.allocator());
    defer engine.cleanup();
    std.debug.print("Ok!\n", .{});
}
