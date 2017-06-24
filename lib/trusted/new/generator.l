namespace Generic is
    use System.Coroutine;
    use System.ThreadState;

    class Generator<T> isa Coroutine do Iterator<T> is
        // Coroutine caller;
        T next;
        void proc(Generator<T>) p;
        bool need_check_next;
        bool have_next;

        void init() is
            super.init();

            Caller = Current;

            need_check_next = true;
        si

        void init(void proc(Generator<T>) p) is
            init();
            this.p = p;
        si

        bool checkNext() is
            Caller = Coroutine.Current;
            have_next = false;
            // ex = null;
 
            Caller.call_(this);

            need_check_next = false;
            // checkThrow();
        si

        void run() is
            if p != null then
                p(this);
            else
                loop();
            fi
        si
 
        void loop() is
            @Virtual;
        si
       
        void yield(T t) is
            next = t;
            have_next = true;
            call_(Caller);
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