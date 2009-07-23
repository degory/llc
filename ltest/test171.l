

import args;
import stream;
import gproc;
import "dl";

namespace Dynamic {
    use System.Object;
    use System.Class;
    use System.String;
    use System.Proc;

    class LoadTest {

	get Object Value {
	    pragma NoFinal;

	    return "override me";
	}
    }

    class Main {
	void init() {	    
	    String[] args = System.Arguments.ProgramArguments;

	    if( args.length < 2 ) {
		IO.Std.err.println( "usage: " + args[0] + " <so-name>... <class-name>" );
		System.Exit.exit(1);
	    }

	    IO.Std.err.FlushOnPrintln = true;

	    int i;
	    Library l;
	    for( i = 1; i < args.length-1; i = i + 1 ) {
		l = new Library( args[i] );
	    }

	    Class c = l.loadClass( args[i] );

	    IO.Std.err.println( "loaded class: " + c );

	    Object o = c.create();
	    IO.Std.err.println( "created instance: " + o );

	    LoadTest t = cast LoadTest(o);

	    IO.Std.err.println( "load test value is: " + t.Value );
	}

    }

    class Library {
	word h;
	String so_name;

	void init( String so_name ) {
	    if( !so_name.endsWith(".so") ) {
		so_name = so_name + ".so";
	    }

	    if( !so_name.startsWith('/') ) {
		so_name = IO.File.WorkingDirectory + "/" + so_name;
	    }

	    this.so_name = so_name;

	    h = cast word(native.dlopen(so_name.toCString(),257)); // 257 = lazy binding + make symbols global 

	    if( h == 0w ) {
		throw new System.Exception( "could not open library " + so_name + ": " + dlerror() );
	    }
	}

	Class loadClass( String vtable ) {
	    if( vtable == null ) {
		throw new System.Exception( "no get vtable function supplied" );
	    }

	    // look up get vtable function in the just loaded library:
	    word v = cast word( native.dlsym( h, vtable.toCString() ) );

	    if( v == 0w ) {
		// failing that search all libraries:
		v = cast word( native.dlsym( 0, vtable.toCString() ) );
	    }

	    if( v != 0w ) {
		// make a new proc reference from the get vtable function that returns the odd type
		// expected by System.Class.init():
		var p = new Proc<int ptr ptr proc()>(v);

		// create a new class from the vtable returned by the get vtable function:
		Class c = new Class( p() );

		return c; 
	    } else {
		throw new System.Exception( "no class " + vtable + " found in library " + so_name + ": " + dlerror() );
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