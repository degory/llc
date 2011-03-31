#C

namespace Test1 {
    class Main extends System.Object {
	void init() {
	    native.puts( `hello world!\n` );
            native.__flush_stdout();
	}
    }
}