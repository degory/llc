#K

namespace Util is
    use Generic.Iterable;
    use Generic.List;
    use Generic.Vector;

    class Filter<T> is
        static List<T> where(Iterable<T> l, bool proc(T) f ) is
            var result = new Vector<T>();

            foreach var i; l.Iterator do
                if f(i) then
                    result.add(i);
                fi
            od

            return result;
        end

        static List<T> except(Iterable<T> l, bool proc(T) f ) is
            var result = new Vector<T>();

            foreach var i; l.Iterator do
                if !f(i) then
                    result.add(i);
                fi
            od

            return result;
        end

        static List<T> map(Iterable<T> l, T proc(T) f ) is
            var result = new Vector<T>();

            foreach var i; l.Iterator do
                result.add( f(i) );
            od

            return result;
        end

        static void apply(List<T> l, T proc(T) f ) is
            int len = l.Length;
            for var i = 0; i < len; i = i + 1 do
                l[i] = f(l[i]);
            od
        end

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
        end

        static void applyIf(List<T> l, bool proc(T) p, T proc(T) f ) is
            int len = l.Length;
            for var i = 0; i < len; i = i + 1 do
                var v = l[i];
                if p(v) then
                    l[i] = f(v);
                fi
            od
        end
    end
end