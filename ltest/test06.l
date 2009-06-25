
namespace Test6 {
    class Main {
	void init() {
	    native.puts( `starting up...` );

	    TestA a = new TestA();

	    native.printf( `new TestA: %lx\n`, a );
	}
    }

    class TestA {
	void init() {
	    native.printf( `new TestA: %lx\n`, this );
	}
    }
}