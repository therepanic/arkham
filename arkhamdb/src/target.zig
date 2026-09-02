//todo: bringing in more content!
pub const Arch = enum(u8) {
    x86 = 0,
    x86_64 = 1,
};

pub const Endian = enum(u8) {
    little = 0,
    big = 1,
};

pub const Os = enum(u8) {
    linux = 0,
};
