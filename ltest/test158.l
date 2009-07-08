
import stream;

namespace Test158 {
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

	static void print(Tree t) {
	    IO.Std.err.println( t );
	}
    }

    class Main {
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

	    t.visit( proc(Tree)(Tree.print) );
	}
    
    }

}