#K

import object;
import exception;
// import iterator;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace Util is
    /// A resizeable array of integers
    /// \deprecated Use Generic.Vector<int>    
    class IntVector isa Generic.Vector<int> is
	/// Construct an IntVector with enough space for at least l values
	/// \param l how many values to initially allocate space for
	void init( int l ) is
	    super.init(l);
	si

	/// Construct an IntVector with default initial capacity
	void init() is
	    super.init();
	si
    si
si
