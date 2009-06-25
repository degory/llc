namespace Test37 {
    class Main {
        void init() {
	}

	static void test0( int i, int j, int k, int l ) {
	    test1( l, k, j, i );
	}

	static void test1( int i, int j, int k, int l ) {
	    test0( i, k, j, l );
	}

	static void test3( int i, int j, int k, int l ) {
	    test0( k, i, j, l );
	}

	static void test4( int i, int j, int k, int l ) {
	    test0( j, l, k, i );
	}

	static void test5( int i, int j, int k, int l, int m, int n ) {
	    test5( j, i, l, k, n, m );
	}

	static void test6( int i, int j, int k, int l, int m, int n ) {
	    test5( j, l, l, l, l, m );
	}
    }
}