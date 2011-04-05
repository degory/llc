namespace Test197 is
    use IO.Std;
    use System.Coroutine;

    class Main is
        public static Coroutine c0, c1;
        void init() is
            Std.out.FlushOnPrintln = true;
            Std.out.println( "Main.init" );
            c0 = new C0();
            c1 = new C1();
            c0.start();
            Std.out.println( "c0 started" );
            c1.start();
            Std.out.println( "c1 started" );
            c0.call();
            Std.out.println( "clean exit" );
        si
    si

    class C0 isa Coroutine is
        void init() is
            Std.out.println( "C0 init" );
            super.init();
            Std.out.println( "C0 init done" );
        si

        void run() is
            Std.out.println( "C0: entry" );
            foreach var i; 0..99 do
                Std.out.println( "C0: " + i );
                Main.c1.call();
            od
            
            Std.out.println( "C0: exit" );
        si
    si

    class C1 isa Coroutine is
        void init() is
            Std.out.println( "C1 init" );
            super.init();
            Std.out.println( "C1 init done" );
        si

        void run() is
            Std.out.println( "C1: entry" );
            foreach var i; 0..99 do
                Std.out.println( "C1: " + i );
                Main.c0.call();
            od
            Std.out.println( "C1: entry" );
        si
    si
si

