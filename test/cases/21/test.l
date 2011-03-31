#C
namespace Test21 {
    class Main {
	void init() {

	    TestA a;
	    TestB b;

	    a = new TestA(111);
	    b = new TestB(222,333);

	    a.print();
	    b.print();
	    a.print();
	    b.print();
	}

    }

    class TestA {
	int i;
	void init( int i ) {
	    this.i = i;
	    native.printf( `TestA.init(%d)\n`, i );
	}

	void print() {
	    native.printf( `TestA.print, i: %d\n`, i );
	}
    }

    class TestB extends TestA {
	int j;
	void init( int i, int j ) {
	    super.init( i );
	    this.j = j;
	    native.printf( `TestB.init(%d)\n`, j );
	}

	void print() {
	    super.print();
	    native.printf( `TestB.print, j: %d\n`, j );
	}
    }
}