#K

namespace Util is
    use Generic.Iterable;
    use Generic.List;
    use Generic.Vector;

    /// Apply functions to lists of values
    /// \param T element type of lists/argument type of functions
    class Filter<T> is
        static List<T> where(Iterable<T> l, bool proc(T) p ) is
            var result = new Vector<T>();

            foreach var i; l.Iterator do
                if p(i) then
                    result.add(i);
                fi
            od

            return result;
        si

        static List<T> except(Iterable<T> l, bool proc(T) f ) is
            var result = new Vector<T>();

            foreach var i; l.Iterator do
                if !f(i) then
                    result.add(i);
                fi
            od

            return result;
        si

        static List<T> map(Iterable<T> l, T proc(T) f ) is
            var result = new Vector<T>();

            foreach var i; l.Iterator do
                result.add( f(i) );
            od

            return result;
        si

        static void apply(List<T> l, T proc(T) f ) is
            int len = l.Length;
            for var i = 0; i < len; i = i + 1 do
                l[i] = f(l[i]);
            od
        si

	static T reduce(Iterable<T> l, T proc(T,T) f, T s) is
	    foreach var i; l.Iterator do
	        s = f(s, i);
	    od

	    return s;
	si

	static T reduce(Iterable<T> l, T proc(T,T) f) is
	    return reduce(l, f, T.none);
	si

        static List<T> mapIf(Iterable<T> l, bool proc(T) p, T proc(T) f ) is
            var result = new Vector<T>();

            foreach var i; l.Iterator do
                if p(i) then
                    result.add( f(i) );
                else
                    result.add( i );
                fi
            od

            return result;
        si

        static void applyIf(List<T> l, bool proc(T) p, T proc(T) f ) is
            int len = l.Length;
            for var i = 0; i < len; i = i + 1 do
                var v = l[i];
                if p(v) then
                    l[i] = f(v);
                fi
            od
        si

	static T reduceIf(Iterable<T> l, bool proc(T) p, T proc(T,T) f, T s) is
	    foreach var i; l.Iterator do
	        if p(i) then
		    s = f(s,i);
		fi
	    od

	    return s;
	si

        static T reduceIf(Iterable<T> l, bool proc(T) p, T proc(T,T) f) is
	    return reduceIf(l, p, f, T.none);
	si
    si
si