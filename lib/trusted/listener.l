#K

namespace Util is
    use Generic.Vector;

    class Listener<E> is
        Vector<void proc(E)> procs;

        void init() is
            super.init();
            procs = new Vector<void proc(E)>();
        si

        void add( void proc(E) p ) is
            procs.add(p);
        si

        void signal(E e) is
            foreach var p; procs.Iterator do
                p(e);
            od
        si
    si
si
