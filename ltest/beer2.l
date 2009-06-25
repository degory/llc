#K
import stream;  
import generic;

namespace Beer is
    use System.Object;
    use System.Exception;
    use System.String;
    use System.StringBuffer;
    use IO.Std;
    use Generic.Vector;
   
    // Bottle represents a bottle of beer that knows its position
    // in the song and can return that song line as its string
    // representation:
    class Bottle extends Object is
        int number;   // our position on the wall

        // construct a new Bottle object with given number:
        void init(int number) is
            this.number = number;
        end

        // this property returns a string representation
        // of a Bottle object for display:
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
        // this is the program entry point:
	void init() is
            try
                // this instance of the variable length array template
                // class Vector will represent the wall:
                var wall = new Vector<Bottle>();
 
                // create 99 bottles each with their own number and
                // place them on the wall:
                for var i = 1; i < 100; i = i + 1 do
                    wall.add(new Bottle(i));
                od

               // for each bottle on the wall in descending order:
               foreach Bottle bottle; wall.reverseElements() do
                   // print the song line for this bottle:
                   Std.err.println(bottle);
               od
            catch Exception e
               Std.err.println("too drunk to sing anymore" );
            finally
               // song epilog:
               Std.err.println( "No more bottles of beer on the wall, no more bottles of beer" );
               Std.err.println( "Go to the store and buy some more. 99 bottles of beer on the wall" );
            yrt
        end
    end
end
