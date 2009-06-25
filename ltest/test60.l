import stream;

namespace Test60 {
    use System.Integer;

    class Main {
        void init() {
	    TestB b = new TestB(
				new TestB(
					  new TestB( new Integer(1), new Integer(2), new Integer(3) ),
					  new TestB( new Integer(4), new Integer(5), new Integer(6) ),
					  new TestB( new Integer(7), new Integer(8), new Integer(9) )
					  ),
				new TestB(
					  new TestB( new Integer(11), new Integer(22), new Integer(33) ),
					  new TestB( new Integer(44), new Integer(55), new Integer(66) ),
					  new TestB( new Integer(77), new Integer(88), new Integer(99) )
					  ),
				new TestB(
					  new TestB( new Integer(111), new Integer(222), new Integer(333) ),
					  new TestB( new Integer(444), new Integer(555), new Integer(666) ),
					  new TestB( new Integer(777), new Integer(888), new Integer(999) )
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