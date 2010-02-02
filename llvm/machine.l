// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

namespace Gen {
    use System.String;


    class Machine {
	public static String NAME = "llvm";

	static void initOpNames() {
	}

	static String file_name = "unknown";

	static get bool Is64Bit {
	    return true;
	}

        void init() {
            super.init();
        }
    }
}
