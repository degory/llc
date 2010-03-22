#K

import unwind;

namespace System is
    /// A method in memory
    class Method is
	UnwindInfo unwind;
	ConstString name;

	void init( UnwindInfo u ) is
	    this.unwind = u;
	si
	
	System.String getName() is
	    if name == null then
		name = new ConstString( unwind.method_name );
	    fi

	    return name;
	si

	get int CodeSize is
	    return cast int(unwind.method_length);
	si

	get int RoDataSize is
	    return cast int(unwind.ro_size);
	si

	word invoke( word[] args ) is
	    // return native.__invoke_method( unwind.method_start, args.length, args.address );
	si

	String toString() is
	    return "method " + Name;
	si

	static MethodIterator methods() is
	    return new MethodIterator( UnwindInfo.First );
	si

	static MethodNameIterator methodNames() is
	    return new MethodNameIterator( UnwindInfo.First );
	si

	static Method find( System.String name ) is
	    foreach Method m; methods() do
		if name.equals(m.Name) then
		    return m;
		fi
	    od
	si
    si

    // avoid linking rest of library here by not extending Iterator:
    class MethodNameIterator is
	UnwindInfo current;

	void init( UnwindInfo c ) is
	    current = c;
	si

	bool hasMoreElements() is
	    return current.method_start != 0W;
	si

	String nextElement() is
	    String result = new ConstString(current.method_name);
	    current = current.Next;
	si
    si

    class MethodIterator is
	UnwindInfo current;

	void init( UnwindInfo m ) is
	    current = m;
	si

	bool hasMoreElements() is
	    return current.method_start != 0W;
	si

	Method nextElement() is
	    Method result = new Method( current );
	    current = current.Next;
	    return result;
	si
    si
si