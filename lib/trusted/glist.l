#K

import gbag;

namespace Generic is
    interface List<T> extends Bag<T> is
	void lengthen(int l);
        get T[int index];
	set T[int index] = v;
    end
end
