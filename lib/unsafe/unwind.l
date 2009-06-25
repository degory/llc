
namespace System {
    struct UnwindInfo {
	const int UNWIND_SIZE = 6; // in machine words
	
	// these are public but as unwind data is stored in .readonly segment
	// attempts to alter will cause a MemoryProtectionException:
	public word method_start;
	public word method_end;
	public char ptr method_name;
	public LineInfo line_numbers;
	public word flags;
	public word ro_size;

	static get UnwindInfo First {
	    return cast UnwindInfo(native.__get_unwind_start());
	}

	get UnwindInfo Next {
	    // have no pointer arithmetic on structs so:
	    return cast UnwindInfo(cast word ptr(this) + UNWIND_SIZE);
	}
    }

    struct LineInfo {
	const int LINEINFO_SIZE = 2;

	// these are public but as unwind data is stored in .readonly segment
	// attempts to alter will cause a MemoryProtectionException:
        public word address;
	public word line_number;

	LineInfo next() {
	    // have no pointer arithmetic on structs so:
	    return cast LineInfo(cast word ptr(this) + LINEINFO_SIZE);
	}
    }
}