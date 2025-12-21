const std = @import("std");
const vk = @import("clibs.zig").vk;
const sdl = @import("clibs.zig").sdl;
const bootstrapInstance = @import("bootstrap/instance.zig");
const bootstrapWindow = @import("bootstrap/window.zig");
const bootstrapDevice = @import("bootstrap/device.zig");

const Self = @This();

window: *sdl.Window = undefined,
surface: sdl.VulkanSurface = null,
allocator: std.mem.Allocator = undefined,
instance: vk.Instance = null,
device: bootstrapDevice.GraphicDeviceHandles = .{},

fn init_instance(self: *Self) void {
    var builder = bootstrapInstance.builder(self.allocator);
    self.instance = builder
        .setAppName("zdrenderer")
        .activateSDL3Window()
        // .enableDebugExtension()
        .build();
}

fn init_device(self: *Self) void {
    var builder = bootstrapDevice.builder(self.allocator, self.instance, self.surface);
    self.device = builder
        .debug_print_physical_devices()
        .selectByIndex(0)
        .selectLogicalDevice(true) // with swap chain
        .build();
}

pub fn init(alloc: std.mem.Allocator) Self {
    const window = bootstrapWindow.createWindow("zdrenderer", 800, 600);
    var engine = Self{ .window = window, .allocator = alloc };
    engine.init_instance();
    engine.surface = bootstrapWindow.createSurface(engine.instance, engine.window);
    engine.init_device();
    return engine;
}

pub fn cleanup(self: *Self) void {
    vk.DestroyInstance(self.instance, null);
    sdl.DestroyWindow(self.window);
}
