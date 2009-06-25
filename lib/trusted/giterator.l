#K

namespace Generic is
    interface Iterator<T> is
        bool hasMoreElements();
	T nextElement();
    end
end