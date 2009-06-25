#K

import gvector;
namespace Generic is
    class Sort<T,U> is

	static void sort(U values) is
	    sort( values, 0, values.Length - 1 );
	end

	static void sort(U values, int p, int r) is
	    if p < r then
		int q = partition( values, p, r );
		if q == r then
		    q = q - 1;
		fi
		sort( values, p, q );
		sort( values, q+1, r );
	    fi
	end

	static int partition(U values, int lo, int hi ) is
	    T middle = values[lo];
	    do
		while values[hi] >= middle && lo < hi do
		    hi = hi - 1;
		od

		while values[lo] < middle && lo < hi do
		    lo = lo + 1;
		od

		if lo < hi then
		    T temp = values[hi];
		    values[hi] = values[lo];
		    values[lo] = temp;
		else
		    return hi;
		fi
	    od
	end
    end
end