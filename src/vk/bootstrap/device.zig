const std = @import("std");
const vk = @import("../clibs.zig").vk;

const Self = @This();

allocator: std.mem.Allocator = undefined,
chosen_device_idx: u32 = undefined,
devices: std.ArrayList(vk.PhysicalDevice) = .empty,

pub fn debug_print_physical_devices(self: *Self) *Self {
    for (self.devices.items, 0..) |device, index| {
        var properties = vk.PhysicalDeviceProperties{};
        vk.GetPhysicalDeviceProperties(device, &properties);
        std.debug.print("Device [{d}]: {s}\n", .{ index, properties.deviceName });
    }
    return self;
}

// TODO: Implement a select based on supported features

pub fn selectByIndex(self: *Self, index: u32) *Self {
    if(index >= self.devices.items.len) {
        @panic("Selected devices does not exists");
    }
    self.chosen_device_idx = index;
    return self;
}

pub fn builder(alloc: std.mem.Allocator, instance: vk.Instance) Self {
    var device_count: u32 = 0;
    var self = Self{ .allocator = alloc };

    vk.vk_try(vk.EnumeratePhysicalDevices(instance, &device_count, null));
    if (device_count <= 0) {
        @panic("Did not find a vulkan device!");
    }
    self.devices.ensureTotalCapacityPrecise(self.allocator, device_count) catch @panic("OOM");
    std.debug.print("Found {d} devices\n", .{device_count});
    vk.vk_try(vk.EnumeratePhysicalDevices(instance, &device_count, self.devices.items.ptr));
    self.devices.items.len = device_count; // we have to "move the slice"
    return self;
}

pub fn build(self: *Self) vk.PhysicalDevice {
    defer self.deinit();
    return self.devices.items[self.chosen_device_idx];
}

pub fn deinit(self: *Self) void {
    self.devices.deinit(self.allocator);
}
