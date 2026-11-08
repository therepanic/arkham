const std = @import("std");
const qemu_tracer = @import("qemu-tracer");

fn refAll(comptime T: type, comptime depth: usize) void {
    inline for (comptime std.meta.declarations(T)) |d| {
        const v = @field(T, d.name);
        if (@TypeOf(v) == type) {
            switch (@typeInfo(v)) {
                .@"struct", .@"union", .@"enum", .@"opaque" => {
                    if (depth == 0 or std.mem.indexOfScalar(u8, @typeName(v), '.') != null)
                        refAll(v, depth + 1);
                },
                else => {},
            }
        } else {
            _ = &v;
        }
    }
}

test {
    refAll(qemu_tracer, 0);
}

export fn qemu_plugin_tb_get_insn(tb: ?*anyopaque, idx: usize) ?*anyopaque {
    _ = tb;
    _ = idx;
    return null;
}
export fn qemu_plugin_insn_data(insn: ?*anyopaque, dest: ?*anyopaque, len: usize) usize {
    _ = insn;
    _ = dest;
    _ = len;
    return 0;
}
