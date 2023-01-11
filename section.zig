const std = @import("std");
const Symbol = @import("symbol.zig").Symbol;
pub const SectionType = enum(u32) {
    Text,
    Data,
    Rodata,
    Bss,
    const Self = @This();
    const SectionMap = struct {
        type: SectionType,
        name: []const u8,
    };
    const sections = &[_]SectionMap{
        .{ .type = .Text, .name = "text" },
        .{ .type = .Data, .name = "data" },
        .{ .type = .Rodata, .name = "rodata" },
        .{ .type = .Bss, .name = "bss" },
    };
    inline fn find(name: []const u8) ?Self {
        for (sections) |section| {
            if (std.mem.eql(u8, name, section.name)) return section.type;
        }

        return null;
    }
};

pub const Section = struct {
    idx: u8,
    name: []const u8,
    data: ?std.ArrayList(u8) = null,
    symbols: ?std.ArrayList(*Symbol) = null,
    type: SectionType,
    const Self = @This();

    pub fn initText(idx: u8) Self {
        return Self{ .idx = idx, .name = ".text", .type = .Text };
    }

    pub fn initData(idx: u8) Self {
        return Self{ .idx = idx, .name = ".data", .type = .Data };
    }

    pub fn initRoData(idx: u8) Self {
        return Self{ .idx = idx, .name = ".rodata", .type = .Rodata };
    }

    pub fn initBss(idx: u8) Self {
        return Self{ .idx = idx, .name = ".bss", .type = .Bss };
    }

    pub fn init(name: []const u8, idx: u8) !Self {
        if (SectionType.find(name)) |section_type| {
            switch (section_type) {
                .Text => return initText(idx),
                .Data => return initData(idx),
                .Rodata => return initRoData(idx),
                .Bss => return initBss(idx),
            }
        } else return error.InvalidSectionName;
    }

    pub inline fn size(self: Self) u32 {
        return if (self.data) |d| @intCast(u32, d.items.len) else 0;
    }

    pub inline fn appendSlice(self: *Self, allocator: std.mem.Allocator, bytes: []const u8) !void {
        if (self.data) |*data| {
            try data.appendSlice(bytes);
        } else {
            self.data = std.ArrayList(u8).init(allocator);
            try self.data.?.appendSlice(bytes);
        }
    }

    pub inline fn appendSliceNTimes(self: *Self, allocator: std.mem.Allocator, bytes: []const u8, times: usize) !void {
        var rep = times;
        if (self.data) |*data| {
            while (rep > 0) : (rep -= 1) {
                try data.appendSlice(bytes);
            }
        } else {
            self.data = std.ArrayList(u8).init(allocator);
            while (rep > 0) : (rep -= 1) {
                try self.data.?.appendSlice(bytes);
            }
        }
    }

    pub inline fn replaceRange(self: *Self, allocator: std.mem.Allocator, start: u32, end: u32, bytes: []const u8, times: u32) !void {
        if (self.data) |*data| {
            try data.replaceRange(start, end, bytes);
            if (times > 1) {
                var rep: u32 = 1;
                while (rep < times) : (rep += 1) try data.insertSlice(end + rep * bytes.len, bytes);
            }
        } else {
            self.data = std.ArrayList(u8).init(allocator);
            try self.data.?.appendSlice(bytes);
            if (times > 1) {
                var rep: u32 = 1;
                while (rep < times) : (rep += 1) try self.data.?.appendSlice(bytes);
            }
        }
    }

    pub inline fn addSymbol(self: *Self, allocator: std.mem.Allocator, sym: *Symbol) !void {
        if (self.symbols) |*symbols| {
            try symbols.append(sym);
        } else {
            self.symbols = std.ArrayList(*Symbol).init(allocator);
            try self.symbols.?.append(sym);
        }
    }

    pub fn findSymbol(self: Self, name: []const u8) ?*Symbol {
        if (self.symbols) |symbols| {
            for (symbols.items) |symbol| {
                if (std.mem.eql(u8, symbol.name, name)) return symbol;
            }
        }

        return null;
    }

    pub inline fn deinit(self: *Self) void {
        if (self.data) |*data| data.deinit();
        if (self.symbols) |*symbols| symbols.deinit();
    }
};
