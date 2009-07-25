import stream;
import gvector;
import gset;
import gmap;
import gllist;
//import postgres;
import gc;
import environment;
import unwind;
import klass;
import library;
import thread;
import lock;
import signal;
import stat;
import args;


namespace System {
    use Generic.Vector;
    use Generic.Set;
    use Generic.Map;
	
    class Lib {
	void init() {
	    var a0 = new Map<String,String>();
	    var a1 = new Map<int,String>();
	    var a2 = new Map<String,int>();

	    var b0 = new Vector<String>();
	    var b1 = new Vector<int>();
	    var b2 = new Vector<bool>();
	    
	    var c1 = new char[0];
	    var c2 = new int[0];
	    var c3 = new word[0];
	    var c4 = new String[0];
	    var c5 = new Object[0];	

	    var d0 = new Set<String>();
	    var d1 = new Set<int>();
	    var d2 = new Set<char>();	    
	}
    }
}