#K

namespace System is
    /// Gives information about the state of the garbage collected heap
    class GC is
        /// Return the size of the heap in bytes
        static get int HeapSize is
            return cast int(native.GC_get_heap_size());
	end

	/// Return amount of free space in the heap in bytes
        static get int HeapFree is
	    return cast int(native.GC_get_free_bytes());
	end

	/// Return amount of used space in the heap in bytes
	static get int HeapUsed is
	    return HeapSize - HeapFree;
        end
    end
end