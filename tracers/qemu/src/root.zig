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

export fn qemu_plugin_register_vcpu_tb_exec_cb(tb: ?*c.struct_qemu_plugin_tb, cb: ?*const fn (c_uint, ?*anyopaque) void, flags: c_uint, userdata: ?*anyopaque) void {
    const ab = c.qemu_plugin_tb_get_insn(tb, 0);
    var buf: [16]u8 = undefined;

    const len = c.qemu_plugin_insn_data(
        ab,
        &buf,
        buf.len,
    );

    std.debug.print("Instruction bytes: ", .{});

    for (buf[0..len]) |byte| {
        std.debug.print("{x:0>2} ", .{byte});
    }

    std.debug.print("\n", .{});
    _ = cb;
    _ = flags;
    _ = userdata;
}
