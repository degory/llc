
namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;

    use Gen.ITree;
    use Gen.IBlock;
    use Gen.ILabel;
    use Gen.IString;
    use Gen.Machine;
    use Gen.TempFactory;
    use Gen.MBitSet;

    class Package extends ParseTree {
        Statement body;
        SymbolList sl;
	bool is_trusted;
        
        void init( int line_number, Statement body ) {
            super.init(line_number);
            this.file_name = file_name;
            this.body = body;
            this.sl = null;	    
        }

        void parseImports( CompileState state ) {
            state.beginPackage( file_name, null );
	    setFileName();

	    is_trusted = state.isSourceFileTrusted( file_name );
	    state.setTrusted( is_trusted );
            
            body.parseImports( state );
            state.endPackage();
        }
               
        void declareGlobalSymbols( CompileState state ) {
            state.beginPackage( file_name, null );
	    setFileName();
	    state.setTrusted( is_trusted );
            
            
            body.declareGlobalSymbols( state );
            state.endPackage();
        }

	void useTypes( CompileState state ) {
            state.beginPackage( file_name, null );
	    setFileName();
	    state.setTrusted( is_trusted );

	    body.useTypes( state );

	    state.endPackage();
	}

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "check templates for source file: " + file_name );
	    state.beginPackage( file_name, null );
	    setFileName();
	    state.setTrusted( is_trusted );            

	    body.checkTemplates( state );
	    state.endPackage();
	}
        
        void declareClassSymbols( CompileState state ) {
            state.beginPackage( file_name, null );

	    setFileName();            
	    state.setTrusted( is_trusted );
            
            body.declareClassSymbols( state );
            state.endPackage();
        }

        void declareSymbols( CompileState state ) {
            state.beginPackage( file_name, null );
	    setFileName();
	    state.setTrusted( is_trusted );
            
            body.declareSymbols( state );
            state.endPackage();
        }


	void checkInline( CompileState state ) {
	    state.beginPackage( file_name, null );
	    setFileName();
	    state.setTrusted( is_trusted );
            
	    body.checkInline( state );
	    state.endPackage();
	}

	void prepareInline( CompileState state ) {
	    state.beginPackage( file_name, null );
	    setFileName();
	    state.setTrusted( is_trusted );
            
	    body.prepareInline( state );
	    state.endPackage();
	    // IO.Std.err.println( "end inline pass: " + i + " file " + file_name );
	}

	void compile( CompileState state ) {
	    // var temp_factory = new TempFactory( TempFactory.CurrentTemp, 0 );
	    // var worker = new CompileWork( state, this, temp_factory );
	    // state.submit( worker );

	    compile2( state );
	}
        
        void compile2( CompileState state ) {
	    // IO.Std.err.println( ">>> " + file_name );
	    // IO.Std.err.println( "compile package: " + file_name );

            state.beginPackage( file_name, null );
	    setFileName();
	    state.setTrusted( is_trusted );
	    
            body.compile( state );            

	    print( state );
            state.endPackage();	    
	    // IO.Std.err.println( "<<< " + file_name );

	    // state.walk( this );
        }

	void print( CompileState state ) {
	    if( state.WantPrint ) {
		int from = file_name.lastIndexOf('/');
		if( from < 0 ) {
		    from = 0;
		}
		String s = state.CacheDir + file_name.substring( from, file_name.Length-2 ) + ".h";
		IO.Std.out.println( "would output to: '" + s + "'" );

		IO.Writer o = IO.File.openCreate( s );

		Printer p = new Printer( o );
		pl(p);
		
		body.print( state, p );

		o.close();
	    }
	}
    }

    class NameSpace extends Statement {
        // String qualified_name;
        Identifier name;
        Statement body;
        Container n;
        SymbolList use_list; // saved use list as use list must be null when parser/compiler not operating within this namespace 

        void init( int line_number, Identifier name, Statement body ) {
            super.init( line_number );
            this.name = name;
            this.body = body;
            this.n = null;
            this.use_list = new SymbolList();
        }

        void declareGlobalSymbols( CompileState state ) {
            // this.qualified_name = name.getHumanName( state );
            n = state.declareNameSpace( name, name.Name );
            state.enterNameSpace( n );
	    state.UseList = use_list;
            if( body != null ) {
                body.declareGlobalSymbols( state );
            }
            state.exitNameSpace( n );
        }

	void useTypes( CompileState state ) {
            // this.qualified_name = name.getHumanName( state );
            n = state.declareNameSpace( name, name.Name );
            state.enterNameSpace( n );
	    state.UseList = use_list;
            if( body != null ) {
                body.useTypes( state );
            }
            state.exitNameSpace( n );
	}

	void checkTemplates( CompileState state ) {
            state.enterNameSpace( n );
	    state.UseList = use_list;
            if( body != null ) {
                body.checkTemplates( state );
            }
	    
            state.exitNameSpace( n );
	}

        void declareClassSymbols( CompileState state ) {
            state.enterNameSpace( n );
	    state.UseList = use_list;
            if( body != null ) {
                body.declareClassSymbols( state );
            }
            state.exitNameSpace( n );
        }	

        void declareSymbols( CompileState state ) {
            state.enterNameSpace( n );
	    state.UseList = use_list;
            if( body != null ) {
                body.declareSymbols( state );
            }
            state.exitNameSpace( n );
        }	

        void checkInline( CompileState state ) {
            state.enterNameSpace( n );
	    state.UseList = use_list;
            if( body != null ) {
                body.checkInline( state );
            }
            state.exitNameSpace( n );
        }

	void prepareInline( CompileState state ) {
            state.enterNameSpace( n );
	    state.UseList = use_list;
            if( body != null ) {
                body.prepareInline( state );
            }
            state.exitNameSpace( n );
	}

        void compile( CompileState state ) {
            state.enterNameSpace( n );
	    state.UseList = use_list;
            if( body != null ) {
                body.compile( state );
            }
            state.exitNameSpace( n );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.print( "namespace " );
	    name.print( state, p );
	    p.println( " {" );
	    p.indent();
	    body.print( state, p );
	    p.outdent();
	    p.println( "}" );
	}

        String toString() {
            StringBuffer result = new StringBuffer();
            result.append( "namespace " );
            result.append( name );
            result.append( body );

	    return result;
        }
    }

    class Use extends Statement {
        Identifier name;

        void init( int line_number, Identifier name ) {
            super.init( line_number );
            this.name = name;
        }

        void declareGlobalSymbols( CompileState state ) {
        }

	void useTypes( CompileState state ) {
            // Symbol symbol = state.findSymbol( name.getName() );
	    // do not report errors, search only for types:
            Symbol symbol = name.getSymbol(state,false,Symbol.FIND_TYPE);
            if( symbol == null ) {
                error( "cannot find type or namespace " + name.Name );
            } else if( symbol.Kind != Symbol.NAMESPACE && symbol.Kind != Symbol.ENUM && symbol.Kind != Symbol.CLASS ) {
                error( "cannot use " + symbol.HumanName );
            } else {
                state.useNameSpace( this, cast<Container>(symbol) );
            }
	}

	void checkTemplates( CompileState state ) {
	}

        void declareSymbols( CompileState state ) {
        }

        void compile( CompileState state ) {
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.print( "using " );
	   
	    name.print( state, p );
	    p.println( ";" );
	}
    }
}