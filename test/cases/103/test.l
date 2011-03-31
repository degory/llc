#C
import stream;

namespace Test103 {
    use System.Class;

    namespace Test {
	class Main extends System.Object {
	    void init() {
		Test0 t = new Test0(123);
		t.Main = 456;
		IO.Std.err.println( "t.Main: " + t.Main );
	    }
	}
	
	class Test0 extends System.Object {
	    int m;
	    Class c, d;
	    public static int t = 789;
	    
	    void init( int m ) {
		Main = m;
		c = Class;
		d = new Class();

		IO.Std.err.println( "test0: " + Test0 );
	    }
	    
	    void setMain( int m ) {
		this.m = m;
	    }
	    
	    int getMain() {
		return m;
	    }

	    int getTest0() {
		return t;
	    }
	}
    }
}