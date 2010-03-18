#K

namespace Generic is
    use Generic.Iterable;
    use Generic.List;
    use Generic.Vector;

    class Filter<T> is
        static List<T> filter(Iterable<T> l, bool proc(T) f ) is
	    var result = new Vector<T>();				    

	    foreach var i; l.Iterator do
	        if f(i) then
		    result.add(i);
		fi
	    od

	    return result;
	end
    end
end