
namespace System {
    class Proc<P> {
	word f0;
	word d;
	word f1;

	void init(P p) {	    
	}

	void init(word f) {
	    f0 = f;
	}

	void init() {
	}

	get P Proc {
	    return cast<P>(this);
	}
    }
}