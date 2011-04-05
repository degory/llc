namespace Generic is
    use System.Coroutine;
    use System.ThreadState;

    class Generator<T> isa Coroutine do Iterator<T> is
        Coroutine caller;
        T next;
        bool need_check_next;
        bool have_next;

        void init() is
            super.init();
            need_check_next = true;
        si

        bool checkNext() is
            caller = Coroutine.Current;
            have_next = false;
            // ex = null;
 
            caller.call_(this);
            need_check_next = false;
            // checkThrow();
        si

        void yield(T t) is
            next = t;
            have_next = true;
            call_(caller);
        si

        bool hasMoreElements() is
            if need_check_next then
                checkNext();
            fi
            return have_next;
        si

        T nextElement() is
            if have_next then
                have_next = false;
                need_check_next = true;
                return next;
            else
                throw new IteratorException( "No more elements in " + this );
            fi            
        si

        get Generator<T> Iterator is
            return this;
        si
    si
si