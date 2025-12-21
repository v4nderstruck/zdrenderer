const std = @import("std");
const clibs = @import("../clibs.zig");

const vk = clibs.vk;
const sdl = clibs.sdl;

const Self = @This();
pub const GraphicDeviceHandles = struct {
    physical: vk.PhysicalDevice = null,
    logical: vk.Device = null,
    graphics_queue: vk.Queue = null,
    compute_queue: vk.Queue = null,
    present_queue: vk.Queue = null,
    transfer_queue: vk.Queue = null,
};

const QueueFamilies = struct {
    graphics_family: u32 = INVALID_INDEX,
    compute_family: u32 = INVALID_INDEX,
    transfer_family: u32 = INVALID_INDEX,
    present_family: u32 = INVALID_INDEX,

    const INVALID_INDEX = std.math.maxInt(u32);
    /// Checks if all queues are valid
    pub fn isValid(self: QueueFamilies) bool {
        return (self.graphics_family != INVALID_INDEX and
            self.compute_family != INVALID_INDEX and
            self.transfer_family != INVALID_INDEX and
            self.present_family != INVALID_INDEX);
    }

    /// Returns an iterator that yields unique valid queue indices
    pub fn iterator(self: QueueFamilies) Iterator {
        return Iterator{ .families = self };
    }

    pub const Iterator = struct {
        families: QueueFamilies,
        index: usize = 0,

        pub fn next(self: *Iterator) ?u32 {
            // Put fields into an array for easy indexing
            const fields = [_]u32{
                self.families.graphics_family,
                self.families.compute_family,
                self.families.transfer_family,
                self.families.present_family,
            };

            while (self.index < fields.len) {
                const current_val = fields[self.index];
                const current_pos = self.index;
                self.index += 1;

                // Skip invalid indices
                if (current_val == INVALID_INDEX) continue;

                // Set logic: Check if this value appeared in any previous field
                var already_seen = false;
                for (0..current_pos) |prev_idx| {
                    if (fields[prev_idx] == current_val) {
                        already_seen = true;
                        break;
                    }
                }

                // If we haven't seen it before, this is a unique element in the set
                if (!already_seen) {
                    return current_val;
                }
            }

            return null;
        }
    };
};

allocator: std.mem.Allocator = undefined,
instance: vk.Instance = null,
surface: sdl.VulkanSurface = null,
device_handles: std.ArrayList(vk.PhysicalDevice) = .empty,
chosen_queue_families: QueueFamilies = QueueFamilies{},
chosen_device_handler: vk.PhysicalDevice = null, // TODO: use the handle thing
handles: GraphicDeviceHandles = .{},

