const std = @import("std");
const clibs = @import("../clibs.zig");
const vma = clibs.vma;
const sdl = clibs.sdl;

const device = @import("device.zig");
const Self = @This();

allocator: std.mem.Allocator = undefined,
device_handles: device.GraphicDeviceHandles = .{},
vma_allocator: vma.Allocator = null,
window_width: u32 = undefined,
window_height: u32 = undefined,

pub fn builder(
    alloc: std.mem.Allocator,
    window: *sdl.Window,
    device_handles: device.GraphicDeviceHandles,
    vma_allocator: vma.Allocator,
) Self {
    var width: u32 = undefined;
    var height: u32 = undefined;

    sdl.sdl_try(@intFromBool(sdl.GetWindowSize(window, @ptrCast(&width), @ptrCast(&height))));

    const self = Self{
        .allocator = alloc,
        .device_handles = device_handles,
        .vma_allocator = vma_allocator,
        .window_width = width,
        .window_height = height,
    };
    return self;
}

pub fn build(self: *Self) void{
    _ = self;
}
