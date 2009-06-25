
import stream;

namespace Test147 {
    class IStack<T> {
        void push(T v) { }

	T pop() { }

	T top() { }
    }


    class Stack<T> extends System.Object implements IStack<T> {
	T[] values;
	int sp;

	void init(int size) {
	    values = new T[size];
	    sp = -1;
	}

	void push(T v) {
	    sp = sp + 1;
	    values[sp] = v;
	}

	T pop() {
	    T result = values[sp];
	    sp = sp - 1;
	    return result;
	}

	T top() {
	    return values[sp];
	}	   
    }

    class Main {
	void init() {
	    IStack<int> s = new Stack<int>(10);

	    int i;
	    for( i = 0; i < 10; i = i + 1 ) {
		s.push(i);
	    }

	    for( i = 0; i < 10; i = i + 1 ) {
		IO.Std.err.println( "at " + i + ": " + s.pop() );
	    }
	}
    }
}