const std = @import("std");
const clibs = @import("../clibs.zig");
const vma = clibs.vma;
const vk = clibs.vk;
const sdl = clibs.sdl;

const device = @import("device.zig");
const Self = @This();

allocator: std.mem.Allocator = undefined,
device_handles: device.GraphicDeviceHandles = .{},
window: ?*sdl.Window = null,
surface: sdl.VulkanSurface = null,
vma_allocator: vma.Allocator = null,
window_width: u32 = undefined,
window_height: u32 = undefined,

// TODO: Selects could be a cool use case for comptime

pub fn selectSwapchain(self: *Self, comptime T: type) *Self {
    var count: u32 = 0;
    var list = std.ArrayList(T).empty;
    defer list.deinit(self.allocator);

    switch (T) {
        vk.SurfaceFormats => {
            vk.vk_try(vk.GetPhysicalDeviceSurfaceFormats(self.device_handles.physical, self.surface, &count, null));
            if (count == 0) {
                @panic("No swapchain formats found!");
            }
        },
        else => @panic("Cannot select this"),
    }

    list.ensureTotalCapacityPrecise(self.allocator, count) catch @panic("OOM");

    switch (T) {
        vk.SurfaceFormats => {
            vk.vk_try(vk.GetPhysicalDeviceSurfaceFormats(self.device_handles.physical, self.surface, &count, list.items.ptr));
        },

        else => @panic("Cannot select this"),
    }

    list.items.len = count;

    return self;
}

pub fn builder(
    alloc: std.mem.Allocator,
    window: *sdl.Window,
    surface: sdl.VulkanSurface,
    device_handles: device.GraphicDeviceHandles,
    vma_allocator: vma.Allocator,
) Self {
    var width: u32 = undefined;
    var height: u32 = undefined;

    sdl.sdl_try(@intFromBool(sdl.GetWindowSize(window, @ptrCast(&width), @ptrCast(&height))));

    const self = Self{
        .allocator = alloc,
        .window = window,
        .surface = surface,
        .device_handles = device_handles,
        .vma_allocator = vma_allocator,
        .window_width = width,
        .window_height = height,
    };
    return self;
}

pub fn build(self: *Self) void {
    _ = self;
}
