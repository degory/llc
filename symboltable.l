// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

namespace Parse { 
    class SymbolTable extends System.Object {
        const int MAX_LEVEL = 25;
        int level;
        SymbolList[] scope;
        SymbolList current_scope;
        
        void init() {
            super.init();
            scope = new SymbolList[MAX_LEVEL];
            
            level = -1;
	    // IO.Std.err.println( "new SymbolTable: level = " + level );
            enterScope();
        }

	SymbolTable copy() {
	    SymbolTable result = cast SymbolTable(clone());

	    assert(level == 0);
	   
	    var new_scope = new SymbolList[MAX_LEVEL];

	    /*
	    for( var i = 0; i <= level; i = i + 1 ) {
		new_scope[i] = scope[i];
	    }

	    */

	    result.scope = new_scope;
	    result.scope[0] = scope[0]; // global scope
	    return result;
	}
        
        void enterScope() {
            current_scope = new SymbolList();
	    // IO.Std.err.println( "level: " + level );
            level = level + 1;
	    // IO.Std.err.println( "level<--" + level );
            scope[level] = current_scope;
	    // IO.Std.err.println( "scope[" + level + "] = " + scope[level] );
        }
        
        void enterScope( SymbolList s ) {
            current_scope = s;
	    // IO.Std.err.println( "level: " + level );
            level = level + 1;
	    // IO.Std.err.println( "level<--" + level );
            scope[level] = current_scope;
	    // IO.Std.err.println( "scope[" + level + "] = " + scope[level] );
        }
        
        void exitScope() {
            scope[level] = null;
            level = level - 1;
            current_scope = scope[level];
        }
        
        SymbolList getCurrentScope() {
            return current_scope;
        }
        
        Symbol findGlobal( System.String name, int find_what ) {
            return scope[0].find( name, find_what );
        }
        
        Symbol findInCurrentScope( System.String name, int find_what ) {
            return current_scope.find( name, find_what );
        }
        
        void add( Symbol symbol ) {
            current_scope.add( symbol );
        }
        
        void addAll( SymbolList list ) {
            throw new System.Exception( "don't use: unsafe" );
            current_scope.addAll( list );
        }

	SymbolList[] getSymbolState() {
	    SymbolList[] result = new SymbolList[level+1];
	    for( int i = 0; i <= level; i = i + 1 ) {
		result[i] = scope[i];
	    }

	    return result;
	}

	void setSymbolState( SymbolList[] s ) {
	    scope = new SymbolList[MAX_LEVEL];

      	    for( level = 0; level < s.length; level = level + 1 ) {
		scope[level] = s[level];
	    }
	    level = level - 1;
	    current_scope = scope[level];
	}
        

	System.String toString() {
	    System.StringBuffer result = new System.StringBuffer();

	    for( int i = level; i >= 0; i = i - 1 ) {
		result.append( "level " + i + ": " + scope[i] + "\n" );
	    }

	    return result;
	}
	/*
        void useAll( SymbolList list ) {
            throw new System.Exception( "is this safe?" );
            current_scope.useAll( list );
        }
	*/
    }
}
