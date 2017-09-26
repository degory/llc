namespace Generic is
    use System.NotImplementedException;
    use System.String;
    use System.StringBuffer;

    class Range<T> do Iterator<T> is
        public T i, from, to;

        get String op is
            throw new NotImplementedException("abstract");
        si

        void init( T from, T to ) is
            i = from;
            this.from = from;
            this.to = to;	    
        si

        bool hasMoreElements() is
            throw new NotImplementedException("abstract");
        si

        T nextElement() is
            throw new NotImplementedException("abstract");
        si

        get Iterator<T> Iterator is
            return this;
        si

        String toString() is
            StringBuffer result = new StringBuffer();
            result
                .append(from.toString())
                .append(op)
                .append(to.toString());

            if i !~ from then
                result
                    .append("@")
                    .append(i.toString());
            fi

            return result;
        si
    si

    class ForwardRange<T> isa Range<T> is
        void init(int f, int t) is
            super.init(f, t);
        si

        T nextElement() is
            T result = i;
            i = i.next();
            return result;
        si
    si

    class ForwardInclusiveRange<T> isa ForwardRange<T> is
        get String op is
            return "::";
        si

        void init(int f, int t) is
            super.init(f, t);
        si

        bool hasMoreElements() is
            return i <= to;
        si
    si

    class ForwardExclusiveRange<T> isa ForwardRange<T> is
        get String op is
            return "..";
        si

        void init(int f, int t) is
            super.init(f, t);
        si

        bool hasMoreElements() is
            return i < to;
        si
    si

    class ReverseRange<T> isa Range<T> is
        void init(int f, int t) is
            super.init(f, t);
        si

        T nextElement() is
            T result = i;
            i = i.prev();
            return result;
        si
    si

    class ReverseInclusiveRange<T> isa ReverseRange<T> is
        get String op is
            return "::";
        si

        void init(int f, int t) is
            super.init(f, t);
        si

        bool hasMoreElements() is
            return i >= to;
        si
    si

    class ReverseExclusiveRange<T> isa ReverseRange<T> is
        get String op is
            return "..";
        si

        void init(int f, int t) is
            super.init(f, t);
        si

        bool hasMoreElements() is
            return i > to;
        si
    si    
si