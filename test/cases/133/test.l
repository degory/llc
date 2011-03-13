#C

import stream;
import classsize;

class Main {
    void init() {
	System.Class c = System.Class.find("System.String");

	System.ClassSize.getClassSize(c);
    }

}