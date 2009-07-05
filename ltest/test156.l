
namespace Test156 {
    class Main {
	int proc(int,int) compare;

	void init() {
	    test(compare);
	}

	void test( int proc(int,int) c ) {
	    c(111,222);
	}
    }
}