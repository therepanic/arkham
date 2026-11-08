const c = @import("c");
const std = @import("std");

export var qemu_plugin_version: c_int = c.QEMU_PLUGIN_VERSION;

export fn qemu_plugin_install(id: c.qemu_plugin_id_t, info: [*c]const c.qemu_info_t, argc: c_int, argv: [*c][*c]u8) c_int {
    _ = info;
    _ = argc;
    _ = argv;
    std.debug.print("working", .{});
    c.qemu_plugin_register_vcpu_tb_trans_cb(id, onTbTrans, null);
    return 0;
}

fn onTbTrans(tb: ?*c.struct_qemu_plugin_tb, userdata: ?*anyopaque) callconv(.c) void {
    _ = userdata;
    const n = c.qemu_plugin_tb_n_insns(tb);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const insn = c.qemu_plugin_tb_get_insn(tb, i);
        var buf: [16]u8 = undefined;
        const len = c.qemu_plugin_insn_data(insn, &buf, buf.len);
        std.debug.print("insn: ", .{});
        for (buf[0..len]) |byte| std.debug.print("{x:0>2} ", .{byte});
        std.debug.print("\n", .{});
    }
}
