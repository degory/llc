
namespace System {
    /// Constants describing machine name and sizes of primitive integer types
    class Environment {
	public static String getNAME() { return "x86"; }

        public const int
	    WORD_BITS = 32,
	    WORD_MASK = 31,
	    WORD_SHIFT = 5,
	    WORD_TO_BYTE_SHIFT = 2, // WORD_SHIFT - log2(bits in byte)
	    WORD_BYTES = 4,
	    LONG_BITS = 32,
	    LONG_SHIFT = 5,
	    LONG_BYTES = 4,
	    INT_BITS = 32,
	    INT_SHIFT = 5,
	    INT_BYTES = 4;
    }
}