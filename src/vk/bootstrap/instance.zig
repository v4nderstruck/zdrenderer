const vk = @import("../clibs.zig").vk;
const sdl = @import("../clibs.zig").sdl;

const Self = @This();

applicationInfo: vk.ApplicationInfo = .{
    .sType = vk.STRUCTURE_TYPE_APPLICATION_INFO,
    .pApplicationName = "DUMMY",
    .applicationVersion = vk.MAKE_VERSION(1, 0, 0),
    .pEngineName = null,
    .engineVersion = vk.MAKE_VERSION(1, 0, 0),
    .apiVersion = vk.API_VERSION,
},
instanceCreateInfo: vk.InstanceCreateInfo = .{
    .sType = vk.STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
    .pApplicationInfo = undefined,
    .enabledExtensionCount = 0,
    .ppEnabledExtensionNames = undefined,
    .enabledLayerCount = 0,
},

pub fn builder() Self {
    return Self{};
}

/// Sets Application Name to `name`
pub fn setAppName(self: *Self, name: [:0]const u8) *Self {
    self.applicationInfo.pApplicationName = name;
    return self;
}

/// Configures SDL3 required Extensions
/// Will SegFault when SDL3 has not been initialized
pub fn activateSDL3Window(self: *Self) *Self {
    var sdl_required_ext_count: u32 = undefined;
    const sdl3_extension = sdl.VulkanGetInstanceExtension(&sdl_required_ext_count);
    // TODO: Check all extensions are support by vulkan
    self.instanceCreateInfo.enabledExtensionCount = sdl_required_ext_count;
    self.instanceCreateInfo.ppEnabledExtensionNames = sdl3_extension;
    return self;
}

pub fn build(self: *Self) vk.Instance {
    self.instanceCreateInfo.pApplicationInfo = &self.applicationInfo;
    var instance: vk.Instance = undefined;
    vk.vk_try(vk.CreateInstance(&self.instanceCreateInfo, null, &instance));
    return instance;
}
