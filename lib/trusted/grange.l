namespace Generic is
    class Range<T> do Iterator<T>, Iterable<T> is
        bool done;
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
	    return new Range<T>(from,to);
	si
    si				
si