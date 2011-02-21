namespace Generic is
    use System.String;
    use System.StringBuffer;

    class Range<T> do Iterator<T> is
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
si