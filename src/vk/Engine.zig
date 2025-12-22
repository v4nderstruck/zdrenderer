const std = @import("std");
const vk = @import("clibs.zig").vk;
const sdl = @import("clibs.zig").sdl;
const vma = @import("clibs.zig").vma;
const bootstrapInstance = @import("bootstrap/instance.zig");
const bootstrapWindow = @import("bootstrap/window.zig");
const bootstrapDevice = @import("bootstrap/device.zig");
const bootstrapSwapChain = @import("bootstrap/swapchain.zig");

const Self = @This();

const RenderFrameHandle = struct {
    command_pool: vk.CommandPool = null,
    command_buffer: vk.CommandBuffer = null,
};

const RenderDataHandle = struct {
    command_pool: vk.CommandPool = null,
    command_buffer: vk.CommandBuffer = null,
};

allocator: std.mem.Allocator = undefined,
window: *sdl.Window = undefined,
surface: sdl.VulkanSurface = null,
instance: vk.Instance = null,
device: bootstrapDevice.GraphicDeviceHandles = .{},
swapchain: bootstrapSwapChain.GraphicSwapchainHandles = .{},
vm_allocator: vma.Allocator = null,
render_frames: [2]RenderFrameHandle = .{RenderFrameHandle{}} ** 2,
render_data: RenderDataHandle = .{},

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
    // TODO: A Swapchain Image and view with depth buffer for 3d!
}

fn init_command_buffer(self: *Self) void {
    for (&self.render_frames) |*render_frame| {
        const cp_create_info = vk.CommandPoolCreateInfo{
            .sType = vk.STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
            .queueFamilyIndex = self.device.graphics_queue.index,
            .flags = vk.COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
        };

        vk.vk_try(vk.CreateCommandPool(self.device.logical, &cp_create_info, null, &render_frame.command_pool));

        const cb_alloc_info = vk.CommandBufferAllocateInfo{
            .sType = vk.STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
            .commandBufferCount = 1,
            .commandPool = render_frame.command_pool,
            .level = vk.COMMAND_BUFFER_LEVEL_PRIMARY,
        };
        vk.vk_try(vk.AllocateCommandBuffers(self.device.logical, &cb_alloc_info, &render_frame.command_buffer));
    }

    const cp_create_info = vk.CommandPoolCreateInfo{
        .sType = vk.STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .queueFamilyIndex = self.device.graphics_queue.index,
        .flags = 0, // no special use, we use this command pool to prepare render data
    };

    vk.vk_try(vk.CreateCommandPool(self.device.logical, &cp_create_info, null, &self.render_data.command_pool));

    const cb_alloc_info = vk.CommandBufferAllocateInfo{
        .sType = vk.STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandBufferCount = 1,
        .commandPool = self.render_data.command_pool,
        .level = vk.COMMAND_BUFFER_LEVEL_PRIMARY,
    };

    vk.vk_try(vk.AllocateCommandBuffers(self.device.logical, &cb_alloc_info, &self.render_data.command_buffer));
}

pub fn init(alloc: std.mem.Allocator) Self {
    const window = bootstrapWindow.createWindow("zdrenderer", 800, 600);
    var engine = Self{ .window = window, .allocator = alloc };
    engine.init_instance();
    engine.surface = bootstrapWindow.createSurface(engine.instance, engine.window);
    engine.init_device();
    engine.init_vma_allocator();
    engine.init_swapchain();
    engine.init_command_buffer();
    return engine;
}

pub fn cleanup(self: *Self) void {
    self.allocator.free(self.swapchain.images);
    self.allocator.free(self.swapchain.image_views);
    vk.DestroyInstance(self.instance, null);
    sdl.DestroyWindow(self.window);
}
