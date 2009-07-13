

import stream;
import "dl";

namespace Test171 {
    use System.Object;
    use System.Class;
    use System.String;

    class Main {
	void init() {
	    IO.Std.err.FlushOnPrintln = true;
	    IO.Std.err.println( "dlopen..." );
	    word h = cast word(native.dlopen( `/home/degs/lang/llc/ltest/test.so`,1));

	    IO.Std.err.println( "result: " + cast int(h) );
	    IO.Std.err.println( "result is: " + dlerror() );

	    IO.Std.err.println( "dlsym..." );
	    word v = cast word( native.dlsym( h, `vtable$__Q27Test1704Test` ) );

	    IO.Std.err.println( "result: " + cast int(v) );
	    IO.Std.err.println( "result is: " + dlerror() );

	    if( v != 0w ) {
		Class c = new Class( cast int ptr ptr(v) );
		IO.Std.err.println( "class: " + c );

		Object o = c.create();

		IO.Std.err.println( "have: " + cast int(o) );
		IO.Std.err.println( "object: " + o );
	    }
	}

	String dlerror() {
	    char ptr s = cast char ptr(native.dlerror());
	    if( s != null ) {
		native.printf( `dlerror %s\n`, s );
		return new String( s );
	    } else {
		return "OK";
	    }
	}
    }
}