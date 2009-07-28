import library;

namespace System {
    class Compiler {
	static Class c;

	void init() { }
	int run( String[] args ) {
	    pragma Virtual;
	}

	static get Compiler Create {
	    if( c == null ) {
		var l = new Library("/usr/lang/lib/unsafe/llc.so");
		c = l.findClass( "Parse.Compiler" );
	    }
	    return cast Compiler(c.create());
	}
    }
}