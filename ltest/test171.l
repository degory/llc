

import stream;
import "dl";

namespace Test171 {
    use System.Object;
    use System.Class;
    use System.String;

    class Main {
	void init() {
	    IO.Std.err.FlushOnPrintln = true;
	    
	    Class c = loadClass( "Test170.Test" );

	    IO.Std.err.println( "loaded class: " + c );

	    Object o = c.create();

	    IO.Std.err.println( "created instance: " + o );
	}

	Class loadClass( String file_name ) {
	    if( !file_name.startsWith('/') ) {
		file_name = "/tmp/lcache-amd64/" + file_name;
	    }

	    if( !file_name.endsWith(".so") ) {
		file_name = file_name + ".so";
	    }

	    word h = cast word(native.dlopen(file_name.toCString(),1)); // 1 = lazy binding

	    if( h == 0w ) {
		throw new System.Exception( "could not open library " + file_name + ": " + dlerror() );
	    }

	    word v = cast word( native.dlsym( h, `__vtable` ) );

	    if( v != 0w ) {
		Class c = new Class( cast int ptr ptr(v) );

		return c; 
	    } else {
		throw new System.Exception( "no class found in library " + file_name + ": " + dlerror() );
	    }
	}

	String dlerror() {
	    char ptr s = cast char ptr(native.dlerror());
	    if( s != null ) {
		native.printf( `dlerror %s\n`, s );
		return new String( s );
	    } else {
		return "no error";
	    }
	}
    }
}