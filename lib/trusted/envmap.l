#K
import args;
import gmap;

namespace Util is
    use Generic.Map;
    use System.String;

    /// Program environment as a Generic.Map of String
    class ProgramEnvironment is
        /// Returns program environment as a set of key-value pairs
	static get Map<String,String> Map is
    	    return makeMap( new Map<String,String>(), System.Arguments.ProgramEnvironment );
        end

	/// Populates a supplied map with key value pairs parsed from a supplied array of strings in 'name=value' format
	/// \param result a map to populate. Keys will be overwritten from env if they exist in both in both result and env
	/// \param env array of environment String to convert
	static Map<String,String> makeMap( Map<String,String> result, String[] env ) is
	    for int i = 0; i < env.length; i = i + 1 do
		String e = env[i];
		int split = e.indexOf('=');
		String key, value;

		if split >= 0 then
		    key = e.substring(0,split);
		    value = e.substring(split+1);
		else
		    key = e;
		    value = null;
		fi

		result[key] = value;
	    od

	    return result;
	end
    end
end
