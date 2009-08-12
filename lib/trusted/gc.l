#K

namespace System is
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
    end
end