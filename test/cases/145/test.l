#K

import stream;

namespace Test145 is
    class Test is
        void init() is
	    IO.Std.err.println( "testing..." );
	si
    si

    interface InterfaceA is
        void testA();
	void testA1();
	void testA2();
    si

    interface InterfaceB is
        void testB();
	void testB1();
    si

    interface InterfaceC is
    	void testC();
	void testC1();
	void testC2();
	void testC3();
    si

    interface InterfaceD is
        void testD();
    si

    interface InterfaceE is
    	void testE();
    si

    interface InterfaceF is
        void testF();
	void testF1();
	void testF2();
    si

    interface InterfaceG isa InterfaceF is
       void testF3();
       void testF4();
    si

    interface InterfaceH<T> is
        void testH(T t);
	void testH1(T t);
	void testH2(T t);
    si

    class Implement1 isa System.Object do InterfaceA, InterfaceB is
        void init() is
	si

	void testA() is
	    IO.Std.err.println( "test A..." );						     
	si

        void testA1() is
	    IO.Std.err.println( "test A1..." );
        si

	void testA2() is
	    IO.Std.err.println( "test A2..." );
        si

        void testB() is
	    IO.Std.err.println( "test B..." );
        si
    si

    class Implement2 isa System.Object do InterfaceC is
        void init() is
	si

	void testC() is
	si
    si

    class Implement3 isa System.Object do InterfaceD, InterfaceE is
        void init() is
	si

	void testD() is
	si
    si

    class Implement4 isa System.Object do InterfaceF is
        void init() is
	si
    si

    class Implement5 isa System.Object do InterfaceG is
        void init() is
        si
    si

    class Implement6<T> isa System.Object do InterfaceH<T> is
        void testH(T t) is
	si

	void testH1(T t) is
	si
    si

    class Implement7 isa System.Object do InterfaceH<System.String> is
        void testH(System.String t) is
	si

	void testH1(System.String t) is
	si
    si

    class Main isa System.Object is
        void init() is
            var i1 = new Implement1();
	    var i2 = new Implement2();
	    var i3 = new Implement3();

            var i4 = new Implement6<int>();

            InterfaceA ia;
            InterfaceB ib;
	    InterfaceC ic;
	    InterfaceD id;

            System.Object o, p;

            ia = i1;
	    ib = i1;
	    ic = i2;
	    id = i3; 

            i1.testA();
            ia.testA();

	    i1.testB();
	    ib.testB();
	si
    si
si
