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
