namespace Util is
    use System.String;
    use System.StringBuffer;

    use Generic.Bag;
    use Generic.Slice;
    use Generic.Range;
    use Generic.Iterable;
    use Generic.List;
    use Generic.Iterator;

    class CastIterator<T,F> do Iterator<T> is
        Iterator<F> proxy;

	void init(Iterator<F> i) is
	    proxy = i;
	si

        bool hasMoreElements() is
	    return proxy.hasMoreElements();
	si

	T nextElement() is
	    return cast T(proxy.nextElement());
	si

	get Iterator<T> Iterator is
	    return this;
	si
    si

    class CastBag<T,F> do Bag<T> is
        Bag<F> proxy;

	void init( Bag<F> b ) is
	    proxy = b;
	si

        void add( T v ) is
	    proxy.add( cast F(v) );
	si

        void add( Iterable<T> v ) is
	    foreach var i; v do
	        add( i );
	    od
        si

	void remove( T v ) is
	    proxy.remove( cast F(v) );
	si

        bool contains( T v ) is
	    return proxy.contains( cast F(v) );
	si

	bool isEmpty() is
	    return proxy.isEmpty();
	si

	get int Length is
	    return proxy.Length;
	si

	get CastIterator<T,F> Iterator is
	    return new CastIterator<T,F>(proxy.Iterator);
	si

        CastIterator<T,F> elements() is
            return Iterator;
        si

	String toString() is
	    return proxy.toString();
	si
    si


    class CastList<T,F> isa CastBag<T,F> do List<T> is
        // avoid spurious checked casts by duplicating this member with
	// narrower type:
        List<F> proxy;

        void init(List<F> l) is
	    super.init(l);
	    proxy = l;
	si

	void lengthen(int l) is
	    proxy.lengthen(l);
	si

        get T[int index] is
	    return cast T(proxy[index]);
	si

	set T[int index] = v is
	    proxy[index] = cast F(v);
	si

	Slice<T> slice(int from, int to) is
	    return new Slice<T>(this, from, to);
	si

        get List<T>[Range<int> r] is
	    return new Slice<T>(this, r.from, r.to);
	si

	get List<T> Freeze is
	    return slice(0,Length-1);
	si
    si

    class ConvertIterator<T,F> do Iterator<T> is
        Iterator<F> proxy;
        T proc(F) convert;

	void init(Iterator<F> i, T proc(F) c) is
	    proxy = i;
            convert = c;
	si

        bool hasMoreElements() is
	    return proxy.hasMoreElements();
	si

	T nextElement() is
	    return convert(proxy.nextElement());
	si

	get Iterator<T> Iterator is
	    return this;
	si
    si

    class ConvertBag<T,F> do Bag<T> is
        Bag<F> proxy;
        protected T proc(F) convertT;
        protected F proc(T) convertF;

	void init( Bag<F> b, T proc(F) ct, F proc(T) cf ) is
	    proxy = b;
            convertT = ct;
            convertF = cf;
	si

        void add( T v ) is
	    proxy.add( convertF(v) );
	si

        void add( Iterable<T> v ) is
	    foreach var i; v do
	        add( i );
	    od
        si

	void remove( T v ) is
	    proxy.remove( convertF(v) );
	si

        bool contains( T v ) is
	    return proxy.contains( convertF(v) );
	si

	bool isEmpty() is
	    return proxy.isEmpty();
	si

	get int Length is
	    return proxy.Length;
	si

	get ConvertIterator<T,F> Iterator is
	    return new ConvertIterator<T,F>(proxy.Iterator,convertT);
	si

        ConvertIterator<T,F> elements() is
            return Iterator;
        si

	String toString() is
	    return proxy.toString();
	si
    si


    class ConvertList<T,F> isa ConvertBag<T,F> do List<T> is
        // avoid spurious checked casts by duplicating this member with
	// narrower type:
        List<F> proxy;

        void init(List<F> l, T proc(F) ct, F proc(T) cf ) is
	    super.init(l, ct, cf);
	    proxy = l;
	si

	void lengthen(int l) is
	    proxy.lengthen(l);
	si

        get T[int index] is
	    return convertT(proxy[index]);
	si

	set T[int index] = v is
	    proxy[index] = convertF(v);
	si

	Slice<T> slice(int from, int to) is
	    return new Slice<T>(this, from, to);
	si

        get List<T>[Range<int> r] is
	    return new Slice<T>(this, r.from, r.to);
	si

	get List<T> Freeze is
	    return slice(0,Length-1);
	si
    si

/*
    class Main is
        void init() is
            // StringBuffer[]:
            var a = {"A"+"A", "B"+"B", "C"+"C", "D"+"D", "E"+"E"};

            var b = new CastList<String,StringBuffer>(a);

            var c = new ConvertList<String,StringBuffer>(
	        a,
		String proc(StringBuffer sb) is return sb; si,
		StringBuffer proc(String s) is return cast StringBuffer(s); si
            );

	    IO.Std.err.println( "a is: " + a.Class + ": " + a );
	    IO.Std.err.println( "b is: " + b.Class + ": " + b );
	    IO.Std.err.println( "b is: " + c.Class + ": " + c );

	    foreach var s; b do
	        IO.Std.err.println( "have: " + s );
	    od

	    foreach var s; c do
	        IO.Std.err.println( "have: " + s );
	    od

        si
    si
*/
si