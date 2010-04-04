#C
import stream;
import gvector;

namespace Test136 {
    class Main {
	void init() {
	    // var a = new System.StringBuffer[1000];
	    var a = new Generic.Vector<System.StringBuffer>(1000);
	    a.lengthen(1000);
	    for( int i = 0; i < 10000; i = i + 1 ) {
		System.StringBuffer b = new System.StringBuffer();
		a[i % 1000] = b;
		for( int j = 0; j < 10000; j = j + 1 ) {
		    b.append(j);
		}
	    }
	}
    }
}