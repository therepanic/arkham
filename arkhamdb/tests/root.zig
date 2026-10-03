const std = @import("std");
const arkhamdb = @import("arkhamdb");

fn refAll(comptime T: type, comptime depth: usize) void {
    inline for (comptime std.meta.declarations(T)) |name| {
        const v = @field(T, name);
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
    refAll(arkhamdb, 0);
}
