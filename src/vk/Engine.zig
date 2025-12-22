const std = @import("std");
const vk = @import("clibs.zig").vk;
const sdl = @import("clibs.zig").sdl;
const vma = @import("clibs.zig").vma;
const bootstrapInstance = @import("bootstrap/instance.zig");
const bootstrapWindow = @import("bootstrap/window.zig");
const bootstrapDevice = @import("bootstrap/device.zig");
const bootstrapSwapChain = @import("bootstrap/swapchain.zig");

const Self = @This();

allocator: std.mem.Allocator = undefined,
window: *sdl.Window = undefined,
surface: sdl.VulkanSurface = null,
instance: vk.Instance = null,
device: bootstrapDevice.GraphicDeviceHandles = .{},
swapchain: bootstrapSwapChain.GraphicSwapchainHandles = .{},
vm_allocator: vma.Allocator = null,

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

fn init_vma_allocator(self: *Self) void {
    const create_info = vma.AllocatorCreateInfo{
        .physicalDevice = self.device.physical,
        .device = self.device.logical,
        .instance = self.instance,
    };
    vk.vk_try(vma.CreateAllocator(&create_info, &self.vm_allocator));
}

fn init_swapchain(self: *Self) void {
    var builder = bootstrapSwapChain.builder(
        self.allocator,
        self.window,
        self.surface,
        self.device,
        self.vm_allocator,
    );
    self.swapchain = builder.selectSwapchain(vk.SurfaceFormats)
        .selectSwapchain(vk.PresentMode)
        .selectExtent()
        .build();
}

pub fn init(alloc: std.mem.Allocator) Self {
    const window = bootstrapWindow.createWindow("zdrenderer", 800, 600);
    var engine = Self{ .window = window, .allocator = alloc };
    engine.init_instance();
    engine.surface = bootstrapWindow.createSurface(engine.instance, engine.window);
    engine.init_device();
    engine.init_vma_allocator();
    engine.init_swapchain();
    return engine;
}

pub fn cleanup(self: *Self) void {
    self.allocator.free(self.swapchain.images);
    self.allocator.free(self.swapchain.image_views);
    vk.DestroyInstance(self.instance, null);
    sdl.DestroyWindow(self.window);
}
