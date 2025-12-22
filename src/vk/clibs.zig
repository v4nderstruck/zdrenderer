const std = @import("std");
const cInclude = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_vulkan.h");
    @cInclude("vulkan/vulkan.h");
    @cInclude("vk_mem_alloc.h");
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
    pub const GetWindowSize = cInclude.SDL_GetWindowSize;

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
    pub const ImageViewCreateInfo = cInclude.VkImageViewCreateInfo;
    pub const Instance = cInclude.VkInstance;
    pub const Device = cInclude.VkDevice;
    pub const Queue = cInclude.VkQueue;
    pub const Swapchain = cInclude.VkSwapchainKHR;
    pub const Image = cInclude.VkImage;
    pub const ImageView = cInclude.VkImageView;

    pub const Bool32 = cInclude.VkBool32;
    pub const DebugUtilsMessengerEXT = cInclude.VkDebugUtilsMessengerEXT;
    pub const DebugUtilsMessengerCreateInfoEXT = cInclude.VkDebugUtilsMessengerCreateInfoEXT;
    pub const DebugMessageSeverityFlagBitsExt = cInclude.VkDebugUtilsMessageSeverityFlagBitsEXT;
    pub const DebugMessageTypeFlagsExt = cInclude.VkDebugUtilsMessageTypeFlagsEXT;
    pub const DebugMessengerCallbackDataExt = cInclude.VkDebugUtilsMessengerCallbackDataEXT;
    pub const DeviceCreateInfo = cInclude.VkDeviceCreateInfo;
    pub const PhysicalDeviceFeatures = cInclude.VkPhysicalDeviceFeatures;
    pub const PhysicalDeviceShaderDrawParameterFeatures = cInclude.VkPhysicalDeviceShaderDrawParameterFeatures;
    pub const PhysicalDeviceProperties = cInclude.VkPhysicalDeviceProperties;
    pub const PhysicalDevice = cInclude.VkPhysicalDevice;
    pub const SurfaceFormats = cInclude.VkSurfaceFormatKHR;
    pub const SurfaceCapabilities = cInclude.VkSurfaceCapabilitiesKHR;
    pub const PresentMode = cInclude.VkPresentModeKHR;
    pub const QueueFamilyProperties = cInclude.VkQueueFamilyProperties;
    pub const Extent2D = cInclude.VkExtent2D;
    pub const SwapchainCreateInfo = cInclude.VkSwapchainCreateInfoKHR;

    pub const PFN_CreateDebugUtilsMessagerExt = cInclude.PFN_vkCreateDebugUtilsMessengerEXT;
    pub const PFN_GetInstanceProcAddr = cInclude.PFN_vkGetInstanceProcAddr;

    // Functions/Macros
    pub const DestroyInstance = cInclude.vkDestroyInstance;
    pub const CreateInstance = cInclude.vkCreateInstance;
    pub const CreateDevice = cInclude.vkCreateDevice;
    pub const CreateSwapchain = cInclude.vkCreateSwapchainKHR;
    pub const CreateImageView = cInclude.vkCreateImageView;
    pub const GetDeviceQueue = cInclude.vkGetDeviceQueue;
    pub const GetInstanceProcAddr = cInclude.vkGetInstanceProcAddr;
    pub const MAKE_VERSION = cInclude.VK_MAKE_VERSION;
    pub const EnumeratePhysicalDevices = cInclude.vkEnumeratePhysicalDevices;
    pub const GetPhysicalDeviceProperties = cInclude.vkGetPhysicalDeviceProperties;
    pub const GetPhysicalDeviceQueueFamiliyProperties = cInclude.vkGetPhysicalDeviceQueueFamilyProperties;
    pub const GetPhysicalDeviceSurfaceSupportKHR = cInclude.vkGetPhysicalDeviceSurfaceSupportKHR;
    pub const GetPhysicalDeviceSurfaceFormats = cInclude.vkGetPhysicalDeviceSurfaceFormatsKHR;
    pub const GetPhysicalDeviceSurfaceCapabilities = cInclude.vkGetPhysicalDeviceSurfaceCapabilitiesKHR;
    pub const GetPhysicalDevicePresentModes = cInclude.vkGetPhysicalDeviceSurfacePresentModesKHR;
    pub const GetSwapchainImages = cInclude.vkGetSwapchainImagesKHR;

    // Constants
    pub const API_VERSION = cInclude.VK_API_VERSION_1_3;

    pub const STRUCTURE_TYPE_APPLICATION_INFO = cInclude.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    pub const STRUCTURE_TYPE_INSTANCE_CREATE_INFO = cInclude.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    pub const STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT = cInclude.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
    pub const STRUCTURE_TYPE_DEVICE_CREATE_INFO = cInclude.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    pub const STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO = cInclude.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    pub const STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DRAW_PARAMETER_FEATURES = cInclude.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DRAW_PARAMETERS_FEATURES;
    pub const STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO = cInclude.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
    pub const STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO = cInclude.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;

    pub const EXT_DEBUG_UTILS = cInclude.VK_EXT_debug_utils;
    pub const EXT_DEBUG_UTILS_EXTENSION_NAME = cInclude.VK_EXT_DEBUG_UTILS_EXTENSION_NAME;

    pub const FORMAT_B8G8R8A8_SRGB = cInclude.VK_FORMAT_B8G8R8A8_SRGB;
    pub const COLOR_SPACE_SRGB_NONLINEAR_KHR = cInclude.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;
    pub const PRESENT_MODE_FIFO = cInclude.VK_PRESENT_MODE_FIFO_KHR;
    pub const IMAGE_USAGE_COLOR_ATTACHMENT_BIT = cInclude.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
    pub const COMPOSITE_ALPHA_OPAQUE_BIT = cInclude.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
    pub const SHARING_MODE_CONCURRENT = cInclude.VK_SHARING_MODE_CONCURRENT;
    pub const SHARING_MODE_EXCLUSIVE = cInclude.VK_SHARING_MODE_EXCLUSIVE;
    pub const IMAGE_VIEW_TYPE_2D = cInclude.VK_IMAGE_VIEW_TYPE_2D;
    pub const COMPONENT_SWIZZLE_IDENTITY = cInclude.VK_COMPONENT_SWIZZLE_IDENTITY;
    pub const IMAGE_ASPECT_COLOR_BIT = cInclude.VK_IMAGE_ASPECT_COLOR_BIT;

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

    pub const ZD_SWAPCHAIN_FORMAT = FORMAT_B8G8R8A8_SRGB;
    pub const ZD_SWAPCHAIN_COLOR_SPACE = COLOR_SPACE_SRGB_NONLINEAR_KHR;
    pub const ZD_PRESENT_MODE = PRESENT_MODE_FIFO;

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

pub const vma = struct {
    // Structs/Types
    pub const Allocator = cInclude.VmaAllocator;
    pub const AllocatorCreateInfo = cInclude.VmaAllocatorCreateInfo;

    // Functions/Macros
    pub const CreateAllocator = cInclude.vmaCreateAllocator;

};
