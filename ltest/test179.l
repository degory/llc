#C

import stream;
import compiler;
import library;

namespace Test179 {
    use System.Object;
    use System.Class;
    use System.Compiler;
    use System.Library;

    class Main {	
	void init() {	    
	    IO.Std.err.FlushOnPrintln = true;

	    /// open the L compiler shared object:
	    var llc = new Library( "../llc.so" );
                                      
	    /// find the compiler class:
	    Class c = llc.loadClass( "Parse.Compiler" );

	    IO.Std.err.println( "loaded class: " + c );

	    /// create an instance of the compiler:
	    Object o = c.create();
	    IO.Std.err.println( "created instance: " + o );

	    var compiler = cast Compiler(o);

	    IO.Std.err.println( "compiler is: " + compiler );

	    /// call the compiler to compile a test program:
	    compiler.run( { "llc", "test27.l" } );
	}
    }
}

