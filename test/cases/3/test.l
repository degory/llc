#C

namespace Test3 {
    class Main extends System.Object {
	void init() {
	    super.init();

	    native.puts( `hello world!\n` );

	    TestA a = new TestA();

	    native.printf( `a = %lx\n`, a );

	    a.testA(1,2,3);
	    native.puts( `after testA\n` );
	    a.test1();

	    native.puts( `after\n` );
	}
    }

    class TestA extends System.Object {
	void init() {
	    super.init();

	    native.printf( `new TestA @ %lx\n`, this );
	}

	void testA(int a, int b, int c) {
	    native.printf( `%lx: TestA.testA(%d,%d,%d)\n`, this, a, b, c );
	}

	void test() {
	    native.puts( `TestA.test()` );
	}

	void test1() {
	    native.puts( `TestA.test1()` );
	}

	void test2() {
	    native.puts( `TestA.test2()` );
	}

	void test3() {
	    native.puts( `TestA.test3()` );
	}
    }

    class TestB extends TestA {
	void init() {
	    super.init();

	    native.puts( `new TestB\n` );
	}

	void test() {
	    native.puts( `TestB.test()` );
	}

	void test1() {
	    native.puts( `TestB.test1()` );
	}

	void test2() {
	    native.puts( `TestA.test2()` );
	}

	void test3() {
	    native.puts( `TestA.test3()` );
	}
    }
}