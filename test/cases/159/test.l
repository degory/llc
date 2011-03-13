#C

import stream;

namespace Test159 {
    use System.String;

    class Tree {
	static int next_id;

	Tree left;
	Tree right;
	int id;

	void init( Tree left, Tree right ) {
	    this.left = left;
	    this.right = right;

	    id = next_id;
	    next_id = next_id + 1;
	}

	void visit( void proc(Tree) v ) {
	    if( left != null ) {
		left.visit(v);
	    }

	    if( right != null ) {
		right.visit(v);
	    }

	    v(this);
	}
	
	String toString() {
	    return "tree: " + id;
	}
    }

    class Visit {       
	void init() {
	}

	void test(Tree t) {
	    IO.Std.err.println( "from: " + this + " test: " + t );
	}
    }

    class Main {
	System.Proc<void proc(Tree)> p0;
	
	void init() {
	    Tree t =
		new Tree(
			 new Tree(
				  new Tree(
					   new Tree( null, null ),
					   new Tree( null, null )
					   ),
				  new Tree(
					   new Tree( null, null ),
					   new Tree( null, null )
					   )
				  ),
			 new Tree(
				  new Tree(
					   new Tree( null, null ),
					   new Tree( null, null )
					   ),
				  new Tree(
					   new Tree( null, null ),
					   new Tree( null, null )
					   )
				  )
			 );

	    // p0 = cast System.Proc<void proc(Tree)>( proc(Tree)(print) );

	    IO.Std.err.println( "visit print: " );
	    t.visit( proc(Tree)(print) );
	    IO.Std.err.println( "visit test: " );
	    t.visit( proc(Tree)(new Visit().test) );
	}

	void print(Tree t) {
	    IO.Std.err.println( "from: " + this + " print: " + t );
	}    
    }

}