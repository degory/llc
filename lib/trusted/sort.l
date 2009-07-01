#K

namespace Util is
    class Compare extends System.Object is
	public int compare( System.Object a, System.Object b ) is
	    return 0;
	end

	public void init() is
	    super.init();
	end
    end

    /// Sort arrays or Vectors of Objects.
    /// \deprecated Use Generic.SortList<T> or Generic.SortArray<T> instead
    class Sort is
	static void sort(Compare compare, Util.Vector values ) is
	    sort( compare, values, 0, values.getLength() - 1 );
	end

	static void sort(Compare compare, System.Object[] values ) is
	    sort( compare, values, 0, values.length - 1 );
	end

	static void sort(Compare compare, Util.Vector values, int p, int r) is
	    if p < r then
		int q = partition( compare, values, p, r );
		if q == r then
		    q = q - 1;
		fi
		sort( compare, values, p, q );
		sort( compare, values, q+1, r );
	    fi
	end

	static void sort(Compare compare, System.Object[] values, int p, int r) is
	    if p < r then
		int q = partition( compare, values, p, r );
		if q == r then
		    q = q - 1;
		fi
		sort( compare, values, p, q );
		sort( compare, values, q+1, r );
	    fi
	end

	static int partition( Compare compare, Util.Vector values, int lo, int hi ) is
	    System.Object middle = values[lo];
	    do
		while compare.compare( values[hi], middle ) >= 0 && lo < hi do
		    hi = hi - 1;
		od

		while compare.compare( values[lo], middle ) < 0 && lo < hi do
		    lo = lo + 1;
		od
		
		if lo < hi then
		    System.Object temp = values[hi];
		    values.put(hi,values[lo]);
		    values.put(lo,temp);
		else
		    return hi;
		fi
	    od
	end
    
	static int partition( Compare compare, System.Object[] values, int lo, int hi ) is
	    System.Object middle = values[lo];
	    do
		while compare.compare( values[hi], middle ) >= 0 && lo < hi do
		    hi = hi - 1;
		od

		while compare.compare( values[lo], middle ) < 0 && lo < hi do
		    lo = lo + 1;
		od
		
		if lo < hi then
		    System.Object temp = values[hi];
		    values[hi] = values[lo];
		    values[lo] = temp;
		else
		    return hi;
		fi
	    od
	end
    end
end
