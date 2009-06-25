#K
import args;
import gmap;

namespace Util is
    use Generic.Map;
    use System.String;

    class ProgramEnvironment is
	static get Map<String,String> Map is
    	    return makeMap( new Map<String,String>(), System.Arguments.ProgramEnvironment );
        end

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
