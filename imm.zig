const std = @import("std");
const byte = @import("byte.zig");
pub const Imm = union(enum) {
    imm8: u8,
    imm16: u16,
    imm32: u32,
    imm64: u64,
    imm: u64,    // Non-sized, Must be resolved to a sized one before encoding
    const Self = @This();

    pub inline fn matches(self: Self, other: Self) bool {
        switch (self) {
            .imm8 => {
                switch (other) {
                    .imm8, .imm => return true,
                    else => return false,
                }
            },
            .imm16 => {
                switch (other) {
                    .imm16, .imm => return true,
                    else => return false,
                }
            },
            .imm32 => {
                switch (other) {
                    .imm32, .imm => return true,
                    else => return false,
                }
            },
            .imm64 => {
                switch (other) {
                    .imm64, .imm => return true,
                    else => return false,
                }
            },
            else => unreachable,        // Template parameter must never be a non sized variant
        }
    }

    pub inline fn fromISize(ival: isize) Self {
        const uval = @bitCast(usize, ival);
        if (uval <= std.math.maxInt(u8) or ival >= std.math.minInt(i8)) {
            return .{ .imm8 = @intCast(u8, uval) };
        } else if (uval <= std.math.maxInt(u16) or ival >= std.math.minInt(i16)) {
            return .{ .imm16 = @intCast(u16, uval) };
        } else if (uval <= std.math.maxInt(u32) or ival >= std.math.minInt(i32)) {
            return .{ .imm32 = @intCast(u32, uval) };
        } else {
            return .{ .imm64 = @intCast(u64, uval) };
        }
    }

    pub inline fn fromUSize(uval: usize) Self {
        if (uval <= std.math.maxInt(u8)) {
            return .{ .imm8 = @intCast(u8, uval) };
        } else if (uval <= std.math.maxInt(u16)) {
            return .{ .imm16 = @intCast(u16, uval) };
        } else if (uval <= std.math.maxInt(u32)) {
            return .{ .imm32 = @intCast(u32, uval) };
        } else {
            return .{ .imm64 = @intCast(u64, uval) };
        }
    }
    
    pub inline fn toImm(imm: Self, dest_size: u16) !Self {
        switch (dest_size) {
            8 => return Self{ .imm8 = imm.toImm8() },
            16 => return Self{ .imm16 = imm.toImm16() },
            32 => return Self{ .imm32 = imm.toImm32() },
            64 => return Self{ .imm64 = imm.toImm64() },
            else => return error.InvalidImmediateSize,
        }
    }

    pub inline fn size(self: Self) u8 {
        switch (self) {
            .imm8 => return 8,
            .imm16 => return 16,
            .imm32 => return 32,
            .imm64 => return 64,
            .imm => return 0,
        }
    }

    pub inline fn toImm8(self: Self) u8 {
        switch (self) {
            .imm8 => |ival| return ival,
            .imm16 => |ival| return @intCast(u8, ival & 0x00ff),
            .imm32 => |ival| return @intCast(u8, ival & 0x000000ff),
            .imm64, .imm => |ival| return @intCast(u8, ival & 0x00000000000000ff),
        }
    }

    pub inline fn toImm16(self: Self) u16 {
        switch (self) {
            .imm8 => |ival| return ival,
            .imm16 => |ival| return ival,
            .imm32 => |ival| return @intCast(u16, ival & 0x0000ffff),
            .imm64, .imm => |ival| return @intCast(u16, ival & 0x00000000000000ff),
        }
    }

    pub inline fn toImm32(self: Self) u32 {
        switch (self) {
            .imm8 => |ival| return ival,
            .imm16 => |ival| return ival,
            .imm32 => |ival| return ival,
            .imm64, .imm => |ival| return @intCast(u32, ival & 0x00000000ffffffff),
        }
    }

    pub inline fn toImm64(self: Self) u64 {
        switch (self) {
            .imm8 => |ival| return ival,
            .imm16 => |ival| return ival,
            .imm32 => |ival| return ival,
            .imm64, .imm => |ival| return ival,
        }
    }

    pub inline fn updateToSize(self: Self, updated_size: u16) !Self {
        switch (updated_size) {
            8 => return Self{ .imm8 = self.toImm8() },
            16 => return Self{ .imm16 = self.toImm16() },
            32 => return Self{ .imm32 = self.toImm32() },
            64 => return Self{ .imm64 = self.toImm64() },
            else => return error.InvalidSizeConversion,
        }
    }

    pub inline fn fromFloat(fval: f64) Self {
        const uval = @bitCast(usize, fval);
        if (uval <= std.math.maxInt(u32)) {
            return .{ .imm32 = @intCast(u32, uval) };
        } else {
            return .{ .imm64 = @intCast(u64, uval) };
        }
    }

    pub inline fn toNegative(self: Self) !Self {
        switch (self) {
            .imm8 => |ival| {
                if (ival > std.math.maxInt(u8) / 2) return Self{ .imm16 = @bitCast(u16, ~self.toImm16() + 1) } else return Self{ .imm8 = @bitCast(u8, ~self.toImm8() + 1) };
            },
            .imm16 => |ival| {
                if (ival > std.math.maxInt(u16) / 2) return Self{ .imm32 = @bitCast(u32, ~self.toImm32() + 1) } else return Self{ .imm16 = @bitCast(u16, ~self.toImm16() + 1) };
            },
            .imm32 => |ival| {
                if (ival > std.math.maxInt(u32) / 2) return Self{ .imm64 = @bitCast(u64, ~self.toImm64() + 1) } else return Self{ .imm32 = @bitCast(u32, ~self.toImm32() + 1) };
            },
            .imm64, .imm => |ival| {
                if (ival > std.math.maxInt(u64) / 2) return error.NumberTooBig else return Self{ .imm64 = @bitCast(u64, ~self.toImm64() + 1) };
            },
        }
    }

    pub inline fn encode(self: Self) ![]const u8 {
        switch (self) {
            .imm8 => |ival| return byte.intToLEBytes(u8, ival),
            .imm16 => |ival| return byte.intToLEBytes(u16, ival),
            .imm32 => |ival| return byte.intToLEBytes(u32, ival),
            .imm64 => |ival| return byte.intToLEBytes(u64, ival),
            .imm => return error.MustBeResolvedToASizedVariant,
        }
    }

    pub inline fn print(self: Self) void {
        std.log.info("[IMM]: 0x{x}", .{self.toImm64()});
    }
};
