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
swapchain_create_info: vk.SwapchainCreateInfo = .{},

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
        vk.PresentMode => {
            vk.vk_try(vk.GetPhysicalDevicePresentModes(self.device_handles.physical, self.surface, &count, null));
            if (count == 0) {
                @panic("No swapchain formats found!");
            }
        },
        else => @panic("Cannot select this"),
    }

    list.ensureTotalCapacityPrecise(self.allocator, count) catch @panic("OOM");

    // Is this T specific? whatever
    switch (T) {
        vk.SurfaceFormats => {
            vk.vk_try(vk.GetPhysicalDeviceSurfaceFormats(self.device_handles.physical, self.surface, &count, list.items.ptr));
            self.swapchain_create_info.imageFormat = vk.ZD_SWAPCHAIN_FORMAT;
            self.swapchain_create_info.imageColorSpace = vk.ZD_SWAPCHAIN_COLOR_SPACE;
            self.swapchain_create_info.imageArrayLayers = 1;
            self.swapchain_create_info.imageUsage = vk.IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
        },
        vk.PresentMode => {
            vk.vk_try(vk.GetPhysicalDevicePresentModes(self.device_handles.physical, self.surface, &count, list.items.ptr));
            self.swapchain_create_info.presentMode = vk.ZD_PRESENT_MODE;
        },
        else => @panic("Cannot select this"),
    }

    list.items.len = count;

    for (list.items, 0..) |item, index| {
        switch (T) {
            vk.SurfaceFormats => {
                _ = item;
                _ = index;
            },
            vk.PresentMode => {
                _ = item;
                _ = index;
            },
            else => @panic("Cannot select this"),
        }
    }

    return self;
}

pub fn selectExtent(self: *Self) *Self {
    var capabilities: vk.SurfaceCapabilities = .{};
    vk.vk_try(vk.GetPhysicalDeviceSurfaceCapabilities(self.device_handles.physical, self.surface, &capabilities));

    var extent = vk.Extent2D{
        .width = self.window_width,
        .height = self.window_height,
    };
    extent.width = @max(
        capabilities.minImageExtent.width,
        @min(capabilities.maxImageExtent.width, extent.width),
    );
    extent.height = @max(
        capabilities.minImageExtent.height,
        @min(capabilities.maxImageExtent.height, extent.height),
    );
    const image_count = blk: {
        const desired_count = capabilities.minImageCount + 1;
        if (capabilities.maxImageCount > 0) {
            break :blk @min(desired_count, capabilities.maxImageCount);
        }
        break :blk desired_count;
    };
    self.swapchain_create_info.minImageCount = image_count;
    self.swapchain_create_info.imageExtent = extent;
    self.swapchain_create_info.preTransform = capabilities.currentTransform;
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
    self.swapchain_create_info.sType = vk.STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO;
    self.swapchain_create_info.surface = self.surface;
    self.swapchain_create_info.compositeAlpha = vk.COMPOSITE_ALPHA_OPAQUE_BIT;
    self.swapchain_create_info.oldSwapchain = null;
    self.swapchain_create_info.clipped = vk.BoolTrue;

    const queue_family: []const u32 = &.{ self.device_handles.graphics_queue.index, self.device_handles.present_queue.index };
    if (self.device_handles.present_queue.index != self.device_handles.graphics_queue.index) {
        self.swapchain_create_info.imageSharingMode = vk.SHARING_MODE_CONCURRENT;
        self.swapchain_create_info.queueFamilyIndexCount = 2;
        self.swapchain_create_info.pQueueFamilyIndices = queue_family.ptr;
    } else {
        self.swapchain_create_info.imageSharingMode = vk.SHARING_MODE_EXCLUSIVE;
    }
    var swapchain: vk.Swapchain = null;
    vk.vk_try(vk.CreateSwapchain(self.device_handles.logical, &self.swapchain_create_info, null, &swapchain));
}
