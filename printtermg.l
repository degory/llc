#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import stream;
import generic;

namespace PrintTerm {
   
    use IO.Reader;
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use Generic.Vector;
    use Generic.List;

    class Terminal extends Object {
        public int size;
        public int op;
        public String name;
        public int address;

        void init( int size, int op, String name, int address ) {
            super.init();
            this.size = size;
            this.op = op;
            this.name = name;
            this.address = address;
        }

        String toString() {
            return "Terminal(" + size + "," + op + "," + name + "," + address + ")";
        }
    }

    class Main {
        List<Terminal> list;
        Reader f;
        int next_terminal;

        bool readEntry() {
            int i;
            bool size1 = cast<char>(f.read()) == '1';
            bool size4 = cast<char>(f.read()) == '1';
	    bool size8 = cast<char>(f.read()) == '1';
	    bool size0 = cast<char>(f.read()) == '1';

            f.read();
            bool multi = cast<char>(f.read()) == '1';
            f.read();
            int inputs = f.read() - cast<int>('0');
            f.read();
            StringBuffer s = new StringBuffer();
            do {
                int c = f.read();
                if( c == -1 ) {
                    return false;
                } else if( cast<char>(c) == '\n' ) {
                    break;
                } else {
                    s.append( cast<char>(c) );
                }
            } while( true );

            Terminal t;

	    if( size0 ) {
                if( multi && inputs == 1 ) {
                    t = new Terminal( 0, next_terminal, s, 2 );
                    list[t.op] = t;
                    t = new Terminal( 0, next_terminal+4, s, 1 );
                    list[t.op] = t;
                } else if( multi && inputs == 2 ) {
                    t = new Terminal( 0, next_terminal, s, 3 );
                    list[t.op] = t;
                    t = new Terminal( 0, next_terminal+4, s, 2 );
                    list[t.op] = t;
                } else {
                    t = new Terminal( 0, next_terminal, s, 0 );
                    list[t.op] = t;
                }
	    }

            if( size1 ) {
                if( multi && inputs == 1 ) {
                    t = new Terminal( 1, next_terminal+1, s, 2 );
                    list[t.op] = t;
                    t = new Terminal( 1, next_terminal+5, s, 1 );
                    list[t.op] = t;
                } else if( multi && inputs == 2 ) {
                    t = new Terminal( 1, next_terminal+1, s, 3 );
                    list[t.op] = t;
                    t = new Terminal( 1, next_terminal+5, s, 2 );
                    list[t.op] = t;
                } else {
                    t = new Terminal( 1, next_terminal+1, s, 0 );
                    list[t.op] = t;
                }
            }

            if( size4 ) {
                if( multi && inputs == 1 ) {
                    t = new Terminal( 4, next_terminal+2, s, 2 );
                    list[t.op] = t;
                    t = new Terminal( 4, next_terminal+6, s, 1 );
                    list[t.op] = t;
                } else if( multi && inputs == 2 ) {
                    t = new Terminal( 4, next_terminal+2, s, 3 );
                    list[t.op] = t;
                    t = new Terminal( 4, next_terminal+6, s, 2 );
                    list[t.op] = t;
                } else {
                    t = new Terminal( 4, next_terminal+2, s, 0 );
                    list[t.op] = t;
                }
            }


	    if( size8 ) {
                if( multi && inputs == 1 ) {
                    t = new Terminal( 8, next_terminal+3, s, 2 );
                    list[t.op] = t;
                    t = new Terminal( 8, next_terminal+7, s, 1 );
                    list[t.op] = t;
                } else if( multi && inputs == 2 ) {
                    t = new Terminal( 8, next_terminal+3, s, 3 );
                    list[t.op] = t;
                    t = new Terminal( 8, next_terminal+7, s, 2 );
                    list[t.op] = t;
                } else {
                    t = new Terminal( 8, next_terminal+3, s, 0 );
                    list[t.op] = t;
                }
	    } 

            next_terminal = next_terminal + 8;
            return true;
        }

