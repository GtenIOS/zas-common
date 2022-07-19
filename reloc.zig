const Section = @import("section.zig").Section;

pub const RelocType = enum {
    Rela,
    Abs,    
};

pub const Relocation = struct {
    loc: u32,    // Location(in `.text` section) where relocation is used
    ofst_in_sec: u32, // Relocatable symbol's offset in it's respective section
    sec: *const Section,    // Symbol's origin section
    size: u4,    // Relocation address size in bytes, (1, 2, 4, or 8)
    type: RelocType,    // Relocation type
};
