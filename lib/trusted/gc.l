#K

namespace System is
    use Generic.List;
    use Generic.Vector;

    /// Gives information about the state of the garbage collected heap
    class GC is
        /// Return the size of the heap in bytes
        static get int HeapSize is
            return cast int(native.GC_get_heap_size());
	end

	static set int MaxHeapSize = s is
	    native.GC_set_max_heap_size(s);
	end

	/// Return amount of free space in the heap in bytes
        static get int HeapFree is
	    return cast int(native.GC_get_free_bytes());
	end

	/// Return amount of used space in the heap in bytes
	static get int HeapUsed is
	    return HeapSize - HeapFree;
        end

	static void collect() is
	    native.GC_gcollect();
	end    

        static void disable() is
	    native.GC_disable();
	end

	static void enable() is
	    native.GC_enable();
	end

        static word ptr getBaseQuiet(word ptr p) is
	    var b = cast word ptr(native.__native_thunk(native.__get_GC_base(),p));	    
	    IO.Std.err.println( String.hex(cast word(p)) + ": base is " + String.hex(cast word(b)) );

	    return b;
	end

        static int getSizeQuiet(word ptr p) is
	    return cast int(native.__native_thunk(native.__get_GC_size(),p));		
	end

        static word ptr getBase(word ptr p) is
	    try
		return getBaseQuiet(p);
	    catch MemoryException me
	        return null;
	    yrt
	end

        static int getSize(word ptr p) is
	    try
                return getSizeQuiet(p);
	    catch MemoryException me 
	        return 0;
	    yrt
	end

	static get List<GCRoot> Roots is
	    var result = new Vector<GCRoot>();

            word ptr roots = cast word ptr(native.__get_roots());

	    if roots == null then
	        return result;
	    fi

	    while [roots] != 0W do
		result.add( new GCRoot( [roots], [roots+1] ) );
	        roots = roots + 2;
	    od

	    return result;
	end
    end

    struct GCRoot is
        word low;
	word high;

	void init( word l, word h ) is
	    low = l;
	    high = h;
	end

	get word Low is
	    return low;
	end

	get word High is
	    return high;
	end

	String toString() is
	    return String.hex(low) + ".." + String.hex(high);
	end

        bool operator =~(GCRoot u) is
	    return this == u;
	end

	int operator >(GCRoot u) is
	    return Word.operator >(cast word(this), cast word(u));
	end
    end
end