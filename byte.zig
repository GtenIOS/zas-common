const std = @import("std");
pub inline fn intToLEBytes(comptime T: type, int: T) ![]const u8 {
    switch (@typeInfo(T)) {
        .Int => |info| if (info.signedness == std.builtin.Signedness.signed) return error.InvalidIntType else {
            if (info.bits == 8) {
                return &[_]u8{int};
            } else if (info.bits == 16) {
                return &[_]u8{ @intCast(u8, int & 0x00ff), @intCast(u8, (int >> 8)) };
            } else if (info.bits == 32) {
                return &[_]u8{ @intCast(u8, int & 0x000000ff), @intCast(u8, (int >> 8) & 0x000000ff), @intCast(u8, (int >> 16) & 0x000000ff), @intCast(u8, (int >> 24) & 0x000000ff) };
            } else if (info.bits == 64) {
                return &[_]u8{ @intCast(u8, int & 0x00000000000000ff), @intCast(u8, (int >> 8) & 0x00000000000000ff), @intCast(u8, (int >> 16) & 0x00000000000000ff), @intCast(u8, (int >> 24) & 0x00000000000000ff), @intCast(u8, (int >> 32) & 0x00000000000000ff), @intCast(u8, (int >> 40) & 0x00000000000000ff), @intCast(u8, (int >> 48) & 0x00000000000000ff), @intCast(u8, (int >> 56) & 0x00000000000000ff) };
            } else return error.UnsupportedIntSize;
        },
        else => return error.NotAnIntegerType,
    }
}
