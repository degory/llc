import stream;

namespace Test90 {
    class Main {
	void init() {
	    Stack<int> s = new Stack<int>(10);
	    Stack<char> t = new Stack<char>(10);
	    Stack<System.String> u = new Stack<System.String>(10);

	    s.push(1);
	    s.push(2);

	    IO.Std.err.println( "pop s: " + s.pop() );
	    IO.Std.err.println( "pop s: " + s.pop() );

	    t.push('A');
	    t.push('B');

	    IO.Std.err.println( "pop t: " + t.pop() );
	    IO.Std.err.println( "pop t: " + t.pop() );

	    u.push("Hello");
	    u.push("World");

	    IO.Std.err.println( "pop u: " + u.pop() );
	    IO.Std.err.println( "pop u: " + u.pop() );
	}
    }


    class Stack<T> {
	T[] values;
	int sp;
	void init(int l) {
	    values = new T[l];
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
    }
}