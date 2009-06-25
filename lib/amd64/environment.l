
namespace System {
    class Environment {
	public static String getNAME() { return "amd64"; }

        public const int
	    WORD_BITS = 64,
	    WORD_MASK = 63,
	    WORD_SHIFT = 6, // log2(bits in word)
	    WORD_TO_BYTE_SHIFT = 3, // WORD_SHIFT - log2(bits in byte)
	    WORD_BYTES = 8,

	    LONG_BITS = 64,
	    LONG_SHIFT = 6,
	    LONG_BYTES = 8,

	    INT_BITS = 32,
	    INT_SHIFT = 5,
	    INT_BYTES = 4;
    }
}