        void init() {
            int i;
            list = new Vector<Terminal>();
            f = IO.Std.in;
            Terminal t, s0_3a, s1_3a, s4_3a, s8_3a, s0_2a, s1_2a, s4_2a, s8_2a;

            IO.Writer tout = IO.File.openCreate( "terminal.out" );
            IO.Writer oout = IO.File.openCreate( "operation.l" );

            while( readEntry() )
                ;

            for( i = 0; i < list.Length; i = i + 1 ) {
                t = list[i];
                if( t != null ) {
                    if( i & 4 != 0 ) {
                        tout.println( "terminal " + t.name + t.address + "_" + t.size + " = " + t.op );
                    } else {
                        tout.println( "terminal " + t.name + "_" + t.size + " = " + t.op );
                    }                   
                }
            }

            tout.close();

	    oout.println( "#C" );
            oout.println( "class Op {" );
            oout.println( "    public const int" );

            for( i = 0; i < list.Length; i = i + 8 ) {
                try {

		    // size 0, op + 0
		    // size 1, op + 1
		    // size 4, op + 2
		    // size 8, op + 3

		    // size 0, op + 4	       
		    // size 1, op + 5
		    // size 4, op + 6
		    // size 8, op + 7

                    s0_3a = list[i];
                    s1_3a = list[i+1];
		    s4_3a = list[i+2];
		    s8_3a = list[i+3];

                    s0_2a = list[i+4];
                    s1_2a = list[i+5];
                    s4_2a = list[i+6];
                    s8_2a = list[i+7];
                } catch( Generic.VectorException ve ) {
                    IO.Std.err.println( "caught: " + ve );
                }

		bool have_size_0 = s0_3a != null || s0_2a != null;
                bool have_size_1 = s1_3a != null || s1_2a != null;
                bool have_size_4 = s4_3a != null || s4_2a != null;
		bool have_size_8 = s8_3a != null || s8_2a != null;

                bool have_2a = s0_3a != null || s1_2a != null || s4_2a != null || s8_2a != null;

                if( have_size_0 || have_size_1 || have_size_4 || have_size_8 ) {

		    if( have_size_0 ) {
                        oout.println( "        " + s0_3a.name + " = " + (s0_3a.op & ~3)+ "," );
                        if( s0_2a != null ) {
                            oout.println( "        " + s0_3a.name + s0_3a.address + " = " + (s0_3a.op & ~3) + "," );
                            oout.println( "        " + s0_2a.name + s0_2a.address + " = " + (s0_2a.op & ~3)+ "," );
                        }
                    } else if( have_size_1 ) {
                        oout.println( "        " + s1_3a.name + " = " + (s1_3a.op & ~3)  + "," );
                        if( s1_2a != null ) {
                            oout.println( "        " + s1_3a.name + s1_3a.address + " = " + (s1_3a.op & ~3) + "," );
                            oout.println( "        " + s1_2a.name + s1_2a.address + " = " + (s1_2a.op & ~3) + "," );
                        }
		    } else if( have_size_4 ) {
                        oout.println( "        " + s4_3a.name + " = " + (s4_3a.op & ~3)+ "," );
                        if( s4_2a != null ) {
                            oout.println( "        " + s4_3a.name + s4_3a.address + " = " + (s4_3a.op & ~3) + "," );
                            oout.println( "        " + s4_2a.name + s4_2a.address + " = " + (s4_2a.op & ~3)+ "," );
                        }
		    } else if( have_size_8 ) {
			oout.println( "        " + s8_3a.name + " = " + s8_3a.op + "," );
			if( s8_2a != null ) {
			    oout.println( "        " + s8_3a.name + s8_3a.address + " = " + s8_3a.op + "," );
			    oout.println( "        " + s8_2a.name + s8_2a.address + " = " + s8_2a.op + "," );
			}
                    }

		    if( have_size_0 ) {
			oout.println( "        " + s0_3a.name + "_0 = " + s0_3a.op + "," );
			if( s0_2a != null ) {
			    oout.println( "        " + s0_3a.name + s0_3a.address + "_0 = " + s0_3a.op + "," );
			    oout.println( "        " + s0_2a.name + s0_2a.address + "_0 = " + s0_2a.op + "," );
			}
		    }

                    if( have_size_1 ) {
                        oout.println( "        " + s1_3a.name + "_1 = " + s1_3a.op + "," );
                        if( s1_2a != null ) {
                            oout.println( "        " + s1_3a.name + s1_3a.address + "_1 = " + s1_3a.op + "," );
                            oout.println( "        " + s1_2a.name + s1_2a.address + "_1 = " + s1_2a.op + "," );
                        }
                    }

                    if( have_size_4 ) {
                        oout.println( "        " + s4_3a.name + "_4 = " + s4_3a.op + "," );
                        if( s4_2a != null ) {
                            oout.println( "        " + s4_3a.name + s4_3a.address + "_4 = " + s4_3a.op + "," );
                            oout.println( "        " + s4_2a.name + s4_2a.address + "_4 = " + s4_2a.op + "," );
                        }
                    }

		    if( have_size_8 ) {
			oout.println( "        " + s8_3a.name + "_8 = " + s8_3a.op + "," );
			if( s8_2a != null ) {
			    oout.println( "        " + s8_3a.name + s8_3a.address + "_8 = " + s8_3a.op + "," );
			    oout.println( "        " + s8_2a.name + s8_2a.address + "_8 = " + s8_2a.op + "," );
			}
		    }

                }
            }

            oout.println( "        MAX = " + i + ";" );
            oout.println( "    static System.String[] op_name = {" );
            
            char quote = '\"';
	    int size;
	    Terminal u;
            for( i = 0; i < list.Length; i = i + 1 ) {
                u = list[i];
                if( u != null ) {
                    oout.println( "        " + quote + u.name + u.address + "_" + u.size + quote + "," );
                } else {
                    size = 4;
                    if( i & 1 != 0 ) {
                        size = 1;
                    }

                    oout.println( "        " + quote + "undefined_" + i + "_" +size + quote + "," );
                }
            }
            oout.println( "    };" );
	    oout.println( "    static System.String[] as_name = {" );
            for( i = 0; i < list.Length; i = i + 1 ) {
                u = list[i];

		size = 0;
		if( i & 3 == 1 ) {
		    size = 1;
		} else if( i & 3 == 2 ) {
		    size = 4;
		} else if( i & 3 == 3 ) {
		    size = 8;
		}
                if( u != null ) {
		    if( size == 8 ) {
		        oout.println( "        " + quote + u.name.getLowerCase() + 'q' + quote + "," );
		    } else if( size == 4 ) {
		        oout.println( "        " + quote + u.name.getLowerCase() + 'l' + quote + "," );
		    } else if( size == 1 ) {
			oout.println( "        " + quote + u.name.getLowerCase() + 'b' + quote + "," );
		    } else {
			oout.println( "        " + quote + u.name.getLowerCase() + quote + "," );
		    }
                } else {
                    oout.println( "        " + quote + "undefined_" + i + "_" + size + quote + "," );
                }
            }
	    oout.println( "    };" );
	    oout.println( "    static System.String getOpName(int n) { return op_name[n]; }" );
	    oout.println( "    static System.String getAsName(int n) { return as_name[n]; }" );
	    oout.println( "    static void setAsName(int n, System.String s) { as_name[n] = s; }" );
            oout.println( "}" );

            oout.close();

	    printInterp(list);
        }

