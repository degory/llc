#C
namespace Test25 {
    class Main {
	void init() {
	    ClassA a = new ClassA();
	    ClassB b = new ClassB();

	    a.test0();
	    b.test0();

	    System.String s = new System.String( `testing A, B, C` );
	}
    }

    class ClassA extends System.Object {
	void init() {
	    super.init();
	}

	void test0() {
	    native.printf( `testing testing 1, 2, 3` );
	}
    }

    class ClassB extends ClassA {
	void init() {
	    super.init();
	}
    }
}