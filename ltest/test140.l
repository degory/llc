#C

import primtype;
import stream;

namespace Test140 {
    use System.Word;
    use System.Long;
    use System.Bool;
    use System.Int;
    use System.Char;

    class Main {
	void init() {
	    Word w = 0W.box;
	    Long l = 0L.box;
	    Bool b = false.box;
	    Int i = 0.box;
	    Char c = '\0'.box;
	}
    }
}