/// Selects a Queue on device by first occurence and constructs the logical device
pub fn selectLogicalDevice(self: *Self) *Self {
    if (self.chosen_device_handler == null) {
        @panic("Tried loading queue families without selecting physical device!");
    }
    var queue_family_count: u32 = 0;
    vk.GetPhysicalDeviceQueueFamiliyProperties(self.chosen_device_handler, &queue_family_count, null);
    if (queue_family_count <= 0) {
        @panic("Did not found any queue familye");
    }
    var queue_family_list = std.ArrayList(vk.QueueFamilyProperties).initCapacity(self.allocator, queue_family_count) catch @panic("OOM");
    defer queue_family_list.deinit(self.allocator);

    vk.GetPhysicalDeviceQueueFamiliyProperties(self.chosen_device_handler, &queue_family_count, queue_family_list.items.ptr);
    queue_family_list.items.len = queue_family_count; // update the slice

    for (queue_family_list.items, 0..) |queue_family, index| {
        if (queue_family.queueFlags & vk.QUEUE_GRAPHICS_BIT != 0 and
            self.chosen_queue_families.graphics_family == QueueFamilies.INVALID_INDEX)
        {
            std.debug.print("...({d}): Selected Graphics queue\n", .{index});
            self.chosen_queue_families.graphics_family = @intCast(index);
        }
        if (queue_family.queueFlags & vk.QUEUE_COMPUTE_BIT != 0 and
            self.chosen_queue_families.compute_family == QueueFamilies.INVALID_INDEX)
        {
            std.debug.print("...({d}): Selected Compute queue\n", .{index});
            self.chosen_queue_families.compute_family = @intCast(index);
        }
        if (queue_family.queueFlags & vk.QUEUE_TRANSFER_BIT != 0 and
            self.chosen_queue_families.transfer_family == QueueFamilies.INVALID_INDEX)
        {
            std.debug.print("...({d}): Selected Transfer queue\n", .{index});
            self.chosen_queue_families.transfer_family = @intCast(index);
        }

        var present_support: vk.Bool32 = vk.BoolFalse;
        vk.vk_try(vk.GetPhysicalDeviceSurfaceSupportKHR(self.chosen_device_handler, @intCast(index), self.surface, &present_support));
        if (present_support == vk.BoolTrue and
            self.chosen_queue_families.present_family == QueueFamilies.INVALID_INDEX)
        {
            std.debug.print("...({d}): Selected Present queue\n", .{index});
            self.chosen_queue_families.present_family = @intCast(index);
        }
    }

    if (!self.chosen_queue_families.isValid())
        unreachable;

    var queue_create_info = std.ArrayList(vk.DeviceQueueCreateInfo).empty;
    defer queue_create_info.deinit(self.allocator);
    var queue_families_it = self.chosen_queue_families.iterator();
    const family_priority: f32 = 1.0;
    while (queue_families_it.next()) |family| {
        queue_create_info.append(self.allocator, vk.DeviceQueueCreateInfo{
            .sType = vk.STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            .queueCount = 1,
            .queueFamilyIndex = family,
            .pQueuePriorities = &family_priority,
        }) catch @panic("OOM");
    }

    const null_device_features = vk.PhysicalDeviceFeatures{};
    const device_extensions: []const [*c]const u8 = &.{
        "VK_KHR_swapchain",
    };

    const logical_device_create_info = vk.DeviceCreateInfo{
        .sType = vk.STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .queueCreateInfoCount = @intCast(queue_create_info.items.len),
        .pQueueCreateInfos = @ptrCast(queue_create_info.items.ptr),
        .enabledLayerCount = 0,
        .ppEnabledLayerNames = null,
        .enabledExtensionCount = device_extensions.len,
        .ppEnabledExtensionNames = device_extensions.ptr,
        .pEnabledFeatures = &null_device_features,
        .pNext = null, // TODO:
    };

    vk.vk_try(vk.CreateDevice(self.chosen_device_handler, &logical_device_create_info, null, &self.handles.logical));
    vk.GetDeviceQueue(self.handles.logical, self.chosen_queue_families.graphics_family, 0, &self.handles.graphics_queue);
    vk.GetDeviceQueue(self.handles.logical, self.chosen_queue_families.compute_family, 0, &self.handles.compute_queue);
    vk.GetDeviceQueue(self.handles.logical, self.chosen_queue_families.present_family, 0, &self.handles.present_queue);
    vk.GetDeviceQueue(self.handles.logical, self.chosen_queue_families.transfer_family, 0, &self.handles.transfer_queue);

    return self;
}

/// Prints out a list of physical devices
pub fn debug_print_physical_devices(self: *Self) *Self {
    for (self.device_handles.items, 0..) |device, index| {
        var properties = vk.PhysicalDeviceProperties{};
        vk.GetPhysicalDeviceProperties(device, &properties);
        std.debug.print("...Device [{d}]: {s}\n", .{ index, properties.deviceName });
    }
    return self;
}

/// Selects a physical device by index (see debug_print_physical_devices)
/// TODO: Implement a select based on supported features
pub fn selectByIndex(self: *Self, index: u32) *Self {
    if (index >= self.device_handles.items.len) {
        @panic("Selected devices does not exists");
    }
    self.chosen_device_handler = self.device_handles.items[index];
    self.handles.physical = self.device_handles.items[index];
    return self;
}

/// Builder for a logical vulkan device
pub fn builder(alloc: std.mem.Allocator, instance: vk.Instance, surface: sdl.VulkanSurface) Self {
    var device_count: u32 = 0;
    var self = Self{
        .allocator = alloc,
        .instance = instance,
        .surface = surface,
    };

    vk.vk_try(vk.EnumeratePhysicalDevices(instance, &device_count, null));
    if (device_count <= 0) {
        @panic("Did not find a vulkan device!");
    }
    self.device_handles.ensureTotalCapacityPrecise(self.allocator, device_count) catch @panic("OOM");
    std.debug.print("Found {d} devices\n", .{device_count});
    vk.vk_try(vk.EnumeratePhysicalDevices(instance, &device_count, self.device_handles.items.ptr));
    self.device_handles.items.len = device_count; // we have to "move the slice"
    return self;
}

pub fn build(self: *Self) GraphicDeviceHandles {
    defer self.deinit();
    return self.handles;
}

pub fn deinit(self: *Self) void {
    self.device_handles.deinit(self.allocator);
}
