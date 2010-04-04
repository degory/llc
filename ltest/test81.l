#C
// operator call should prevent method inlining
// string constant should be inlineable

import stream;

namespace Test81 {
    class Main {
	void init() {
	    IO.Std.err.println( "test0.0: " + test0() );
	    IO.Std.err.println( "test0.1: " + test0() );
	    IO.Std.err.println( "test1.0: " + test1() );
	    IO.Std.err.println( "test1.1: " + test1() );
	    IO.Std.err.println( "test2.0: " + test2() );
	    IO.Std.err.println( "test2.1: " + test2() );
	}

	// should not be inlined as + results in method call System.String.opAdd:
	System.String test0() {
	    return "test" + 0;
	}

	// should be inlined
	System.String test1() {
	    return "test1";
	}

	System.String test2() {
	    return test1();
	}
    }
}