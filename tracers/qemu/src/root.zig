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

fn onInsnExec(vcpu_index: c_uint, userdata: ?*anyopaque) callconv(.c) void {
    _ = vcpu_index;
    const text: [*:0]const u8 = @ptrCast(userdata.?);
    std.debug.print("{s}\n", .{text});
}

fn onTbTrans(tb: ?*c.struct_qemu_plugin_tb, userdata: ?*anyopaque) callconv(.c) void {
    _ = userdata;
    const n = c.qemu_plugin_tb_n_insns(tb);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const insn = c.qemu_plugin_tb_get_insn(tb, i);
        const disas = c.qemu_plugin_insn_disas(insn);
        c.qemu_plugin_register_vcpu_insn_exec_cb(insn, onInsnExec, c.QEMU_PLUGIN_CB_NO_REGS, disas);
    }
}
