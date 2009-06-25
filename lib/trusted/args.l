#K
pragma NoWarnUnsafe;
pragma NoMarkUnsafe;

namespace System is
    class Arguments is
	static String[] makeStringArrayFromCStringList( char ptr ptr csl ) is
	    char ptr ptr p = csl;
	    int c = 0;
	    while [p] != null do
		c = c + 1;
		p = p + 1;
	    od

	    String[] result = new String[c];
	    
	    for int i = 0; i < c; i = i + 1 do
		result[i] = new String( [csl + i] );
	    od

	    return result;
	end

	static get String[] ProgramArguments is
	    char ptr ptr argv = cast char ptr ptr(native.__get_argv());
	    return makeStringArrayFromCStringList( argv );
	end

	static get String[] ProgramEnvironment is
	    return makeStringArrayFromCStringList( cast char ptr ptr(native.__get_envp()) );
	end
    end
end
