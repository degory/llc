#C
import stream;

namespace Test93 {
    class Main {
	void init() {
	    Stack<System.String> s = new Stack<System.String>(30);
	    Stack<int> t = new Stack<int>(30);
	    
	    s.push( "!" );
	    s.push( "world" );
	    s.push( " " );
	    s.push( "Hello" );
	    
	    for(
		StackIterator<System.String> i = s.Iterator;
		i.hasMoreElements();
		) {
		
		IO.Std.err.print( i.nextElement() );
	    }

	    IO.Std.err.println( "class is: " + s.Class.Name );


	    t.push( 12 );
	    t.push( 34 );
	    t.push( 56);
	    t.push( 78 );
	    
	    for(
		StackIterator<int> j = t.Iterator;
		j.hasMoreElements();
		) {
		
		IO.Std.err.print( "" + j.nextElement() );
	    }

	    IO.Std.err.println( "class is: " + t.Class.Name );
	}
    }

    class StackIterator<T> {
	Stack<T> v;

	void init( Stack<T> v ) {
	    this.v = v;
	}

	bool hasMoreElements() {
	    return !v.IsEmpty;
	}

	T nextElement() {
	    return v.pop();
	}
    }

    class Stack<T> extends System.Object {
	T[] values;
	int sp;

	void init( int size ) {
	    values = new T[size];
	    sp = -1;
        }

	void push( T t ) {
	    sp = sp + 1;
	    values[sp] = t;
	}

	T pop() {
	    T result = values[sp];
	    sp = sp - 1;
	    return result;
	}

	bool getIsEmpty() {
	    return sp < 0;
	}

	StackIterator<T> getIterator() {
	    return new StackIterator<T>( this );
	}
    }
}