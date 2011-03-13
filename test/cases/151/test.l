#C


import stream;

namespace Test151 {
    interface IFace<T> {
	void test(T v);
    }

    class Test<T> extends System.Object implements IFace<T> {
	void init() { }
	void test(T v);
    }

    class Main {
	Test<int> t;
	IFace<System.String> s;

	void init() {
	    Test<System.Object> o;
	    IFace<char> c;
	}
    }
}