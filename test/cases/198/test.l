import ssl;

namespace Test198 is
    use System.StringBuffer;
    use IO.Std;
    use Util.SSL;
    class Main is
        void init() is
            var b = new StringBuffer();
            foreach var i in; 0..1000 do
                b.append(i);
            od

            Std.out.println( "Hash is: " + SSL.MD5(b) );
        si
    si
si