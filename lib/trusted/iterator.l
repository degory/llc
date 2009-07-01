#K

import object;

namespace Util is
    /// Iterator over some collection of Objects returns each value in the collection in turn.
    class Iterator extends System.Object is
        /// Return the next value. Behaviour is not defined if nextElement() is called after hasMoreElements() has returned false
	System.Object nextElement() is throw new System.NotImplementedException(); end
	/// Are there more values to return? 
	bool hasMoreElements() is throw new System.NotImplementedException(); end
    end
end
