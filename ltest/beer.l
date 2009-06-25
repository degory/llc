// 99 bottles of beer song. Unreasonably complicated example in L

import stream;
import generic;

namespace Beer is
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use IO.Std;
    use Generic.Vector;

    class Bottle extends Object is
        int number;

	void init(int number) is
	    this.number = number;
	end
	
	get String String is
	    var s = "s"; // plural suffix
            var p = "";  // bottle phrase

            var next = number - 1; // next descending bottle number

	    // figure out phrase and bottle suffix:
	    case next
	        is 0:
		    s = ""; // no plural suffix as bottle number is 1
                    p = "no more bottles";
                is 1:
                    p = "1 bottle";
                default:
                    p = "" + next + " bottles";            
    	    esac

	    return
	        "" + number + " bottle" + s + " of beer on the wall, "
		+ number + " bottle" + s + " of beer\n" +
		"Take one down and pass it around, " +
		p + " of beer on the wall";
        end
    end

    class Main extends Object is
        void init() is 
	    var wall = new Vector<Bottle>();
	    for var i = 1; i < 100; i = i + 1 do
	        wall.add(new Bottle(i));
	    od

	    foreach var bottle; wall.reverseElements() do
	        Std.err.println(bottle.String);
            od 

	    Std.err.println( "No more bottles of beer on the wall, no more bottles of beer" );
	    Std.err.println( "Go to the store and buy some more. 99 bottles of beer on the wall" );
        end
    end
end

 