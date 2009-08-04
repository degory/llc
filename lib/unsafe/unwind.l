
namespace System {
    /// Steps through stack unwind information for all methods in program
    struct UnwindInfo {
	const int UNWIND_SIZE = 6; // in machine words
	
	// these are public but as unwind data is stored in .readonly segment
	// attempts to alter will cause a MemoryProtectionException:
	public word method_start;
	public word method_length;
	public char ptr method_name;
	public LineInfo line_numbers;
	public word flags;
	public word ro_size;

	/// Accessor: static get UnwindInfo First
	/// Get the UnwindInfo struct referring to the first method in the program
	static get UnwindInfo First {
	    return cast UnwindInfo(native.__get_unwind_start());
	}

	/// Accessor: get UnwindInfo Next
	/// Get the UnwindInfo struct referring to the next method in the program after this one
	get UnwindInfo Next {
	    // have no pointer arithmetic on structs so:
	    return cast UnwindInfo(cast word ptr(this) + UNWIND_SIZE);
	}
    }

    /// Steps through line number information for all source program lines in a method
    struct LineInfo {
	const int LINEINFO_SIZE = 2;

	// these are public but as unwind data is stored in .readonly segment
	// attempts to alter will cause a MemoryProtectionException:
        public word address;
	public word line_number;

	/// Return the LineInfo struc for the next program line following this one
	LineInfo next() {
	    // have no pointer arithmetic on structs so:
	    return cast LineInfo(cast word ptr(this) + LINEINFO_SIZE);
	}
    }
}