	void printInterp(List<Terminal> list) {
	    var o = IO.File.openCreate( "interp.l" );
	    o.println( "#K" );
	    o.println( "namespace Gen is" );
	    o.println( "  class SkeletonInterpreter is" );

	    var i = 0;
	    foreach( var t; list.elements() ) {
		var size = 0;
		var a2 = "";

		if( i & 3 == 1 ) {
		    size = 1;
		} else if( i & 3 == 2 ) {
		    size = 4;
		} else if( i & 3 == 3 ) {
		    size = 8;
		}
		if( i & 7 > 3 ) {
		    a2 = "2";
		}

		if( t != null ) {
		    if( size == 8 ) {
			o.println( "    word " + t.name + a2 + "_8(ITree v) is notImplemented(\"" + t.name + "_8\"); end" );
		    } else if( size == 4 ) {
			o.println( "    word " + t.name + a2 + "_4(ITree v) is notImplemented(\"" + t.name + "_4\"); end" );
		    } else if( size == 1 ) {
			o.println( "    word " + t.name + a2 + "_1(ITree v) is notImplemented(\"" + t.name + "_1\"); end" );
		    } else {
			o.println( "    word " + t.name + a2 + "(ITree v) is notImplemented(\"" + t.name + "\"); end" );
		    }
		} else {
		    o.println( "    word undefined_" + i + "_" + size + "(ITree v) is notImplemented(\"undefined_" + i + "_" + size + "\"); end" );
		}	    
	    
		i = i + 1;
	    }

	    o.println( "  void notImplemented(System.String s) is throw new System.Exception(\"not implemented: \" + s ); end" );

	    o.println( "  end" );
	    o.println( "end" );

	    o.close();
	}

    }

}
