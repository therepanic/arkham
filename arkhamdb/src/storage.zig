const std = @import("std");
const target = @import("target.zig");

pub const Storage = struct {
    io: std.Io,
    file: std.Io.File,

    pub fn init(io: std.Io, file: std.Io.File) !Storage {
        const writer = file.writer(io).interface;
        try writeHeader(writer);
        return .{ .io = io, .file = file };
    }
};

const MAGIC = [_]u8{ 0x7F, 'a', 'r', 'k', 'h', 'a', 'm' };

const Header = struct { version: u16 = 1, check_sum: [32]u8, branch_offset: u64, arch: target.Arch, endian: target.Endian, os: target.Os };

fn writeHeader(writer: *std.Io.Writer, header: Header) !void {
    try writer.writeAll(MAGIC);
    try writer.writeInt(u16, header.version, .little);
    try writer.writeAll(header.check_sum);
    try writer.writeInt(u64, header.branch_offset, .little);
    try writer.writeByte(header.arch);
    try writer.writeByte(header.endian);
    try writer.writeByte(header.os);
}
