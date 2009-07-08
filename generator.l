// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved
import mtree;
import mblock;
import mframe;

namespace Gen {
    class CodeGenerator {
        static Selector selector;
        Util.Vector list;

	IO.Writer output;

        void init( IO.Writer o ) {
            list = new Util.Vector();
	    output = o;
        }

        static MTree walk( int goal, ITree t ) {
	    if( selector == null ) {
		selector = new Selector();
	    }

	    // IO.Std.err.println( "walk non-terminal #" + goal + " from " + t );

            int ern = selector.rule( t.GenState, goal );
            // IO.Std.err.println( "matched ern " + ern + ", getting nts[]..." );

	    if( ern == 0 ) {
		throw new System.Exception( "no machine pattern for: " + t );
	    }

            int[] nts = selector.getNTS( ern );
            
            // IO.Std.err.println( "got " + nts.length + " terminals" );

            ITree[] children = selector.kids( t, ern );
            // IO.Std.out.println( "got " + children.length + " children" );
            MTree[] mtree = new MTree[children.length];
            
            for( int i = 0; i < nts.length; i = i + 1 ) {
                mtree[i] = walk( nts[i], children[i] );
                // IO.Std.out.println( "mtree[" + i + "] = " + mtree[i].dump() );
            }
            
            // IO.Std.out.println( "calling getMTree for rule " + ern + ", tree " + t + " and " + mtree.length + " children" );
            
            MTree result = selector.getResult( ern, t, mtree );
            
            return result;
        }

	static void label( ITree t ) {
	    selector.label(t);
	}

	static bool isValidInstruction( ITree t ) {
	    return tryGenInstruction( t, null, false, false );
	}

	static void genInstructionInto( ITree t, Util.Vector v ) {
	    tryGenInstruction( t, v, true, true );	    
	}

	static bool tryGenInstruction( ITree t, Util.Vector v, bool output, bool rethrow ) {
	    try {
		selector.label(t);

		// IO.Std.out.println( "labelled\nwalking..." );
		MTree result = walk( 1, t );

		if( output ) {
		    MFlatten f = new MFlatten(t);
		    result.rewrite(f);
		    
		    f.dump(v);
		}

		return true;

	    } catch( System.Exception e ) {
		if( rethrow ) {
		    IO.Std.err.println( "not a valid instruction: " + t + " " + e );
		    throw e;
		}
		return false;
	    }
	}

	MInst genSingleInstruction( ITree t ) {
	    list.setLength(0);

	    if( tryGenInstruction(t, list, true, false) ) {
		if( list.Length == 1 ) {
		    return cast<MInst>(list[0]);
		}
	    }
	    
	    return null;
	}



	bool tryGenInstruction( ITree t ) {
	    return tryGenInstruction( t, list, true, false );
	}

        void gen( ITree t ) {
	    tryGenInstruction( t, list, true, true );

	    // output.println( "# from tree: " + t );
	}

	void add( MInst i ) {
	    list.add( i );
	}

        bool genMethod(int attempt, int local_depth, int ref frame_flags ) {
	    // IO.Std.err.println( "Machine genMethod..." );
	    MInst head = null;

	    head = MBlock.makeList( list );

	    // IO.Std.err.println( "Machine genMethod(): build flow\n" );
	    MFlow flow = new MFlow();

	    if( !flow.build(attempt, head, local_depth) ) {
		// IO.Std.err.println( "build failed" );
		return false;
	    }

	    // IO.Std.err.println( "filling frame..." );
	    MFrame m = new MFrame();
	    flow.addInto(m);

	    // IO.Std.err.println( "fixup frame..." );
	    
	    m.fixup();

	    // IO.Std.err.println( "output..." );
	    m.output(output);

	    frame_flags = m.Flags;

	    return true;
        }
    }
}
