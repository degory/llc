#C
import args;
import stream;

namespace Test63 {
    class Main {
        void init() {
	    System.String[] args = System.Arguments.getProgramArguments();

	    for( int i = 0; i < args.length; i = i + 1 ) {
		IO.Std.err.println( "arg #" + i + ": " + args[i] );
	    }
	}
    }
}