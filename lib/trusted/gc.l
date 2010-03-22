#K

namespace System is
    use Generic.List;
    use Generic.Vector;

    /// Gives information about the state of the garbage collected heap
    class GC is
        /// Return the size of the heap in bytes
        static get int HeapSize is
            return cast int(native.GC_get_heap_size());
	si

	static set int MaxHeapSize = s is
	    native.GC_set_max_heap_size(s);
	si

	/// Return amount of free space in the heap in bytes
        static get int HeapFree is
	    return cast int(native.GC_get_free_bytes());
	si

	/// Return amount of used space in the heap in bytes
	static get int HeapUsed is
	    return HeapSize - HeapFree;
        si

	static void collect() is
	    native.GC_gcollect();
	si    

        static void disable() is
	    native.GC_disable();
	si

	static void enable() is
	    native.GC_enable();
	si

        static word ptr getBaseQuiet(word ptr p) is
	    var b = cast word ptr(native.__native_thunk(native.__get_GC_base(),p));	    
	    IO.Std.err.println( String.hex(cast word(p)) + ": base is " + String.hex(cast word(b)) );

	    return b;
	si

        static int getSizeQuiet(word ptr p) is
	    return cast int(native.__native_thunk(native.__get_GC_size(),p));		
	si

        static word ptr getBase(word ptr p) is
	    try
		return getBaseQuiet(p);
	    catch MemoryException me
	        return null;
	    yrt
	si

        static int getSize(word ptr p) is
	    try
                return getSizeQuiet(p);
	    catch MemoryException me 
	        return 0;
	    yrt
	si

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
	si
    si

    struct GCRoot is
        word low;
	word high;

	void init( word l, word h ) is
	    low = l;
	    high = h;
	si

	get word Low is
	    return low;
	si

	get word High is
	    return high;
	si

	String toString() is
	    return String.hex(low) + ".." + String.hex(high);
	si

        bool operator =~(GCRoot u) is
	    return this == u;
	si

	int operator >(GCRoot u) is
	    return Word.operator >(cast word(this), cast word(u));
	si
    si
si