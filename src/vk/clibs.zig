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
    pub const VulkanGetVkInstanceProcAddr = sdl_c.SDL_Vulkan_GetVkGetInstanceProcAddr;

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
    // Structs/Types
    pub const ApplicationInfo = vulkan_c.VkApplicationInfo;
    pub const InstanceCreateInfo = vulkan_c.VkInstanceCreateInfo;
    pub const Instance = vulkan_c.VkInstance;
    pub const Bool32 = vulkan_c.VkBool32;
    pub const DebugUtilsMessengerEXT = vulkan_c.VkDebugUtilsMessengerEXT;
    pub const DebugUtilsMessengerCreateInfoEXT = vulkan_c.VkDebugUtilsMessengerCreateInfoEXT;
    pub const DebugMessageSeverityFlagBitsExt = vulkan_c.VkDebugUtilsMessageSeverityFlagBitsEXT;
    pub const DebugMessageTypeFlagsExt = vulkan_c.VkDebugUtilsMessageTypeFlagsEXT;
    pub const DebugMessengerCallbackDataExt = vulkan_c.VkDebugUtilsMessengerCallbackDataEXT;
    pub const PFN_CreateDebugUtilsMessagerExt = vulkan_c.PFN_vkCreateDebugUtilsMessengerEXT;
    pub const PFN_GetInstanceProcAddr = vulkan_c.PFN_vkGetInstanceProcAddr;

    // Functions/Macros
    pub const DestroyInstance = vulkan_c.vkDestroyInstance;
    pub const CreateInstance = vulkan_c.vkCreateInstance;
    pub const GetInstanceProcAddr = vulkan_c.vkGetInstanceProcAddr;
    pub const MAKE_VERSION = vulkan_c.VK_MAKE_VERSION;

    // Constants
    pub const API_VERSION = vulkan_c.VK_API_VERSION_1_3;
    pub const STRUCTURE_TYPE_APPLICATION_INFO = vulkan_c.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    pub const STRUCTURE_TYPE_INSTANCE_CREATE_INFO = vulkan_c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    pub const STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT = vulkan_c.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
    pub const EXT_DEBUG_UTILS = vulkan_c.VK_EXT_debug_utils;
    pub const EXT_DEBUG_UTILS_EXTENSION_NAME = vulkan_c.VK_EXT_DEBUG_UTILS_EXTENSION_NAME;
    pub const BoolFalse = vulkan_c.VK_FALSE;
    pub const BoolTrue = vulkan_c.VK_TRUE;

    // Derived Constants
    pub const ZD_DEBUG_MESSAGE_SEVERITY_INFO = vulkan_c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT |
        vulkan_c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
        vulkan_c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT;
    pub const ZD_DEBUG_MESSAGE_SEVERITY_DEBUG = vulkan_c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT |
        vulkan_c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
        vulkan_c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT |
        vulkan_c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT;
    pub const ZD_DEBUG_MESSAGE_TYPE = vulkan_c.VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
        vulkan_c.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT |
        vulkan_c.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;

    pub const SUCCESS = vulkan_c.VK_SUCCESS;

    // Vulkan stuff
    pub fn getVulkanInstanceFnByName(comptime Fn: type, instance: Instance, name: [:0]const u8) Fn {
        const vkGetInstanceProcAddr: PFN_GetInstanceProcAddr = @ptrCast(sdl.VulkanGetVkInstanceProcAddr());
        if (vkGetInstanceProcAddr) |get_fn| {
            return @ptrCast(get_fn(instance, name));
        }
        @panic("Could not get PFN_GetInstanceProcAddr for instance");
    }

    // Helpers
    pub fn vk_try(result: c_int) void {
        const Self = @This();
        switch (result) {
            Self.SUCCESS => {},
            else => @panic("Unhandled vulkan error"),
        }
    }
};
