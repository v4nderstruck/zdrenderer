const vk = @import("../clibs.zig").vk;
const sdl = @import("../clibs.zig").sdl;

const std = @import("std");
const Self = @This();
const ExtensionList = std.ArrayList([*c]const u8);

application_info: vk.ApplicationInfo = .{
    .sType = vk.STRUCTURE_TYPE_APPLICATION_INFO,
    .pApplicationName = "DUMMY",
    .applicationVersion = vk.MAKE_VERSION(1, 0, 0),
    .pEngineName = null,
    .engineVersion = vk.MAKE_VERSION(1, 0, 0),
    .apiVersion = vk.API_VERSION,
},
instance_create_info: vk.InstanceCreateInfo = .{
    .sType = vk.STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
    .pApplicationInfo = undefined,
    .enabledExtensionCount = 0,
    .ppEnabledExtensionNames = undefined,
    .enabledLayerCount = 0,
},
extensions: ExtensionList = undefined,
enable_debug_extension: bool = false,
allocator: std.mem.Allocator = undefined,

pub fn builder(alloc: std.mem.Allocator) Self {
    return Self{
        .allocator = alloc,
        .extensions = ExtensionList.empty,
    };
}

/// Sets Application Name to `name`
pub fn setAppName(self: *Self, name: [:0]const u8) *Self {
    self.application_info.pApplicationName = name;
    return self;
}

/// Configures SDL3 required Extensions
/// Will SegFault when SDL3 has not been initialized
pub fn activateSDL3Window(self: *Self) *Self {
    var sdl_required_ext_count: u32 = undefined;
    const sdl3_extension = sdl.VulkanGetInstanceExtension(&sdl_required_ext_count);
    self.extensions.appendSlice(self.allocator, sdl3_extension[0..sdl_required_ext_count]) catch @panic("OOM!");
    return self;
}

pub fn enableDebugExtension(self: *Self) *Self {
    self.extensions.append(self.allocator, vk.EXT_DEBUG_UTILS) catch @panic("OOM!");
    self.enable_debug_extension = true;
    return self;
}

/// Build a vk.Instance and implicitly deinit the Builder
pub fn build(self: *Self) vk.Instance {
    self.instance_create_info.pApplicationInfo = &self.application_info;
    self.instance_create_info.enabledExtensionCount = @intCast(self.extensions.items.len);
    self.instance_create_info.ppEnabledExtensionNames = @ptrCast(self.extensions.items.ptr);

    var instance: vk.Instance = undefined;
    vk.vk_try(vk.CreateInstance(&self.instance_create_info, null, &instance));

    if (self.enable_debug_extension) {
        const maybe_create_debug_fn = vk.getVulkanInstanceFnByName(vk.PFN_CreateDebugUtilsMessagerExt, instance, "vkCreateDebugUtilsMessengerEXT");
        if (maybe_create_debug_fn) |create_debug_fn| {
            const create_debug_info = vk.DebugUtilsMessengerCreateInfoEXT{
                .sType = vk.STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
                .messageSeverity = vk.ZD_DEBUG_MESSAGE_SEVERITY_DEBUG,
                .messageType = vk.ZD_DEBUG_MESSAGE_TYPE,
                .pfnUserCallback = null, // TODO: Add callback
                .pUserData = null,
            };
            var maybe_debug_utils_messenger: vk.DebugUtilsMessengerEXT = undefined;
            vk.vk_try(create_debug_fn(instance, &create_debug_info, null, &maybe_debug_utils_messenger));
        }
    }
    defer deinit(self);
    return instance;
}

pub fn deinit(self: *Self) void {
    self.extensions.deinit(self.allocator);
}
