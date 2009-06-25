
import stream;
import args;

namespace Test122 {
    class Main {
	void init() {
	    System.String[] env = System.Arguments.ProgramEnvironment;

	    for( int i = 0; i < env.length; i = i + 1 ) {
		IO.Std.err.println( env[i] );
	    }
	}
    }
}