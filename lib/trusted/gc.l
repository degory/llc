#K

namespace System is
    class GC is
        static get int HeapSize is
            return cast int(native.GC_get_heap_size());
	end

        static get int HeapFree is
	    return cast int(native.GC_get_free_bytes());
	end

	static get int HeapUsed is
	    return HeapSize - HeapFree;
        end
    end
end