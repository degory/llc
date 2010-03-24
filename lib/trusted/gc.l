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

	/// Set the maximum allowable heap size 
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

	/// Force a garbage collection now
	static void collect() is
	    native.GC_gcollect();
	si    

	/// Disable garbage collection. This increments a counter and an equal
	/// number of calls to enable are required to re-enable collection.
        static void disable() is
	    native.GC_disable();
	si

	/// Disable garbage collection. This decrements the counter that is
	/// incremented by disable. Collection is reenabled when this counter
	/// is decremented to zero
	static void enable() is
	    native.GC_enable();
	si

	/// Get a pointer to the first word in a value stored in the heap
	/// \param p pointer to a value on the heap
	/// \return a pointer to the first word in the value
	/// \throw MemoryException if p is not a valid pointer into the heap
        static word ptr getBaseQuiet(word ptr p) is
	    var b = cast word ptr(native.__native_thunk(native.__get_GC_base(),p));	    
	    IO.Std.err.println( String.hex(cast word(p)) + ": base is " + String.hex(cast word(b)) );

	    return b;
	si

	/// Get size in bytes of  a value stored in the heap
	/// \param p pointer to a value on the heap
	/// \return a size of the value in bytes
	/// \throw MemoryException if p is not a valid pointer into the heap
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

        /// Get the current list of garbage collection roots. These are areas scanned for
	/// pointers to garbage collected values other than the standard areas (stack,
	/// machine registers, data segments of main program and shared objects)
	/// \return list of roots
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

    /// a garbage collection root area    
    struct GCRoot is
        word low;
	word high;

	/// Construct a new GCRoot covering a given memory region
	/// \param l address of first word in root region  
	/// \param h address of last word in root region
	void init( word l, word h ) is
	    low = l;
	    high = h;
	si

	/// Get address of first word in this root region
	get word Low is
	    return low;
	si

	/// Get address of last word in this root region
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