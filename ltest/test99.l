#K
import stream;

namespace Test99 is
    class Main is
	void init() is
	    int a, b, c;

	    a = 1;
	    b = 2;
	    c = 0;

	    if a =~ 1 then
		IO.Std.err.println( "a =~ 1 (expected)" );
	    else
		IO.Std.err.println( "a !~ 1 (not expected)" );
	    fi

	    if c =~ 0 then
		IO.Std.err.println( "c =~ 0 (expected)" );
	    else
		IO.Std.err.println( "c !~ 0 (not expected)" );
	    fi

	    if a !~ 1 then
		IO.Std.err.println( "a !~ 1 (not expected)" );
	    else
		IO.Std.err.println( "a =~ 1 (expected)" );
	    fi

	    if c !~ 0 then
		IO.Std.err.println( "c !~ 0 (not expected)" );
	    else
		IO.Std.err.println( "c =~ 0 (expected)" );
	    fi
	si
    si
si
