#K
pragma NoWarnUnsafe;
pragma NoMarkUnsafe;

namespace System is
    /// Program command line arguments and UNIX environment
    class Arguments is
        /// returns a copy of a C array of C strings converted to an L array of String
        /// \param csl the C array of C strings to convert
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

	/// returns program command line arguments as an array of String
	static get String[] ProgramArguments is
	    char ptr ptr argv = cast char ptr ptr(native.__get_argv());
	    return makeStringArrayFromCStringList( argv );
	end

	/// returns the program environment as an array of String
	static get String[] ProgramEnvironment is
	    return makeStringArrayFromCStringList( cast char ptr ptr(native.__get_envp()) );
	end
    end
end
