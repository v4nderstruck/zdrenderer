const sdl = @import("../clibs.zig").sdl;

const Self = @This();

/// Creates a Window using sdl3
pub fn createWindow(title: [:0]const u8, width: u32, height: u32) ?*sdl.Window {
    sdl.sdl_try(@intFromBool(sdl.Init(sdl.INIT_VIDEO)));
    const window = sdl.CreateWindow(
        title,
        @intCast(width),
        @intCast(height),
        sdl.WINDOW_VULKAN | sdl.WINDOW_RESIZABLE,
    );
    return window orelse @panic("Failed to create the window");
}
