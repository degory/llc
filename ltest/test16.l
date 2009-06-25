
namespace Test16 {
    class Main {
	void init() {
	    System.String s = null;
	    char ptr p = null;

	    if( s == null ) {
		native.puts( `s is null\n` );
	    }

	    if( p == null ) {
		native.puts( `p is null\n` );
	    }
	}
    }
}