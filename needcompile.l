#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import map;
import stream;
import stat;

import symbol;
import compilestate;

namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;

    use Generic.Vector;

    enum CompileStatus {
        CURRENT,
	LIBRARY,
        STALE,
        METHOD,
        BAD_HASH
    }

    class NeedCompile {
        CompileState state;

	Vector<LibraryHashFile> libraries;

        void init( CompileState state ) {
            this.state = state;

	    libraries = new Vector<LibraryHashFile>();
        }

	void addLibraryHashFile( LibraryHashFile l ) {
	    // IO.Std.err.println( "add library hash file: " + l );
	    libraries.add( l );
	}

	get int Hash[String name] {
	    foreach( var l; libraries.Iterator ) {
		int h = l.Hash[name];
		if( h != 0 ) {
		    return h;
		}
	    }

	    return 0;
	}	    

        // check classes that this_class depends on against the stored hashes in this_class's .depend file
        // return true if this_class needs to be compiled, false otherwise
        bool checkHashList( String this_class ) {
            StringBuffer buffer = new StringBuffer( state.CacheDir );
            buffer.append( this_class );
            buffer.append( ".depend" );
	    // IO.Std.err.println( "checkHashList: " + buffer );
            try {
                IO.Reader f = IO.File.openRead( buffer );

                HashList list = new HashList( state );
                list.readFrom(f);
                return list.check( state.CacheDir, this_class );
            } catch( IO.IOException ie ) {
                // IO.Std.err.println( "CCCCCC: compile " + this_class + ": no or bad dependancy file" );
                return true;
            }
        }

	bool isInLibrary( String class_name ) {
	    return Hash[class_name] != 0;
	}

        CompileStatus needCompile( String source_name, String class_name, int hash, bool one_file ) {
	    foreach( var l; libraries.Iterator ) {
		var h = l.Hash[class_name];
		if( h != 0 ) {
		    if( h == hash ) {
			// IO.Std.err.println( "no need to compile " + class_name + " in library " + l );
			return CompileStatus.LIBRARY;
		    } else {
			// IO.Std.err.println( "bad hash " + class_name + ": library hash " + h + " versus source hash " + hash );
			return CompileStatus.BAD_HASH;
		    }
		}
	    }

	    if( one_file ) {
		return CompileStatus.STALE;
	    }

	    if( needCompile2( source_name, class_name, hash ) ) {
		// IO.Std.err.println( "stale " + class_name + " in current project" );
		return CompileStatus.STALE;
	    } else {
		// IO.Std.err.println( "up to date " + class_name + " in current project" );
		return CompileStatus.CURRENT;
	    }
	    /*
	    if( result ) { 
		IO.Std.err.println( "CCCCCC: need compile: " + source_name + "," + class_name + "," + hash + ": " + result );
	    } 
	    */
	}

        bool needCompile2( String source_name, String class_name, int hash ) {
	    // IO.Std.err.println( "CCCCCC: need to compile '" + source_name + "' for class " + class_name + ", hash " + String.hex(hash) + "?" );

            var s = new IO.Stat(), t = new IO.Stat();
            var output_name = state.getObjectFileName(class_name);

            int compiled_hash;

            if( !s.stat( source_name ) ) {
		throw new System.Exception( "oops: source file " + source_name + " absent" );
            }

	    if( !t.stat( output_name ) ) {
		return true;
	    }

	    if( !t.after(s) ) {
		return true;
	    }

	    // have an existing object file and it's newer than the source so we may not need to compile it.
	    
	    // read the hash of the class definition in:
	    try {
		IO.Reader f = IO.File.openRead( state.CacheDir + class_name + ".hash" );
		compiled_hash = f.readInt();
		f.close();
	    } catch( IO.IOException ie1 ) {
		/*
		  if( state.WantPIC ) {
		  IO.Std.err.println( "compiling " + class_name + " because no hash file present" );
		  }
		*/
		// IO.Std.err.println( "CCCCCC: no hash file present/problem reading hash for: " + class_name + ": " + ie1 );
		return true;
	    }
		
	    try {
		// IO.Std.err.println( "compiled hash " + compiled_hash + " == " + hash + "?" );
		if( compiled_hash == hash ) {
		    // the parsed class defintion matches it's on disk hash (which it really ought to do
		    // since we don't think the source has changed since last compilation). Now check
		    // classes that this class depends on:
		    if( !checkHashList( class_name ) ) {
			// no dependant classes have changed either so we can safely use the existing
			// object file without recompiling
			
			// IO.Std.err.println( "hash list is OK for " + class_name );
			// state.addLinkFile( output_name );
			// IO.Std.err.println( "hashes OK, adding link file: " + output_name );
			return false;			 
		    }
		}
	    } catch( IO.IOException ie ) {
		IO.Std.err.println( "CCCCCC: problem checking dependancies for: " + class_name + ": " + ie );
		// could not check dependency hashes - need to compile
	    }

	    /*
	      if( state.WantPIC ) {
	      IO.Std.err.println( "compiling " + class_name + " because of dependancy change" );
	      }
	    */
	    

	    // source file changed since object file was last written - need to recompile.
	    // write out the current class defition hash:
	    /*
            IO.Writer g = IO.File.openCreate( state.CacheDir + class_name + ".hash" );
            g.write( "" + hash + "\n" );
            g.close();
	    */

	    // IO.Std.err.println( "CCCCCC: will compile: " + class_name );
            return true;
        }
    }

    class HashEntry extends Object {
        public int h;
        public String name;

        void init( int h, String name ) {
            super.init();
            this.h = h;
            this.name = name;
        }

        public int hash() {
            return name.hash();
        }

        public String toString() {
            StringBuffer result = new StringBuffer();
            result.append( h );
            result.append( ' ' );
            result.append( name );
            result.append( '\n' );
	    return result;
        }
    }

    class HashList {
        CompileState state;
        Generic.Map<String,HashEntry> map;
        
        void init( CompileState state ) {
            this.state = state;
            map = new Generic.Map<String,HashEntry>();
        }

        void add( int h, String n ) {
	    // IO.Std.err.println( "add: " + n + "->" + String.hex(h) );
            map[n] = new HashEntry( h, n );
        }

        void forceAdd( int h, String n ) {
	    // IO.Std.err.println( "add: " + n + "->" + String.hex(h) );
            map[n] = new HashEntry( h, n );
        }

        int find( String n ) {
            HashEntry e = map[n];
            if( e != null ) {
                return e.h;
            } else {
                return 0;
            }
        }

        void writeTo( IO.Writer f ) {
            foreach( HashEntry e; map.elements() ) {
                f.write( e.toString() );
                f.write( '\n' );
            }
        }

        void readFrom( IO.Reader f ) {
	    // IO.Std.err.println( "read hash list: " );
            while( !f.isAtEnd() ) {
		int h = f.readInt();

		if( f.isAtEnd() ) {
		    break;
		}
		    
                int c = f.read(); // skip single space
	        // IO.Std.err.println( "read hash: " + h );

                StringBuffer name = new StringBuffer();
		
                do {
		    c = f.read();
		    if( f.isAtEnd() || c == cast<int>('\n') ) {
		        break;
		    }

                    name.append( cast<char>(c) );
                } while( true );

		if( name.Length == 0 ) {
		    break;
		}
                
		// IO.Std.err.println( String.hex(h) + " " + name );
                add( h, name );
            }
	    // IO.Std.err.println( "done readFrom" );

            f.close();
        }

	// check this_class against the hashes of classes it is dependent on. return true if any do not match (true=>compile required)
        bool check( String prefix, String this_class ) {
	    // IO.Std.err.println( "check " + prefix + ": " + this_class + "..." );

            foreach( HashEntry e; map.elements() ) {
                if( e.name.equals( this_class ) ) {
		    // IO.Std.err.println( e.name + " automatic match for " + this_class );
                    continue;
                }       
                
                Symbol s = state.findClass( e.name );
                if( s == null ) {
                    // IO.Std.err.println( this_class + " depends on " + e.name + " but not in symbol table: rebuilding" );
                    return true;
                } else if( s.Kind != Symbol.CLASS ) {
                    // IO.Std.err.println( this_class + " depends on " + e.name + " but its not a class (" + s.getKind() + "): rebuilding" );
                    return true;
                }
                if( cast<Container>(s).Hash != e.h ) {
                    // IO.Std.err.println( "CCCCCC: " + this_class + ": hash in depend file " + e.name + "/" + e.h + " doesn't match " + s.HumanName + "/" + cast Container(s).Hash);
                    return true;
                }

		// IO.Std.err.println( "apparently OK: " + e.name + ", " + e.h );
            }
	    // IO.Std.err.println( "CCCCCC: class " + this_class + " does not need building - all dependancies match" );
            return false;
        }
    }
}
