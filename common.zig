pub const symbol = @import("symbol.zig");
pub const section = @import("section.zig");
pub const byte = @import("byte.zig");
pub const imm = @import("imm.zig");
pub const reloc = @import("reloc.zig");
pub const OperatingMode = enum(u3) {
    Bits16 = 1 << 0,
    Bits32 = 1 << 1,
    Bits64 = 1 << 2,
};
