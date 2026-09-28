const c = @import("c");
const std = @import("std");

export var qemu_plugin_version: c_int = c.QEMU_PLUGIN_VERSION;

export fn qemu_plugin_install(id: c.qemu_plugin_id_t, info: [*c]const c.qemu_info_t, argc: c_int, argv: [*c][*c]u8) c_int {
    _ = id;
    _ = info;
    _ = argc;
    _ = argv;
    std.debug.print("working", .{});
    return 0;
}
