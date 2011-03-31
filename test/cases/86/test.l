#C
import stream;

namespace Test86 {
    class Main {
	void init() {

	}
    }    

    class Test {
	int test0(int i) {
	    return test1(i);
	}

	int test1(int i) { 
	    return test2(i);
	}

	int test2(int i) {
	    return i + i;
	}
    }
}