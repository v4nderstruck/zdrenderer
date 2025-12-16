const std = @import("std");
const sdl_c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
});

const vulkan_c = @cImport({
    @cInclude("vulkan/vulkan.h");
});

const sdl_scoped_log = std.log.scoped(.sdl3);
pub const sdl = struct {
    // Structs
    pub const Window = sdl_c.SDL_Window;
    pub const WindowFlags = sdl_c.SDL_WindowFlags;

    // Functions/Macros
    pub const Init = sdl_c.SDL_Init;
    pub const CreateWindow = sdl_c.SDL_CreateWindow;
    pub const DestroyWindow = sdl_c.SDL_DestroyWindow;

    pub const GetError = sdl_c.SDL_GetError;
    pub const VulkanGetInstanceExtension = sdl_c.SDL_Vulkan_GetInstanceExtensions;

    // Constants
    pub const INIT_VIDEO = sdl_c.SDL_INIT_VIDEO;
    pub const WINDOW_VULKAN = sdl_c.SDL_WINDOW_VULKAN;
    pub const WINDOW_RESIZABLE = sdl_c.SDL_WINDOW_RESIZABLE;

    // Helpers
    pub fn sdl_try(result: c_int) void {
        if (result <= 0) {
            sdl_scoped_log.err("Unhandled sdl error: {s}", .{sdl.GetError()});
            @panic("Unhandled sdl panic!");
        }
    }
};

const vk_scoped_log = std.log.scoped(.vulkan);
pub const vk = struct {
    // Structs
    pub const ApplicationInfo = vulkan_c.VkApplicationInfo;
    pub const InstanceCreateInfo = vulkan_c.VkInstanceCreateInfo;
    pub const Instance = vulkan_c.VkInstance;


    // Functions/Macros
    pub const DestroyInstance = vulkan_c.vkDestroyInstance;
    pub const CreateInstance = vulkan_c.vkCreateInstance;
    pub const MAKE_VERSION = vulkan_c.VK_MAKE_VERSION;

    // Constants
    pub const API_VERSION = vulkan_c.VK_API_VERSION_1_3;
    pub const STRUCTURE_TYPE_APPLICATION_INFO = vulkan_c.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    pub const STRUCTURE_TYPE_INSTANCE_CREATE_INFO = vulkan_c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;

    pub const SUCCESS = vulkan_c.VK_SUCCESS;

    // Helpers
    pub fn vk_try(result: c_int) void {
        const Self = @This();
        switch (result) {
            Self.SUCCESS => {},
            else => @panic("Unhandled vulkan error"),
        }
    }
};
