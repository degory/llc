
namespace System {
    class Proc<P> {
	word f0;
	word d;
	word f1;

	void init(P p) {
	    
	}

	get P Proc {
	    return cast<P>(this);
	}
    }
}