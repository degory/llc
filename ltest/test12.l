
namespace Test12 {
    class Main {
        void init() {
	    TestA a = new TestA(111, 222, 333);

	    a.test(444,555,666);
	    a.test(777,888,999);
	}
    }

    class TestA {
	void test(int i, int j, int k) {
	    native.printf( `test a: %lx, %d, %d, %d\n`, this, i, j, k );
	    native.printf( `test a: %lx, %d, %d, %d\n`, this, i, j, k );
	    native.printf( `test a: %lx, %d, %d, %d\n`, this, i, j, k );	    
	}

	void init(int i, int j, int k) {
	    native.printf( `init a: %lx, %d, %d, %d\n`, this, i, j, k );
	    native.printf( `init a: %lx, %d, %d, %d\n`, this, i, j, k );
	    native.printf( `init a: %lx, %d, %d, %d\n`, this, i, j, k );
	}
    }

    class TestB extends TestA {
	void init( int i, int j, int k ) {
	    native.printf( `init b: %lx, %d, %d, %d\n`, this, i, j, k );
	    native.printf( `init b: %lx, %d, %d, %d\n`, this, i, j, k );
	    native.printf( `init b: %lx, %d, %d, %d\n`, this, i, j, k );
	}

	void test( int i, int j, int k ) {
	    native.printf( `test b: %lx, %d, %d, %d\n`, this, i, j, k );
	    native.printf( `test b: %lx, %d, %d, %d\n`, this, i, j, k );
	    native.printf( `test b: %lx, %d, %d, %d\n`, this, i, j, k );	    
	}
    }
}