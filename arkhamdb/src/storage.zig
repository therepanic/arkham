const std = @import("std");
const target = @import("target.zig");

pub const Storage = struct {
    io: std.Io,
    file: std.Io.File,

    pub fn init(io: std.Io, file: std.Io.File, config: Config) !Storage {
        var buf: [64]u8 = undefined;
        const writer = file.writer(io, buf[0..]).interface;
        const header: Header = .{ .check_sum = config.check_sum, .arch = config.arch, .endian = config.endian, .os = config.os };
        try writeHeader(&writer, header);
        try writer.flush();
        try file.setLength(io, 2 * 4096);
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

const BranchHeader = struct {
    from_offset: u64,
    delta_offset: u64,
};

const Delta = struct { insn_vaddr: u64, write: Write };

const WriteType = enum(u8) {
    reg = 0,
    mem = 1,
    syscall = 2,
};
const Write = union(WriteType) { reg: RegWrite, mem: MemWrite, syscall: SysCall };

const RegWrite = struct { idx: u8, size: u8, value: [*]const u8 };

const MemWrite = struct { addr: u64, size: u64, data: [*]const u8 };

const SysCall = struct { num: u64, args: [8]u64 };
