

namespace System {
    pragma NoWarnUnsafe, NoMarkUnsafe, NoWarnHide, NoWarnResolve;

    /// proc reference values can be converted to appropriate specializations of this type
    /// \param P a proc reference type
    class Proc<P> {
	/// address of static method (if this is a static proc reference) or thunk (if this is a bound proc reference)
	char ptr f0;
	/// address of object this proc is bound to, if any
	char ptr d;
	/// dynamic method to call if this is a bound proc reference
	char ptr f1;

	//void init(P p) {	    
	//}

	/// create a static proc reference pointing to the specified address, which must be the address of a static method with 
	/// the correct signature
	/// \attention this method is completely unsafe
	void init(word f) {
	    f0 = cast char ptr(f);
	}

	///void init() {
	///}

	/// accessor: get P Proc
	/// get this Proc<P> as a P 
	get P Proc {
	    return cast<P>(this);
	}

	String toString() {
	    var cn = Class.Name;

	    var from = cn.indexOf('<');
	    var to = cn.lastIndexOf('>');
	    if( from >= 0 && to >= 0 ) {
		cn = cn.substring(from+1, to);
	    }

	    return cn + " @" + String.hex(cast word(this));
	}
    }
}