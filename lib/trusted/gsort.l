#K

import gvector;
namespace Generic is
    /// Sort a List of values of type T
    /// \param T type of values in the list to be sorted
    class Sort<T> is
        /// Sort the supplied List of values
        /// \param values the List<T> of values to sort
        static void sort(List<T> values) is
            sort( values, int proc(T,T)(T.opCompare), 0, values.Length - 1 );
        end
	
        static void sort(List<T> values, int proc(T,T) compare) is
            sort( values, compare, 0, values.Length - 1 );
        end

        /// Sort a slice of the supplied List
        /// \param values the List<T> of values to sort
        /// \param p first element in the range to sort, inclusive
        /// \param r last element in the range to sort, inclusive
	static void sort(List<T> values, int proc(T,T) compare, int p, int r) is
            if p < r then
                int q = partition( values, compare, p, r );
                if q == r then
                    q = q - 1;
                fi
		sort( values, compare, p, q );
		sort( values, compare, q+1, r );
            fi
        end

        /// Internal method supporting sort(List<T>, int p, int r )
	static int partition(List<T> values, int proc(T,T) compare, int lo, int hi ) is
	    T middle = values[lo];
            do
                while compare(values[hi],middle) >= 0 && lo < hi do
		    hi = hi - 1;
                od

		while compare(values[lo], middle) < 0 && lo < hi do
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


    /// Sort a List of values of type T
    /// \param T type of values in the list to be sorted
    class SortList<T> is
        /// Sort the supplied List of values
	/// \param values the List<T> of values to sort
	static void sort(List<T> values) is
	    sort( values, 0, values.Length - 1 );
	end

	/// Sort a slice of the supplied List
	/// \param values the List<T> of values to sort
	/// \param p first element in the range to sort, inclusive
	/// \param r last element in the range to sort, inclusive
	static void sort(List<T> values, int p, int r) is
	    if p < r then
		int q = partition( values, p, r );
		if q == r then
		    q = q - 1;
		fi
		sort( values, p, q );
		sort( values, q+1, r );
	    fi
	end

	/// Internal method supporting sort(List<T>, int p, int r )
	static int partition(List<T> values, int lo, int hi ) is
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

    /// Sort an array of values of type T
    /// \param T type of values in the array to be sorted
    class SortArray<T> is
        /// Sort the supplied array of values
	/// \param values the T[] array of values to sort
	static void sort(T[] values) is
	    sort( values, 0, values.length - 1 );
	end

	/// Sort a slice of the supplied array
	/// \param values the T[] array of values to sort
	/// \param p first element in the range to sort, inclusive
	/// \param r last element in the range to sort, inclusive
	static void sort(T[] values, int p, int r) is
	    if p < r then
		int q = partition( values, p, r );
		if q == r then
		    q = q - 1;
		fi
		sort( values, p, q );
		sort( values, q+1, r );
	    fi
	end

	/// Internal method supporting sort(T[] values, int p, int r)
	static int partition(T[] values, int lo, int hi ) is
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