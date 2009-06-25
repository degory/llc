#K

import unwind;

namespace System is
    class Method extends System.Object is
	UnwindInfo unwind;
	ConstString name;

	void init( UnwindInfo u ) is
	    this.unwind = u;
	end
	
	System.String getName() is
	    if name == null then
		name = new ConstString( unwind.method_name );
	    fi

	    return name;
	end

	get int CodeSize is
	    return cast int(unwind.method_end - unwind.method_start);
	end

	get int RoDataSize is
	    return cast int(unwind.ro_size);
	end

	word invoke( word[] args ) is
	    // return native.__invoke_method( unwind.method_start, args.length, args.address );
	end

	String toString() is
	    return "method " + Name;
	end

	static MethodIterator methods() is
	    return new MethodIterator( UnwindInfo.First );
	end

	static MethodNameIterator methodNames() is
	    return new MethodNameIterator( UnwindInfo.First );
	end

	static Method find( System.String name ) is
	    foreach Method m; methods() do
		if name.equals(m.Name) then
		    return m;
		fi
	    od
	end
    end

    // avoid linking rest of library here by not extending Iterator:
    class MethodNameIterator extends Object is
	UnwindInfo current;

	void init( UnwindInfo c ) is
	    current = c;
	end

	bool hasMoreElements() is
	    return current.method_start != 0W;
	end

	String nextElement() is
	    String result = new ConstString(current.method_name);
	    current = current.Next;
	end
    end

    class MethodIterator extends Object is
	UnwindInfo current;

	void init( UnwindInfo m ) is
	    current = m;
	end

	bool hasMoreElements() is
	    return current.method_start != 0W;
	end

	Method nextElement() is
	    Method result = new Method( current );
	    current = current.Next;
	    return result;
	end
    end
end