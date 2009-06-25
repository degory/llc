// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import stream;
import vector;

namespace PrintTerm {
    use IO.Reader;
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use Util.Vector;

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
        Vector list;
        Reader f;
        int next_terminal;

        bool readEntry() {
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
                    list.put( t.op, t );
                    t = new Terminal( 0, next_terminal+4, s, 1 );
                    list.put( t.op, t );
                } else if( multi && inputs == 2 ) {
                    t = new Terminal( 0, next_terminal, s, 3 );
                    list.put( t.op, t );
                    t = new Terminal( 0, next_terminal+4, s, 2 );
                    list.put( t.op, t );
                } else {
                    t = new Terminal( 0, next_terminal, s, 0 );
                    list.put( t.op, t );
                }
	    }

            if( size1 ) {
                if( multi && inputs == 1 ) {
                    t = new Terminal( 1, next_terminal+1, s, 2 );
                    list.put( t.op, t );
                    t = new Terminal( 1, next_terminal+5, s, 1 );
                    list.put( t.op, t );
                } else if( multi && inputs == 2 ) {
                    t = new Terminal( 1, next_terminal+1, s, 3 );
                    list.put( t.op, t );
                    t = new Terminal( 1, next_terminal+5, s, 2 );
                    list.put( t.op, t );
                } else {
                    t = new Terminal( 1, next_terminal+1, s, 0 );
                    list.put( t.op, t );
                }
            }

            if( size4 ) {
                if( multi && inputs == 1 ) {
                    t = new Terminal( 4, next_terminal+2, s, 2 );
                    list.put( t.op, t );
                    t = new Terminal( 4, next_terminal+6, s, 1 );
                    list.put( t.op, t );
                } else if( multi && inputs == 2 ) {
                    t = new Terminal( 4, next_terminal+2, s, 3 );
                    list.put( t.op, t );
                    t = new Terminal( 4, next_terminal+6, s, 2 );
                    list.put( t.op, t );
                } else {
                    t = new Terminal( 4, next_terminal+2, s, 0 );
                    list.put( t.op, t );
                }
            }


	    if( size8 ) {
                if( multi && inputs == 1 ) {
                    t = new Terminal( 8, next_terminal+3, s, 2 );
                    list.put( t.op, t );
                    t = new Terminal( 8, next_terminal+7, s, 1 );
                    list.put( t.op, t );
                } else if( multi && inputs == 2 ) {
                    t = new Terminal( 8, next_terminal+3, s, 3 );
                    list.put( t.op, t );
                    t = new Terminal( 8, next_terminal+7, s, 2 );
                    list.put( t.op, t );
                } else {
                    t = new Terminal( 8, next_terminal+3, s, 0 );
                    list.put( t.op, t );
                }
	    } 

            next_terminal = next_terminal + 8;
            return true;
        }

        void init() {
            list = new Vector();
            f = IO.Std.in;
            Terminal t, s0_3a, s1_3a, s4_3a, s8_3a, s0_2a, s1_2a, s4_2a, s8_2a;

            IO.Writer tout = IO.File.openCreate( "terminal.out" );
            IO.Writer oout = IO.File.openCreate( "operation.l" );

            while( readEntry() )
                ;

            for( int i = 0; i < list.getLength(); i = i + 1 ) {
                t = cast<Terminal>(list.get(i));
                if( t != null ) {
                    if( i & 4 != 0 ) {
                        tout.println( "terminal " + t.name + t.address + "_" + t.size + " = " + t.op );
                    } else {
                        tout.println( "terminal " + t.name + "_" + t.size + " = " + t.op );
                    }                   
                }
            }

            tout.close();

            oout.println( "class Op {" );
            oout.println( "    public const int" );

            for( i = 0; i < list.getLength(); i = i + 8 ) {
                try {

		    // size 0, op + 0
		    // size 1, op + 1
		    // size 4, op + 2
		    // size 8, op + 3

		    // size 0, op + 4	       
		    // size 1, op + 5
		    // size 4, op + 6
		    // size 8, op + 7

                    IO.Std.err.println( "trying 0..." );
                    s0_3a = cast<Terminal>(list.get(i));
                    IO.Std.err.println( "trying 1..." );
                    s1_3a = cast<Terminal>(list.get(i+1));
		    IO.Std.err.println( "trying 2..." );
		    s4_3a = cast<Terminal>(list.get(i+2));
		    IO.Std.err.println( "trying 3..." );
		    s8_3a = cast<Terminal>(list.get(i+3));

                    IO.Std.err.println( "trying 4..." );
                    s0_2a = cast<Terminal>(list.get(i+4));
                    IO.Std.err.println( "trying 5..." );
                    s1_2a = cast<Terminal>(list.get(i+5));
                    IO.Std.err.println( "trying 6..." );
                    s4_2a = cast<Terminal>(list.get(i+6));
                    IO.Std.err.println( "done" );
                    s8_2a = cast<Terminal>(list.get(i+7));
                    IO.Std.err.println( "done" );
                } catch( Util.VectorException ve ) {
                    IO.Std.err.println( "caught: " + ve );
                }

		bool have_size_0 = s0_3a != null || s0_2a != null;
                bool have_size_1 = s1_3a != null || s1_2a != null;
                bool have_size_4 = s4_3a != null || s4_2a != null;
		bool have_size_8 = s8_3a != null || s8_2a != null;

                bool have_2a = s0_3a != null || s1_2a != null || s4_2a != null || s8_2a != null;

                IO.Std.err.println( "have 1: " + have_size_1 );
                IO.Std.err.println( "have 4: " + have_size_4 );
                IO.Std.err.println( "have 8: " + have_size_8 );
                IO.Std.err.println( "have 2a: " + have_2a );

		IO.Std.err.println( "s0_3a: " + s0_3a );
		IO.Std.err.println( "s0_2a: " + s0_2a );
                IO.Std.err.println( "s1_3a: " + s1_3a );
                IO.Std.err.println( "s1_2a: " + s1_2a );
                IO.Std.err.println( "s4_3a: " + s4_3a );
                IO.Std.err.println( "s4_2a: " + s4_2a );
                IO.Std.err.println( "s8_3a: " + s8_3a );
                IO.Std.err.println( "s8_2a: " + s8_2a );

                if( have_size_0 || have_size_1 || have_size_4 || have_size_8 ) {
                    IO.Std.err.println( "have 0 or 1 or 4 or 8\n" );

		    if( have_size_0 ) {
                        IO.Std.err.println( "0: have 0: " + s0_3a + " and " + s0_2a );
                        oout.println( "        " + s0_3a.name + " = " + (s0_3a.op & ~3)+ "," );
                        if( s0_2a != null ) {
                            IO.Std.err.println( "0: have 2a: " + s0_2a );
                            oout.println( "        " + s0_3a.name + s0_3a.address + " = " + (s0_3a.op & ~3) + "," );
                            oout.println( "        " + s0_2a.name + s0_2a.address + " = " + (s0_2a.op & ~3)+ "," );
                        }
                    } else if( have_size_1 ) {
                        IO.Std.err.println( "1: have 1: " + s1_3a );
                        oout.println( "        " + s1_3a.name + " = " + (s1_3a.op & ~3)  + "," );
                        if( s1_2a != null ) {
                            IO.Std.err.println( "1: have 2a: " + s1_2a );
                            oout.println( "        " + s1_3a.name + s1_3a.address + " = " + (s1_3a.op & ~3) + "," );
                            oout.println( "        " + s1_2a.name + s1_2a.address + " = " + (s1_2a.op & ~3) + "," );
                        }
		    } else if( have_size_4 ) {
                        IO.Std.err.println( "4: have 4: " + s4_3a );
                        oout.println( "        " + s4_3a.name + " = " + (s4_3a.op & ~3)+ "," );
                        if( s4_2a != null ) {
                            IO.Std.err.println( "4: have 2a:" + s4_2a );
                            oout.println( "        " + s4_3a.name + s4_3a.address + " = " + (s4_3a.op & ~3) + "," );
                            oout.println( "        " + s4_2a.name + s4_2a.address + " = " + (s4_2a.op & ~3)+ "," );
                        }
		    } else if( have_size_8 ) {
			IO.Std.err.println( "have 8: " + s8_3a );
			oout.println( "        " + s8_3a.name + " = " + s8_3a.op + "," );
			if( s8_2a != null ) {
			    IO.Std.err.println( "8: have 2a:" + s8_2a );
			    oout.println( "        " + s8_3a.name + s8_3a.address + " = " + s8_3a.op + "," );
			    oout.println( "        " + s8_2a.name + s8_2a.address + " = " + s8_2a.op + "," );
			}
                    }

		    if( have_size_0 ) {
			IO.Std.err.println( "have 0..." );
			oout.println( "        " + s0_3a.name + "_0 = " + s0_3a.op + "," );
			if( s0_2a != null ) {
			    IO.Std.err.println( "have 2a..." );
			    oout.println( "        " + s0_3a.name + s0_3a.address + "_0 = " + s0_3a.op + "," );
			    oout.println( "        " + s0_2a.name + s0_2a.address + "_0 = " + s0_2a.op + "," );
			}
		    }

                    if( have_size_1 ) {
                        IO.Std.err.println( "2: have 1..." );
                        oout.println( "        " + s1_3a.name + "_1 = " + s1_3a.op + "," );
                        if( s1_2a != null ) {
                            IO.Std.err.println( "2: have 2a..." );
                            oout.println( "        " + s1_3a.name + s1_3a.address + "_1 = " + s1_3a.op + "," );
                            oout.println( "        " + s1_2a.name + s1_2a.address + "_1 = " + s1_2a.op + "," );
                        }
                    }

                    if( have_size_4 ) {
                        IO.Std.err.println( "2: have 4..." );                   
                        oout.println( "        " + s4_3a.name + "_4 = " + s4_3a.op + "," );
                        if( s4_2a != null ) {
                            IO.Std.err.println( "2: have 2a..." );
                            oout.println( "        " + s4_3a.name + s4_3a.address + "_4 = " + s4_3a.op + "," );
                            oout.println( "        " + s4_2a.name + s4_2a.address + "_4 = " + s4_2a.op + "," );
                        }
                    }

		    if( have_size_8 ) {
			IO.Std.err.println( "have 8..." );
			oout.println( "        " + s8_3a.name + "_8 = " + s8_3a.op + "," );
			if( s8_2a != null ) {
			    IO.Std.err.println( "have 2a..." );
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
            for( i = 0; i < list.getLength(); i = i + 1 ) {
                u = cast<Terminal>(list.get(i));
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
            for( i = 0; i < list.getLength(); i = i + 1 ) {
                u = cast<Terminal>(list.get(i));
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
        }
    }
}
