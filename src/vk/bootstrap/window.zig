const clibs = @import("../clibs.zig");

const sdl = clibs.sdl;
const vk = clibs.vk;

const Self = @This();

/// Creates a Window using sdl3
pub fn createWindow(title: [:0]const u8, width: u32, height: u32) *sdl.Window {
    sdl.sdl_try(@intFromBool(sdl.Init(sdl.INIT_VIDEO)));
    const window = sdl.CreateWindow(
        title,
        @intCast(width),
        @intCast(height),
        sdl.WINDOW_VULKAN | sdl.WINDOW_RESIZABLE,
    );
    return window.?;
}

/// Creates a Surface using sdl3
pub fn createSurface(instance: vk.Instance, window: *sdl.Window) sdl.VulkanSurface {
    if (instance == null) {
        @panic("Cannot create a surface with an invalid instance");
    }
    var surface: sdl.VulkanSurface = null;
    sdl.sdl_try(@intFromBool(sdl.VulkanCreateSurface(window, instance, null, &surface)));
    return surface;
}
