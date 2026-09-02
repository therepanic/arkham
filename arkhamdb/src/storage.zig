const std = @import("std");
const target = @import("target.zig");

pub const Storage = struct {
    io: std.Io,
    file: std.Io.File,

    pub fn init(io: std.Io, file: std.Io.File, config: Config) !Storage {
        const writer = file.writer(io).interface;
        const header: Header = .{ .check_sum = config.check_sum, .arch = config.arch, .endian = config.endian, .os = config.os };
        try writeHeader(&writer, header);
        return .{ .io = io, .file = file };
    }
};

pub const Config = struct { check_sum: [32]u8, arch: target.Arch, endian: target.Endian, os: target.Os };

const MAGIC = [_]u8{ 0x7F, 'a', 'r', 'k', 'h', 'a', 'm' };

const Header = struct {
    version: u16 = 1,
    check_sum: [32]u8,
    arch: target.Arch,
    endian: target.Endian,
    os: target.Os,
};

fn writeHeader(writer: *std.Io.Writer, header: Header) !void {
    try writer.writeAll(MAGIC);
    try writer.writeInt(u16, header.version, .little);
    try writer.writeAll(header.check_sum);
    try writer.writeByte(header.arch);
    try writer.writeByte(header.endian);
    try writer.writeByte(header.os);
}
