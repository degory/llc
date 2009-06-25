#K

import stream;

namespace Test145 is
    class Test is
        void init() is
	    IO.Std.err.println( "testing..." );
	end
    end

    interface InterfaceA is
        void testA();
	void testA1();
	void testA2();
    end

    interface InterfaceB is
        void testB();
	void testB1();
    end

    interface InterfaceC is
    	void testC();
	void testC1();
	void testC2();
	void testC3();
    end

    interface InterfaceD is
        void testD();
    end

    interface InterfaceE is
    	void testE();
    end

    interface InterfaceF is
        void testF();
	void testF1();
	void testF2();
    end

    interface InterfaceG extends InterfaceF is
       void testF3();
       void testF4();
    end

    interface InterfaceH<T> is
        void testH(T t);
	void testH1(T t);
	void testH2(T t);
    end

    class Implement1 extends System.Object implements InterfaceA, InterfaceB is
        void init() is
	end

	void testA() is
	    IO.Std.err.println( "test A..." );						     
	end

        void testA1() is
	    IO.Std.err.println( "test A1..." );
        end

	void testA2() is
	    IO.Std.err.println( "test A2..." );
        end

        void testB() is
	    IO.Std.err.println( "test B..." );
        end
    end

    class Implement2 extends System.Object implements InterfaceC is
        void init() is
	end

	void testC() is
	end
    end

    class Implement3 extends System.Object implements InterfaceD, InterfaceE is
        void init() is
	end

	void testD() is
	end
    end

    class Implement4 extends System.Object implements InterfaceF is
        void init() is
	end
    end

    class Implement5 extends System.Object implements InterfaceG is
        void init() is
        end
    end

    class Implement6<T> extends System.Object implements InterfaceH<T> is
        void testH(T t) is
	end

	void testH1(T t) is
	end
    end

    class Implement7 extends System.Object implements InterfaceH<System.String> is
        void testH(System.String t) is
	end

	void testH1(System.String t) is
	end
    end

    class Main extends System.Object is
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
	end      
    end
end
