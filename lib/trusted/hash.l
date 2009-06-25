#K

namespace Util is
    class Hash is
	static int rotate( int u ) is
            int result = u << 5;
            return result | ((u >> 27) & 0x1F);
        end

	static int hash( System.String s ) is
	    int l = s.getLength();
	    int h = 0;
	    for int i = 0; i < l; i = i + 1 do
		h = rotate(h) + cast int(s.charAt(i));
	    od
	end

	static int hash( int i, int j ) is
	    return rotate(i) + j;
	end
    end
end
