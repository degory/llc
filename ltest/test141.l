#K

import stream;

namespace Test141 is
    use IO.Std;
    use System.String;
    use System.Object;

    class Main is
	void init() is
	    var t = new Test(20);
	    int i;
	    for i = 0; i < t.Length; i = i + 1 do
		t[i] = i;
		t.Prop[i] = i;
	    od

	    int[] p = t.Prop;

	    t.Prop = p;	    

	    for i = 0; i < t.Length; i = i + 1 do
		IO.Std.err.println( "t[" + i + "]: " + t[i] );
		IO.Std.err.println( "t.Prop[" + i + "]: " + t.Prop[i] );
	    od
	end
    end

    class Test extends Object is
	String name;
	int value;
	int[] array;
	int[] prop;

	void init(int size) is
	    array = new int[size];
	    prop = new int[size];

	    Std.err.println( "init length: " + Length );
	    Value = 123;

	    Name = Class.Name + Value;
	end

	get int Length is
	    return array.length;
	end

	get int Value is
	    return value;
	end

	set int Value = v is
	    value = v;
	end

        get String Name is
	    return name;
	end

        set String Name = n is
	    name = n;
	end

        get int[int index] is
	    return array[index];
	end

        set int[int index] = v is
	    array[index] = v;
	end

        get int Prop[int index] is
	    return prop[index];
        end

	set int Prop[int index] = v is
	    prop[index] = v;
	end

        get int[] Prop is
	    Std.err.println( "get prop array" );
	    return prop;
	end

        set int[] Prop = p is
	    Std.err.println( "set prop array" );
	    prop = p;
	end
    end
end
