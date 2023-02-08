const std = @import("std");
const Section = @import("section.zig").Section;
const Imm = @import("imm.zig").Imm;
pub const Symbol = struct {
    idx: u32,
    name: []const u8,
    imm: ?Imm = null,
    global: bool,
    did_init: bool,
    ofst_in_sec: u32,
    section: *const Section,
    res_size: ?usize = null,
    unknown_idx: ?usize = null,
};
