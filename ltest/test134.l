#C

import stream;
import gvector;

namespace Test134 {
    use Use.NoArgsUseNamespace;
    use Use.OneArgUseNamespace;
    use System.String;


    class NoArgsSameNamespace extends System.Object {
	void init() { }
    }

    class OneArgSameNamespace<T> extends System.Object {
	void init() { }
    }

    class A1<T> extends NoArgsSameNamespace {
	void init() { }
    }

    class A2<T> extends Other.NoArgsOtherNamespace {
	void init() { }
    }

    class A3<T> extends NoArgsUseNamespace {
	void init() { }
    }

    class B1<T> extends OneArgSameNamespace<T> {
	void init() { }
    }

    class B2<T> extends Other.OneArgOtherNamespace<T> {
	void init() { }
    }

    class B3<T> extends OneArgUseNamespace<T> {
	void init() { }
    }

    class C1 extends OneArgSameNamespace<String> {
	void init() { }
    }

    class C2 extends Other.OneArgOtherNamespace<String> {
	void init() { }
    }

    class C3 extends OneArgUseNamespace<String> {
	void init() { }
    }

    class D1 extends OneArgSameNamespace {

    }

    class Main {
	void init() {
	    var v = new Generic.Vector<System.Object>();
	    var c = new C1();

	    // var a = new A1<String>();
	    IO.Std.err.println( "have: " + new A1<String>() );
	}
    }

}


namespace Other {
    class NoArgsOtherNamespace extends System.Object {
	void init() { }
    }

    class OneArgOtherNamespace<T> extends System.Object {
	void init() { }
    }
}

namespace Use {
    class NoArgsUseNamespace extends System.Object {
	void init() { }
    }

    class OneArgUseNamespace<T> extends System.Object {
	void init() { }
    }
}