const std = @import("std");
const vk = @import("clibs.zig").vk;
const sdl = @import("clibs.zig").sdl;
const bootstrapInstance = @import("bootstrap/instance.zig");
const bootstrapWindow = @import("bootstrap/window.zig");

const Self = @This();

window: ?*sdl.Window = undefined,
allocator: std.mem.Allocator = undefined,
instance: vk.Instance = undefined,

fn init_instance(self: *Self) void {
    var builder = bootstrapInstance.builder();
    self.instance = builder
        .setAppName("zdrenderer")
        .activateSDL3Window()
        .build();
}

pub fn init(alloc: std.mem.Allocator) Self {
    const window = bootstrapWindow.createWindow("zdrenderer", 800, 600);
    var engine = Self{ .window = window, .allocator = alloc };
    engine.init_instance();
    return engine;
}

pub fn cleanup(self: *Self) void {
    vk.DestroyInstance(self.instance, null);
    sdl.DestroyWindow(self.window);
}
