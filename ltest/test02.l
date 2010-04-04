#C

namespace Test2 {
    class Main extends System.Object {
	void init() {
	    native.puts( `hello world!\n` );

	    TestA a = new TestA();
	    a.test();
	}
    }

    class TestA extends System.Object {
	void init() {
	    native.puts( `new TestA\n` );
	}

	void test() {
	    native.puts( `TestA.test()` );
	}
    }
}