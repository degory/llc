#C
import stream;

namespace Test135 {
    class Main {
	void init() {
	    Test t = new Test();
	    t.check();
	    int ptr tw = cast int ptr(t);
	    int ptr uw = cast int ptr(t.clone());

	    IO.Std.err.println( "[tw+0]" + System.String.hex([tw + 0]) );
	    IO.Std.err.println( "[tw+1]" + System.String.hex([tw + 1]) );

	    IO.Std.err.println( "[tw+0]" + System.String.hex([tw + 0]) );
	    IO.Std.err.println( "[tw+1]" + System.String.hex([tw + 1]) );

	    Test u = cast Test(uw);
	    u.check();
	}
    }

    class Test extends System.Object {
	word a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z;

	void init() {
	    a = 0xAAAAAAA0AAAAAA1w;
	    b = 0xBBBBBBB0BBBBBB2w;
	    c = 0xCCCCCCC0CCCCCC3w;
	    d = 0xDDDDDDD0DDDDDD4w;
	    e = 0xEEEEEEE0EEEEEE5w;
	    f = 0xFFFFFFF0FFFFFF6w;
	    g = 0x000000000000007w;
	    h = 0x111111101111118w;
	    i = 0x222222202222229w;
	    j = 0x333333303333310w;
	    k = 0x444444404444411w;
	    l = 0x555555505555512w;
	    m = 0x666666606666613w;
	    n = 0x777777707777714w;
	    o = 0x888888808888815w;
	    p = 0x999999909999916w;
	    q = 0xAAAAAAA0AAAAA17w;
	    r = 0xBBBBBBB0BBBBB18w;
	    s = 0xCCCCCCC0CCCCC19w;
	    t = 0xDDDDDDD0DDDDD20w;
	    u = 0xEEEEEEE0EEEEE21w;
	    v = 0xFFFFFFF0FFFFF22w;
	    w = 0x000000000000023w;
	    x = 0x111111101111124w;
	    y = 0x222222202222225w;
	    z = 0x333333303333326w;
	}
	
	void check() {
	    IO.Std.err.println( "a: " + cast int(a) );
	    IO.Std.err.println( "b: " + cast int(b) );
	    IO.Std.err.println( "c: " + cast int(c) );
	    IO.Std.err.println( "d: " + cast int(d) );
	    IO.Std.err.println( "e: " + cast int(e) );
	    IO.Std.err.println( "f: " + cast int(f) );
	    IO.Std.err.println( "g: " + cast int(g) );
	    IO.Std.err.println( "h: " + cast int(h) );
	    IO.Std.err.println( "i: " + cast int(i) );
	    IO.Std.err.println( "j: " + cast int(j) );
	    IO.Std.err.println( "k: " + cast int(k) );
	    IO.Std.err.println( "l: " + cast int(l) );
	    IO.Std.err.println( "m: " + cast int(m) );
	    IO.Std.err.println( "n: " + cast int(n) );
	    IO.Std.err.println( "o: " + cast int(o) );
	    IO.Std.err.println( "p: " + cast int(p) );
	    IO.Std.err.println( "q: " + cast int(q) );
	    IO.Std.err.println( "r: " + cast int(r) );
	    IO.Std.err.println( "s: " + cast int(s) );
	    IO.Std.err.println( "t: " + cast int(t) );
	    IO.Std.err.println( "u: " + cast int(u) );
	    IO.Std.err.println( "v: " + cast int(v) );
	    IO.Std.err.println( "w: " + cast int(w) );
	    IO.Std.err.println( "x: " + cast int(x) );
	    IO.Std.err.println( "y: " + cast int(y) );
	    IO.Std.err.println( "z: " + cast int(z) );	
	}
    }
}