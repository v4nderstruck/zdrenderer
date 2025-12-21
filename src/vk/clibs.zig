const std = @import("std");
const cInclude = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
    @cInclude("vulkan/vulkan.h");
});

const sdl_scoped_log = std.log.scoped(.sdl3);
pub const sdl = struct {
    // Structs
    pub const Window = cInclude.SDL_Window;
    pub const WindowFlags = cInclude.SDL_WindowFlags;
    pub const VulkanSurface = cInclude.VkSurfaceKHR;

    // Functions/Macros
    pub const Init = cInclude.SDL_Init;
    pub const CreateWindow = cInclude.SDL_CreateWindow;
    pub const DestroyWindow = cInclude.SDL_DestroyWindow;

    pub const GetError = cInclude.SDL_GetError;
    pub const VulkanGetInstanceExtension = cInclude.SDL_Vulkan_GetInstanceExtensions;
    pub const VulkanGetVkInstanceProcAddr = cInclude.SDL_Vulkan_GetVkGetInstanceProcAddr;
    pub const VulkanCreateSurface = cInclude.SDL_Vulkan_CreateSurface;

    // Constants
    pub const INIT_VIDEO = cInclude.SDL_INIT_VIDEO;
    pub const WINDOW_VULKAN = cInclude.SDL_WINDOW_VULKAN;
    pub const WINDOW_RESIZABLE = cInclude.SDL_WINDOW_RESIZABLE;

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
    pub const ApplicationInfo = cInclude.VkApplicationInfo;
    pub const InstanceCreateInfo = cInclude.VkInstanceCreateInfo;
    pub const DeviceQueueCreateInfo = cInclude.VkDeviceQueueCreateInfo;
    pub const Instance = cInclude.VkInstance;
    pub const Device = cInclude.VkDevice;
    pub const Queue = cInclude.VkQueue;
    pub const Bool32 = cInclude.VkBool32;
    pub const DebugUtilsMessengerEXT = cInclude.VkDebugUtilsMessengerEXT;
    pub const DebugUtilsMessengerCreateInfoEXT = cInclude.VkDebugUtilsMessengerCreateInfoEXT;
    pub const DebugMessageSeverityFlagBitsExt = cInclude.VkDebugUtilsMessageSeverityFlagBitsEXT;
    pub const DebugMessageTypeFlagsExt = cInclude.VkDebugUtilsMessageTypeFlagsEXT;
    pub const DebugMessengerCallbackDataExt = cInclude.VkDebugUtilsMessengerCallbackDataEXT;
    pub const DeviceCreateInfo = cInclude.VkDeviceCreateInfo;
    pub const PhysicalDeviceFeatures = cInclude.VkPhysicalDeviceFeatures;
    pub const PhysicalDevice = cInclude.VkPhysicalDevice;
    pub const PhysicalDeviceProperties = cInclude.VkPhysicalDeviceProperties;
    pub const QueueFamilyProperties = cInclude.VkQueueFamilyProperties;

    pub const PFN_CreateDebugUtilsMessagerExt = cInclude.PFN_vkCreateDebugUtilsMessengerEXT;
    pub const PFN_GetInstanceProcAddr = cInclude.PFN_vkGetInstanceProcAddr;

    // Functions/Macros
    pub const DestroyInstance = cInclude.vkDestroyInstance;
    pub const CreateInstance = cInclude.vkCreateInstance;
    pub const CreateDevice = cInclude.vkCreateDevice;
    pub const GetDeviceQueue = cInclude.vkGetDeviceQueue;
    pub const GetInstanceProcAddr = cInclude.vkGetInstanceProcAddr;
    pub const MAKE_VERSION = cInclude.VK_MAKE_VERSION;
    pub const EnumeratePhysicalDevices = cInclude.vkEnumeratePhysicalDevices;
    pub const GetPhysicalDeviceProperties = cInclude.vkGetPhysicalDeviceProperties;
    pub const GetPhysicalDeviceQueueFamiliyProperties = cInclude.vkGetPhysicalDeviceQueueFamilyProperties;
    pub const GetPhysicalDeviceSurfaceSupportKHR = cInclude.vkGetPhysicalDeviceSurfaceSupportKHR;

    // Constants
    pub const API_VERSION = cInclude.VK_API_VERSION_1_3;
    pub const STRUCTURE_TYPE_APPLICATION_INFO = cInclude.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    pub const STRUCTURE_TYPE_INSTANCE_CREATE_INFO = cInclude.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    pub const STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT = cInclude.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
    pub const STRUCTURE_TYPE_DEVICE_CREATE_INFO = cInclude.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    pub const STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO = cInclude.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    pub const EXT_DEBUG_UTILS = cInclude.VK_EXT_debug_utils;
    pub const EXT_DEBUG_UTILS_EXTENSION_NAME = cInclude.VK_EXT_DEBUG_UTILS_EXTENSION_NAME;
    pub const VAL_LAYER_KHRONOS_VALIDATION = "VK_LAYER_KHRONOS_validation"; // Not in headers?
    pub const QUEUE_COMPUTE_BIT = cInclude.VK_QUEUE_COMPUTE_BIT;
    pub const QUEUE_GRAPHICS_BIT = cInclude.VK_QUEUE_GRAPHICS_BIT;
    pub const QUEUE_TRANSFER_BIT = cInclude.VK_QUEUE_TRANSFER_BIT;
    pub const BoolFalse = cInclude.VK_FALSE;
    pub const BoolTrue = cInclude.VK_TRUE;
    pub const NullHandle = cInclude.VK_NULL_HANDLE;

    // Derived Constants
    pub const ZD_DEBUG_MESSAGE_SEVERITY_INFO = cInclude.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT |
        cInclude.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
        cInclude.VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT;
    pub const ZD_DEBUG_MESSAGE_SEVERITY_DEBUG = cInclude.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT |
        cInclude.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
        cInclude.VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT |
        cInclude.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT;
    pub const ZD_DEBUG_MESSAGE_TYPE = cInclude.VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
        cInclude.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT |
        cInclude.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;

    pub const SUCCESS = cInclude.VK_SUCCESS;

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
