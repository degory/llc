#C
import stream;

namespace Test60 {
    use System.Int;

    class Main {
        void init() {
	    TestB b = new TestB(
				new TestB(
					  new TestB( new Int(1), new Int(2), new Int(3) ),
					  new TestB( new Int(4), new Int(5), new Int(6) ),
					  new TestB( new Int(7), new Int(8), new Int(9) )
					  ),
				new TestB(
					  new TestB( new Int(11), new Int(22), new Int(33) ),
					  new TestB( new Int(44), new Int(55), new Int(66) ),
					  new TestB( new Int(77), new Int(88), new Int(99) )
					  ),
				new TestB(
					  new TestB( new Int(111), new Int(222), new Int(333) ),
					  new TestB( new Int(444), new Int(555), new Int(666) ),
					  new TestB( new Int(777), new Int(888), new Int(999) )
					  )
				);
	}
    }

    class TestA extends System.Object {
	void init( int a, int b, int c ) {
	    IO.Std.err.println( "TestA.init(" + a + "," + b + "," + c + ")" );
	}
    }

    class TestB extends System.Object {
	void init( System.Object a, System.Object b, System.Object c ) {
	    IO.Std.err.println( "TestB.init(" + a + "," + b + "," + c + ")" );
	}
    }
}