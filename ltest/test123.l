
import stream;
import envmap;

namespace Test123 {
    class Main {
	void init() {
	    var m = Util.ProgramEnvironment.Map;

	    foreach( Generic.MapPair<System.String,System.String> e; m.pairs() ) {
		IO.Std.err.println( "'" + e.key + "' -> '" + e.value + "'" );
	    }
	}
    }
}