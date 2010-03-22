#K

namespace Util is
    /// Utility class for combining hash values
    class Hash is
        /// Rotate supplied integer left five bits
	static int rotate( int u ) is
            int result = u << 5;
            return result | ((u >> 27) & 0x1F);
        si

	/// Return a hash of supplied String
	static int hash( System.String s ) is
	    int l = s.getLength();
	    int h = 0;
	    for int i = 0; i < l; i = i + 1 do
		h = rotate(h) + cast int(s.charAt(i));
	    od
	si

	/// Combine to hashes 
	static int hash( int i, int j ) is
	    return rotate(i) + j;
	si
    si
si
