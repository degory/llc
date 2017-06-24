namespace Generic is
    use System.String;
    use System.StringBuffer;

    class Range<T> do Iterator<T> is
        public T i, from, to;

	void init( T from, T to ) is
	    i = from;
            this.from = from;
	    this.to = to;	    
	si

	bool hasMoreElements() is
	    return i <= to;
	si

	T nextElement() is
	    T result = i;
	    i = i.next();
	    return result;	 
	si

	get Iterator<T> Iterator is
            return this;
	si

        String toString() is
	    StringBuffer result = new StringBuffer();
	    result
	        .append(from.toString())
		.append("..")
		.append(to.toString());

            if i !~ from then
	        result
		    .append("@")
		    .append(i.toString());
	    fi

	    return result;
        si
    si

    class ReverseRange<T> isa Range<T> is
        void init(int f, int t) is
            super.init(f, t);
            // IO.Std.out.println( "new reverse range: " + this );
        si

	bool hasMoreElements() is
            // IO.Std.out.println( "has more elements: " + this + " -> " + (i >= to) );
	    return i >= to;
	si

        T nextElement() is
            T result = i;
            i = i.prev();
            // IO.Std.out.println( "next element: " + this + " -> " + result );
            return result;
        si
    si
si