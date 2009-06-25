#K

import unwind;

namespace System is
    class ClassSize is
	static int getClassSize( Class c ) is
   	    int size = 0;	    
	    StringBuffer class_name = new StringBuffer(c.Name);
	    class_name.append('.');
	    // IO.Std.err.println( "class name: " + class_name );

	    UnwindInfo current = UnwindInfo.First;

	    while current.method_start != 0W do
		char ptr n = current.method_name;
		while [n] != ' ' do
		    n = n + 1;
		od

		n = n + 1;

		ConstString method_name = new ConstString( n );
		// IO.Std.err.println( "method name: " + method_name );

		if method_name.startsWith(class_name) then
		    // IO.Std.err.println( "match" );
		    size = size + cast int(current.ro_size + current.method_end - current.method_start);
		fi

		current = current.Next;
	    od
	    
	    // IO.Std.err.println( "result: " + size );
	    return size;
	end

	static int getMethodCount( Class c ) is
	    int count = 0;	    
	    StringBuffer class_name = new StringBuffer(c.Name);
	    class_name.append('.');
	    // IO.Std.err.println( "class name: " + class_name );

	    UnwindInfo current = UnwindInfo.First;
	    while current.method_start != 0W do
		char ptr n = current.method_name;
		while [n] != ' ' do
		    n = n + 1;
		od
		n = n + 1;

		ConstString method_name = new ConstString( n );
		// IO.Std.err.println( "method name: " + method_name );

		if method_name.startsWith(class_name) then
		    // IO.Std.err.println( "match" );
		    count = count + 1;
		fi

		current = current.Next;
	    od
	    
	    // IO.Std.err.println( "result: " + size );
	    return count;
	end
    end
end