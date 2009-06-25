#K

import object;

namespace Util is
    class Iterator extends System.Object is
	System.Object nextElement() is throw new System.NotImplementedException(); end
	bool hasMoreElements() is throw new System.NotImplementedException(); end
    end
end
