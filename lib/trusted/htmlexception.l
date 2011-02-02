#C

namespace Web {
    use System.String;

    class HTMLException extends System.Exception {
	void init(String message) {
	    super.init(message);
	}
    }
}