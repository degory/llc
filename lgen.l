// Copyright (C) Degs 2009 all rights reserved

import map;
import stream;
import lgen_token;
import args;

namespace LGen {
    enum Kind { TERM=1, NONTERM }


    public enum Token {
        IDENTIFIER,
        NUMBER,
        STRING,
	CODE_STRING,
        TREESTRING,
        CHARACTER,

        OPEN_BRACE,
        CLOSE_BRACE,
        OPEN_PAREN,
        CLOSE_PAREN,
        OPEN_SQUARE,
        CLOSE_SQUARE,

        ASSIGN,

        LT,
        LE,
        GT,
        GE,
        EQ,
        NE,

        BOOL_NOT,
        BOOL_AND,
        BOOL_OR,

        INT_NOT,
        INT_AND,
        INT_OR,

        ADD,
        SUB,
        MUL,
        DIV,
        SHL,
        SHR,

        DOT,
        COMMA,
        COLON,
        SEMICOLON,
        DOLLAR,

        TERMINAL,
        RULE,
        START,
	REWRITE,
        MACHINE,

        UNKNOWN,
        EOF
    }

    enum Mode {
	REWRITE,
	MACHINE,
	BOTH
    }

    class Symbol extends System.Object {
        public System.String name;
        public Kind kind;

        void init( System.String name, Kind kind ) {
            super.init();
            this.name = name;
            this.kind = kind;
        }

	int getSize() {
	    return 8;
	}
    }

    class Terminal extends Symbol {
        public int esn; 
        public int arity;       
        public Terminal link;
        public Rule rules;      

        void init( System.String name, int esn, int arity ) {
            super.init( name, Kind.TERM );
            this.esn = esn;
            this.arity = arity;
        }

        System.String toString() {
            return name;
        }

	int getSize() {
	    int t = esn & 3;
	    if( t == 0 ) {
		return 0;
	    } else if( t == 1 ) {
		return 1;
	    } else if( t == 2 ) {
		return 4;
	    } else if( t == 3 ) {
		return 8;
	    } else {
		throw new System.Exception( "unexpected operation size: " + t );
	    }
	}
    }

    class NonTerminal extends Symbol {
        public int number;
        public int lhscount;
        public bool reached;
        public Rule rules;      
        public NonTerminal link;
        public Rule chain;      

        void init( System.String name, int number ) {
            super.init( name, Kind.NONTERM );
            this.number = number;
        }

        System.String toString() {
            return name;
        }
    }

    class Tree extends System.Object {
        public Symbol op;               /* a terminal or nonterminal */

        public Tree left, right;        /* operands */
        public int nterms;              /* number of terminal nodes in this tree */

        void init( Symbol op, Tree left, Tree right ) {
            super.init();
            this.op = op;
            this.left = left;
            this.right = right;
        }

        System.String toString() {
            System.StringBuffer result = new System.StringBuffer();
            toString(result);
            return result;
        }

	void toReWriteString( System.StringBuffer b, System.String node, int ref n, int size ) {
	    if( op.kind == Kind.TERM ) {
		b.append( "new ITree(0,Op." );
	    
		b.append( op );
		char c = b.charAt(b.getLength()-1);
		// int size;
		
		if( c >= '0' && c <= '9' ) {
		    size = cast<int>(c - '0');
		    // } else {
		    // throw new System.Exception( "missing size: " + b );
		}

		b.append( ',' );
		b.append( size );

		if( size == 0 ) {
		    size = Main.word_size;
		}

		if( left != null ) {
		    b.append( ',' );
		    left.toReWriteString( b, null, n, size );
		}
		if( right != null ) {
		    b.append( ',' );
		    right.toReWriteString( b, null, n, size );
		}
		if( node != null ) {
		    b.append( ',' );
		    b.append( node );
		    b.append( ".getValue()" );
		}
		b.append( ')' );
	    } else {
		b.append( '$' );
		b.append( n );
		n = n + 1;
	    }
	}

	System.String toReWriteString( Generator gen ) {
	    int n = 0;
	    System.StringBuffer b = new System.StringBuffer();

	    IO.Std.err.println( "to rewrite string: " + this );

	    toReWriteString( b, "node", n, op.getSize() );

	    // IO.Std.err.println( this.toString() + "->" + b );
	    return b;
	}

        void toString( System.StringBuffer b ) {
	    if( left != null || right != null ) {
		b.append( '[' );
	    }
            b.append( op );

            if( left != null ) {
		b.append( ' ' );
                left.toString( b );
            }
            if( right != null ) {
		b.append( ' ' );
                right.toString( b );
            }
	    if( left != null || right != null ) {
		b.append( ']' );
	    }
        }

	void findArgs( System.String prefix, Util.Vector v ) {
	    if( op.kind == Kind.NONTERM ) {
		v.add( prefix );
	    } else {
		System.String result;
		if( left != null ) {
		    left.findArgs( prefix + ".getLeft()", v );
		}
		if( right != null ) {
		    right.findArgs( prefix + ".getRight()", v );
		}
	    }
	}

	Terminal getTerm() {
	    if( op.kind == Kind.TERM ) {
		return cast<Terminal>(op);
	    } else {
		throw new System.Exception( "not a terminal: " + this );
	    }
	}

	int getSize() {
	    return op.getSize();
	}
    }


    class Rule extends System.Object {          /* rules: */
        public NonTerminal lhs;        /* lefthand side nonterminal */
        public Tree pattern;            /* rule pattern */

        public int ern;         /* external rule number */
        public int packed;              /* packed external rule number */
        public int cost;                /* cost, if a constant */

	public int used_temp;           // temporaries this rule generates (bitmap)

        public System.String code;      /* cost, if an expression */
        public System.String mtree;     /* code to create corrasponding MTree */

        public Rule link;               /* next rule in ern order */
        public Rule next;               /* next rule with same pattern root */
        public Rule chain;              /* next chain rule with same rhs */
        public Rule decode;             /* next rule with same lhs */
        public Rule kids;               /* next rule with same _kids pattern */

        void init() {
            super.init();
        }

        System.String toString() {
            return pattern.toString() + " -> " + lhs + " " + ern;
        }

    }

    class Main {
	public static int word_size;

        void init() {
	    Generator g;
	    Mode mode;
	    System.String[] args = System.Arguments.getProgramArguments();
	    if( args.length < 3 ) {
		throw new System.Exception( "usage: lgen [Machine|Rewrite] word-size" );
	    }

	    if( args[1].charAt(0) == 'M' || args[1].charAt(0) == 'm' ) {
		IO.Std.err.println( "operating in machine mode" );
		mode = Mode.MACHINE;
	    } else if( args[1].charAt(0) == 'R' || args[1].charAt(0) == 'r' ) {
		IO.Std.err.println( "operating in rewrite mode" );
		mode = Mode.REWRITE;
	    } else {
		IO.Std.err.println( "unexpected value: " + args[1].charAt(0) );
		throw new System.Exception( "usage: lgen [Machine|Rewrite] word-size" );
	    }

	    word_size = args[2].parseInt();

	    if( word_size != 4 && word_size != 8 ) {
		throw new System.Exception( "expected word size of 4 or 8 bytes" );
	    }
	    
	    g = new Generator(mode);
        }
    }

    class Generator {
        Util.Map symbols;
        Rule rules;
        Terminal terms;
        NonTerminal nts;
        int ntnumber;
        int nrules;
        NonTerminal start;
        public Tokenizer tokenizer;

	int current_temp;
	int used_temp;

        char quote;

        Mode mode;

        System.String name_space;
        System.String tree_name;
        System.String result_name;
        System.String preamble_string;

        void parse( IO.Reader s ) {
	    tokenizer = new Tokenizer(s);
	    tokenizer.nextToken();

	    if( mode == Mode.MACHINE ) {
		name_space = "Gen";
		tree_name = "ITree";
		result_name = "MTree";
		preamble_string = "";
	    } else if( mode == Mode.REWRITE ) {
		name_space = "ReWrite";
		tree_name = "ITree";
		result_name = "ITree";
		preamble_string = "use Gen.ITree; use Gen.IString; use Gen.INumber;";
	    }

            while( !tokenizer.isEndOfFile() ) {
                // IO.Std.err.println( "top loop..." );
                switch( tokenizer.getToken() ) {
                case Token.START:
                    parseStart();

                case Token.TERMINAL:
                    parseTerminalDefinition();

                case Token.RULE:
                    parseRuleDefinition(Mode.BOTH);

		case Token.REWRITE:
		    parseRuleDefinition(Mode.REWRITE);

		case Token.MACHINE:
		    parseRuleDefinition(Mode.MACHINE);

                default:
                    throw new System.Exception( "expected a rule: unexpected token: " + tokenizer.getName(tokenizer.getToken()) + " " + tokenizer.getBuffer() );
                }
                // IO.Std.err.println( "bottom loop..." );
            }
        }

        Token eatToken( Token t ) {
            if( tokenizer.getToken() != t ) {
                throw new System.Exception( "expected: " + tokenizer.getName(t) + ", read: " + tokenizer.getName(tokenizer.getToken()));
            }
            tokenizer.nextToken();
        }

        void parseStart() {
            eatToken(Token.START);
            System.String name = tokenizer.getBuffer();
            eatToken(Token.IDENTIFIER);
            nonterm( name );
        }

        void parseTerminalDefinition() {
            eatToken(Token.TERMINAL);
            System.String name = tokenizer.getBuffer();
            eatToken(Token.IDENTIFIER);
            eatToken(Token.ASSIGN);
            System.String value = tokenizer.getBuffer();
            eatToken(Token.NUMBER);

            // IO.Std.err.println( "terminal " + name + " = " + value + "/" + value.parseInt() );
            term( name, value.parseInt() );
        }

	void skipCodeTree() {
	    if( tokenizer.getToken() == Token.OPEN_SQUARE ) {
		tokenizer.nextToken();
		while( tokenizer.getToken() != Token.CLOSE_SQUARE ) {
		    skipCodeTree();
		}
		tokenizer.nextToken();
	    } else {
		tokenizer.nextToken();
	    }
	}


        void parseRuleDefinition(Mode m) {
	    tokenizer.nextToken();
            System.String name = tokenizer.getBuffer();
            eatToken(Token.IDENTIFIER);
            eatToken(Token.ASSIGN);

	    Tree t;
	    if( m != mode && m != Mode.BOTH ) {
		skipTree();
	    } else {
		// IO.Std.err.println( "parsing tree... ");
		t = parseTree();
		// IO.Std.err.println( "rule tree is: '" + t + "'" );
	    }


            // IO.Std.err.println( "rule tree is: '" + t + "'" );
            
            System.String cost = parseCost();

	    used_temp = 0;
	    System.String mtree;
	    if( tokenizer.getToken() == Token.STRING || tokenizer.getToken() == Token.CODE_STRING ) {
		mtree = tokenizer.getBuffer();
		tokenizer.nextToken();
	    } else if( tokenizer.getToken() == Token.OPEN_SQUARE ) {		
		if( m != mode && m != Mode.BOTH ) {
		    skipCodeTree();
		} else {
		    int size = t.getSize();
		    if( size == 0 ) {
			size = Main.word_size;
		    }
		    System.StringBuffer b = new System.StringBuffer();
		    parseCodeTree( b, size, "Int" + size );		
		    mtree = b;
		}
	    } else {
		throw new System.Exception( "unexpected code token in rule: " + name );
	    }


            // IO.Std.err.println( "rule " + name + " = " + t + " " + cost );

	    if( mode == Mode.REWRITE ) {
		if( m == Mode.MACHINE ) {
		    // IO.Std.err.println( "skipping machine pattern: " + name + " in rewrite mode" );
		} else if( m == Mode.BOTH ) {
		    // IO.Std.err.println( "using both pattern: " + name + " = " + t + " in rewrite mode" );
		    rule( name, t, t.toReWriteString(this), cost, used_temp );
		} else {
		    // IO.Std.err.println( "using rewrite pattern: " + name + " = " + t + " in rewrite mode" );
		    rule( name, t, mtree, cost, used_temp );
		}
	    } else if( mode == Mode.MACHINE ) {
		if( m == Mode.MACHINE || m == Mode.BOTH ) {
		    // IO.Std.err.println( "using machine/both pattern: " + name + " = " + t + " in machine mode" );
		    rule( name, t, mtree, cost, used_temp );
		} else {
		    // IO.Std.err.println( "skipping rewrite pattern: " + name + " in machine mode" );
		}
	    }
        }

        Tree parseTree() {
            Tree left, right;
	    bool needs_rewrite = false;
	    System.String name;
	    if( tokenizer.getToken() == Token.OPEN_SQUARE ) {
		eatToken( Token.OPEN_SQUARE );
		name = tokenizer.getBuffer();
		eatToken( Token.IDENTIFIER );

		if( tokenizer.getToken() != Token.CLOSE_SQUARE ) {
		    left = parseTree();
		    if( tokenizer.getToken() != Token.CLOSE_SQUARE ) {
			right = parseTree();
		    }
		}
		eatToken( Token.CLOSE_SQUARE );
	    } else {
		name = tokenizer.getBuffer();
		eatToken( Token.IDENTIFIER );
	    }

            // IO.Std.err.println( "about to call tree(" + name + "," + left + "," + right + ") from " + new System.Exception("tree") );
            Tree result = tree( name, left, right );
            // IO.Std.err.println( "created: " + result );

            return result;
        }

        void skipTree() {
            Tree left, right;
	    System.String name;
	    if( tokenizer.getToken() == Token.OPEN_SQUARE ) {
		eatToken( Token.OPEN_SQUARE );
		name = tokenizer.getBuffer();
		eatToken( Token.IDENTIFIER );

		if( tokenizer.getToken() != Token.CLOSE_SQUARE ) {
		    skipTree();
		    if( tokenizer.getToken() != Token.CLOSE_SQUARE ) {
			skipTree();
		    }
		}
		eatToken( Token.CLOSE_SQUARE );
	    } else {
		name = tokenizer.getBuffer();
		eatToken( Token.IDENTIFIER );
	    }
        }

	int parseCodeCall( System.StringBuffer b, int size, System.String set ) {
	    if( tokenizer.getToken() == Token.DOLLAR ) {
		// IO.Std.err.println( "parseCodeCall: calling parseCodeOperand..." );
		parseCodeOperand( b, size, set, false );
	    } else if( tokenizer.getToken() == Token.STRING || tokenizer.getToken() == Token.CODE_STRING ) {
		// IO.Std.err.println( "code-string operation: '" + tokenizer.getBuffer() + "', buffer: '" + b + "'" );
		b.append( tokenizer.getBuffer() );
		tokenizer.nextToken();
		// IO.Std.err.println( "token now: " + tokenizer.getName(tokenizer.getToken()) );
	    } else if( tokenizer.getToken() != Token.IDENTIFIER ) {
		throw new System.Exception( "expected identifier parsing tree code call, read: " + tokenizer.getName(tokenizer.getToken()) );
	    } else {
		parseCodeIdentifier(b,size);
	    }

	    if( mode == Mode.REWRITE ) {
		b.append( ',' );
		// IO.Std.err.println( "buffer: '" + b + "' next token: " + tokenizer.getName(tokenizer.getToken()) );
		if( tokenizer.getToken() == Token.COLON || tokenizer.getToken() == Token.SUB ) {
		    tokenizer.nextToken();
		    b.append( tokenizer.getBuffer() );
		    size = tokenizer.getBuffer().parseInt();
		    if( tokenizer.getToken() != Token.NUMBER ) {
			throw new System.Exception( "expected size parsing tree code call" );
		    }
		    tokenizer.nextToken();
		} else {
		    b.append( size );
		}
		if( tokenizer.getToken() != Token.CLOSE_SQUARE ) {
		    b.append( ',' );
		}
	    } else {
		b.append( '(' );
	    }
	    
	    if( size == 0 ) {
		size = Main.word_size;
	    }

	    return size;
	}

	void parseCommaOperands( System.StringBuffer b ) {
	    while( tokenizer.getToken() == Token.COMMA ) {
		tokenizer.nextToken();
		if( tokenizer.getToken() == Token.NUMBER ) {
		    b.append( ',' );
		    b.append( tokenizer.getBuffer() );
		    tokenizer.nextToken();
		} else if( tokenizer.getToken() == Token.IDENTIFIER ) {
		    b.append( ',' );
		    int size;
		    parseCodeIdentifier(b,size);
		}
	    }	      
	}

        void parseCodeIdentifier( System.StringBuffer b, int ref size ) {
	    while( tokenizer.getToken() == Token.IDENTIFIER ) {
		System.String s = tokenizer.getBuffer();

		System.String[] l = { cast<System.String>("_" + size), cast<System.String>("_" + Main.word_size), "_4", "_8", "_1", "_0", "" };
		
		Symbol t = null;
		for( int i = 0; t == null && i < l.length; i = i + 1 ) {
		    t = lookup(s + l[i]);

		    if( t != null ) {
			size = t.getSize();

			b.append( "Op." );
			break;
		    }	    
		}

		b.append( tokenizer.getBuffer() );


		tokenizer.nextToken();
		if( tokenizer.getToken() == Token.DOT ) {
		    tokenizer.nextToken();
		    b.append( '.' );
		} else {
		    return;
		}
	    }
	}

	System.String parseCodeRegSet( System.StringBuffer b, System.String set, bool output ) {
	    if( mode == Mode.REWRITE ) {
	        return set;
	    }
	    set = null;
	    // IO.Std.err.println( "parseCodeRegSet..." );
	    if( tokenizer.getToken() == Token.COLON ) {
		tokenizer.nextToken();
		if( tokenizer.getToken() != Token.IDENTIFIER ) {
		    throw new System.Exception( "expected identifier parsing code tree register set" );
		}
		set = tokenizer.getBuffer();
		tokenizer.nextToken();
	    }
	    if( output && set != null ) {
		// IO.Std.err.println( "colon: appending: " + set + "..." );
		b.append( ".set(MSet." + set + ")" );
	    }
	    // IO.Std.err.println( "result is: '" + b + "'" );
	    return set;
	}

	bool parseDotCode( System.StringBuffer b ) {
	    if( tokenizer.getToken() == Token.DOT ) {
		tokenizer.nextToken();
		if( tokenizer.getToken() != Token.IDENTIFIER ) {
		    throw new System.Exception( "expected .identifier after $n" );
		}
		System.String s = tokenizer.getBuffer();
		tokenizer.nextToken();
		if( s.charAt(0) == 'T' || s.charAt(0) == 't' ) {
		    b.append( ".getTemp()" );
		    return false;
		} else if( s.charAt(0) == 'I' || s.charAt(0) == 'i' ) {
		    b.append( ".getInt()" );
		    return false;
		} else if( s.charAt(0) == 'S' || s.charAt(0) == 's' ) {
		    b.append( ".getString()" );
		    return false;
		} else if( s.charAt(0) == 'V' || s.charAt(0) == 'v' ) {
		    b.append( ".getValue()" );
		    return false;
		} else if( s.charAt(0) == 'C' || s.charAt(0) == 'c' ) {
		    b.append( ".copy()" );
		    return parseDotCode(b);
		} else if( s.charAt(0) == 'L' || s.charAt(0) == 'l' ) {
		    b.append( ".getLeft()" );
		    return parseDotCode(b);
		} else if( s.charAt(0) == 'R' || s.charAt(0) == 'r' ) {
		    b.append( ".getRight()" );
		    return parseDotCode(b);
		} else {
		    throw new System.Exception( "unknown dot code '" + s + "' after $n" );
		}
	    } else {
		return true;
	    }
	}

	void parseTempRegSet( System.StringBuffer b, System.String set ) {
	    if( mode == Mode.REWRITE ) {
		return;
	    }
	    set = parseCodeRegSet( b, set, false );
	    if( set != null ) {
		b.append( ",MSet." + set );
	    }
	}

	void parseCodeOperand( System.StringBuffer b, int size, System.String set, bool output_set ) {
	    // IO.Std.err.println( "parseCodeOperand..." );
	    bool could_be_reg;
	    if( tokenizer.getToken() == Token.DOLLAR ) {
		// IO.Std.err.println( "dollar operand..." );
		tokenizer.nextToken();
		if( tokenizer.getToken() == Token.NUMBER ) {
		    b.append( '$' );
		    b.append( tokenizer.getBuffer() );
		    tokenizer.nextToken();
		    could_be_reg = parseDotCode(b);
		    if( could_be_reg && mode == Mode.MACHINE ) {
			parseCodeRegSet( b, set, output_set );
		    }
		} else {
		    System.String s = tokenizer.getBuffer();
		    tokenizer.nextToken();
		    if( s.getLength() > 1 ) {
			size = s.substring(1).parseInt();
			if( size == 0 ) {
			    size = Main.word_size;
			}
		    }
		    if( s.charAt(0) == 'A' || s.charAt(0) == 'a' ) {
			b.append( "node" );
			could_be_reg = parseDotCode(b);
			if( could_be_reg ) { 
			    parseCodeRegSet( b, set, output_set );
			}
		    } else if( s.charAt(0) == 'T' || s.charAt(0) == 't' ) {
			if( mode == Mode.REWRITE ) {
			    b.append( "new ITree(0,Op.TEMP," + size + ",%T" );
			} else {
			    b.append( "new MReg(%T" );
			    parseTempRegSet(b,set);
			}
			used_temp = used_temp | 1;
			parseCommaOperands(b);
			b.append( ')' );
		    } else if( s.charAt(0) == 'U' || s.charAt(0) == 'u' ) {
			if( mode == Mode.REWRITE ) {
			    b.append( "new ITree(0,Op.TEMP," + size + ",%U" );
			} else {
			    b.append( "new MReg(%U" );
			    parseTempRegSet(b,set);
			}
			used_temp = used_temp | 2;
			parseCommaOperands(b);
			b.append( ')' );
		    } else if( s.charAt(0) == 'L' || s.charAt(0) == 'l' ) {
			b.append( "%L" );
			used_temp = used_temp | 4;
		    } else if( s.charAt(0) == 'M' || s.charAt(0) == 'm' ) {
			b.append( "%M" );
			used_temp = used_temp | 8;
		    } else if( s.charAt(0) == 'R' || s.charAt(0) == 'r' ) {
			if( mode == Mode.REWRITE ) {
			    b.append( "new ITree(0,Op.REGISTER," + size );
			} else {
			    b.append( "new MReg(" );
			}
			parseTempRegSet(b,set);
			parseCommaOperands(b);
			b.append( ')' );
		    } else if( s.charAt(0) == 'S' || s.charAt(0) == 's' ) {
			b.append( "%S" );
		    } else if( s.charAt(0) == 'V' || s.charAt(0) == 'v' ) {
			b.append( "%V" );
		    } else {
			throw new System.Exception( "unexpected dollar token: '" + s + "' parsing code tree" );
		    }
		}
	    } else if( tokenizer.getToken() == Token.COLON ) {
		tokenizer.nextToken();
		if( tokenizer.getToken() != Token.IDENTIFIER ) {
		    throw new System.Exception( "expected identifier parsing register set argument" );
		}
		b.append( "MSet." + tokenizer.getBuffer() );
		tokenizer.nextToken();
	    } else if( tokenizer.getToken() == Token.IDENTIFIER ) {
		parseCodeIdentifier(b,size);
		if( size == 0 ) {
		    size = Main.word_size;
		}

	    } else if( tokenizer.getToken() == Token.NUMBER ) {
		// IO.Std.err.println( "id/number operand..." );
		b.append( tokenizer.getBuffer() );
		tokenizer.nextToken();
	    } else if( tokenizer.getToken() == Token.STRING ) {
		// IO.Std.err.println( "string operand..." );
		b.append( '\"' );
		b.append( tokenizer.getBuffer() );
		b.append( '\"' );
		tokenizer.nextToken();
	    } else if( tokenizer.getToken() == Token.CODE_STRING ) {
		// IO.Std.err.println( "code-string operand..." );
		b.append( tokenizer.getBuffer() );
		tokenizer.nextToken();
	    } else if( tokenizer.getToken() == Token.OPEN_SQUARE ) {
		// IO.Std.err.println( "tree call operand..." );
		if( size == 1 ) {
		    set = "Int1";
		}
		parseCodeTree( b, size, set );
	    } else {
		throw new System.Exception( "unexpected tokeni in code tree operand: " + tokenizer.getName(tokenizer.getToken()) );
	    }
	}

	void parseCodeTree( System.StringBuffer b, int size, System.String set ) {
	    bool needs_rewrite = false;
	    int rewrite_goal = 0;
	    IO.Std.err.println( "parse code tree..." );

	    if( tokenizer.getToken() != Token.OPEN_SQUARE ) {
		throw new System.Exception( "expected '[' parsing code tree" );
	    }
	    tokenizer.nextToken();

	    IO.Std.err.println( "read [..." );
	    if( tokenizer.getToken() == Token.MUL ) {
		IO.Std.err.println( "read *..." );
		needs_rewrite = true;
		tokenizer.nextToken();
	    } else if( tokenizer.getToken() == Token.ADD ) {
		IO.Std.err.println( "read +..." );
		needs_rewrite = true;
		tokenizer.nextToken();
		NonTerminal goal_nt = cast<NonTerminal>(lookup(tokenizer.getBuffer()));
		eatToken( Token.IDENTIFIER );
		rewrite_goal = goal_nt.number;		
	    }

	    if( mode == Mode.REWRITE ) {
		b.append( "new ITree(0," );
	    } else {
		b.append( "new M" );
	    }

	    IO.Std.err.println( "calling parseCodeCall, next token: " + tokenizer.getName(tokenizer.getToken()) );
	    size = parseCodeCall( b, size, set );
	    // set = "Int" + size;
	    while( tokenizer.getToken() != Token.CLOSE_SQUARE ) {
		// IO.Std.err.println( "parse operand into: '" + b + "'" );
		parseCodeOperand( b, size, set, true );
		if( tokenizer.getToken() != Token.CLOSE_SQUARE ) {
		    b.append( ',' );
		}
	    }
	    if( tokenizer.getToken() != Token.CLOSE_SQUARE ) {
		throw new System.Exception( "expected '[' parsing code tree" );
	    }
	    b.append( ')' );
	    if( needs_rewrite ) {
		if( rewrite_goal != 0 ) {
		    b.append( ".rewrite(" + rewrite_goal + ")" );
		} else {
		    b.append( ".rewrite()" );
		}
	    }
	    // IO.Std.err.println( "parsed code tree: '" + b + "'" );
	    tokenizer.nextToken();
	}

        System.String parseCost() {
            if( tokenizer.getToken() == Token.NUMBER || tokenizer.getToken() == Token.STRING || tokenizer.getToken() == Token.CODE_STRING ) {
                System.String result = tokenizer.getBuffer();
                tokenizer.nextToken();
                return result;
            } else {
                eatToken( Token.NUMBER );
            }
        }

        Symbol lookup( System.String name ) {
            System.Object p = symbols.get( name );

            if( p != null ) {
		// IO.Std.err.println( "looking for: '" + name + "' gives: " + p );
                return cast<Symbol>(p);
            } else {
		// IO.Std.err.println( "looking for: '" + name + "' gives: null" );
		return null;
	    }
        }

        void install( Symbol p ) {
            symbols.put( p.name, p );
	    // IO.Std.err.println( "installed: '" + p.name + "' as: " + p );
	    // IO.Std.err.println( "symbol table now: " + symbols );
        }

        void insertLink( NonTerminal ref head, NonTerminal p ) {
            // IO.Std.err.println( "insertLink()..." );
            // IO.Std.err.println( "insertLink(" + head + "," + p + ")" );

            NonTerminal q = head;
            NonTerminal prev = null;
            while( q != null && q.number < p.number ) {
                prev = q;
                q = q.link;
            }
            
            if( prev != null ) {
                prev.link = p;
            } else {
                head = p;
            }
            p.link = q;
        }

        void insertLink( Terminal ref head, Terminal p ) {
            // IO.Std.err.println( "insertLink()..." );
            // IO.Std.err.println( "insertLink(" + head + "," + p + ")" );

            // IO.Std.err.println( "existing list: " + head );
            Terminal q = head;
            Terminal prev = null;
            // IO.Std.err.println( "loop: p = " + p + ", q = " + q );
            while( q != null && q.esn < p.esn ) {
                // IO.Std.err.println( "loop: q = " + cast<int>(q) );
                prev = q;
                // IO.Std.err.println( "after: " + prev );
                
                q = q.link;
            }
            
            if( prev != null ) {            
                prev.link = p;
            } else {
                head = p;
            }
            p.link = q;
        }

        void insertLink( Rule ref head, Rule r ) {
            Rule q = rules;
            Rule prev = null;
            while( q != null ) {
                prev = q;
                q = q.link;
            }

            if( prev != null ) {
                prev.link = r;
            } else {
                head = r;
            }
            r.link = null;

        }

        void insertNext( Rule ref head, Rule r ) {
            Rule q = head;
            Rule prev = q;
            while( q != null ) {
                prev = q;
                q = q.next;
            }

            if( prev != null ) {
                prev.next = r;
            } else {
                head = r;
            }
            r.next = q;
        }    

        void insertDecode( Rule ref head, Rule r ) {
            Rule q = head;
            Rule prev = q;
            while( q != null ) {
                prev = q;
                q = q.decode;
            }
            if( prev != null ) {
                prev.decode = r;
            } else {
                head = r;
            }
            r.decode = q;
        }


        /* nonterm - create a new terminal id, if necessary */
        NonTerminal nonterm(System.String id) {
            Symbol p = lookup(id);

            // IO.Std.err.println( "new non-terminal: '" + id + "'" );

            if( p != null && p.kind == Kind.NONTERM ) {
                return cast<NonTerminal>(p);
            }

            if( p != null && p.kind == Kind.TERM ) {
                throw new System.Exception( "'" + id + "' is a terminal" );
            }

            ntnumber = ntnumber + 1;
            NonTerminal result = new NonTerminal( id, ntnumber );
            install(result);

            if( result.number == 1 ) {
                // IO.Std.err.println( "start non-terminal: '" + result + "'" );
                start = result;
            }

            insertLink( nts, result );
            return result;
        }


        /* term - create a new terminal id with external symbol number esn */
        Terminal term( System.String id, int esn) {
            Symbol p = lookup(id);
            
	    // IO.Std.err.println( "term('" + id + "'," + esn + ")" );
            if( p != null ) {
		// IO.Std.err.println( "term('" + id + "'," + esn + "): existing: " + p );
		if( esn != -1 ) {
		    throw new System.Exception( "redefinition of terminal '" + id + "'" );
		} else if( p.kind != Kind.TERM ) {
		    throw new System.Exception( "misuse of '" + id + "' as terminal" );
		} else {
		    // IO.Std.err.println( "reuse existing terminal: '" + id + "'" );
		    return cast<Terminal>(p);
		}
            }

            Terminal result = new Terminal(id,esn,-1);
            install(result);
            
            insertLink( terms, result );

            return result;
        }



        /* tree - create & initialize a tree node with the given fields */
        Tree tree( System.String id, Tree left, Tree right) {
            // IO.Std.err.println( "in tree(" + id + "," + left + "," + right + ")" );
            Symbol p = lookup(id);

	    if( p == null ) {
		p = lookup( id + "_0" );

		if( p == null ) {
		    p = lookup( id + "_" + Main.word_size );
		}
	    }

            // IO.Std.err.println( "lookup gives: '" + p + "'" );
            Tree t = new Tree(p, left, right);
            int arity = 0;
            
            if( left != null && right != null ) {
                arity = 2;
            } else if( left != null ) {
                arity = 1;
            }
            
            if( p == null && arity > 0 ) {
                throw new System.Exception( "undefined terminal '" + id + "'" );
                p = term(id, -1);
            } else if (p == null && arity == 0) {
                p = nonterm(id);
            } else if (p != null && p.kind == Kind.NONTERM && arity > 0) {
                throw new System.Exception( "'" + id + "' is a nonterminal" );
                p = term(id, -1);
            }

            if (p.kind == Kind.TERM && cast<Terminal>(p).arity == -1) {
                cast<Terminal>(p).arity = arity;
            }
            if (p.kind == Kind.TERM && arity != cast<Terminal>(p).arity) {
                throw new System.Exception( "inconsistent arity for terminal '" + id + "'" );
            }

            t.op = p;
            if( p.kind == Kind.TERM ) {
                t.nterms = 1;
            } else {
                t.nterms = 0;
            }

            t.left = left;
            t.right = right;

            if( left != null ) {
                t.nterms = t.nterms + left.nterms;
            }
            
            if( right != null ) {
                t.nterms = t.nterms + right.nterms;
            }
            
            return t;
        }
        
    
        Rule rule( System.String id, Tree pattern, System.String mtree, System.String code, int used_temp ) {
            Rule r = new Rule();
            System.String end;
            
            r.lhs = nonterm(id);
            r.lhs.lhscount = r.lhs.lhscount + 1;
            r.packed = r.lhs.lhscount;
            
            insertDecode( r.lhs.rules, r );
            
            r.pattern = pattern;
            nrules = nrules + 1;
            r.ern = nrules;
            r.mtree = mtree;
            r.code = code;
	    r.used_temp = used_temp;
            
            try {
                r.cost = code.parseInt(); // strtol(code, &end, 10);
            } catch( System.Exception e ) {
                r.cost = -1;
                r.code = "(" + code + ")";
            }

            if (pattern.op.kind == Kind.TERM) {
                insertNext( cast<Terminal>(pattern.op).rules, r );
            } else if( pattern.left == null && pattern.right == null ) {
                NonTerminal p = cast<NonTerminal>(pattern.op);
                r.chain = p.chain;
                p.chain = r;
                if (r.cost == -1) {
                    throw new System.Exception( "illegal nonconstant cost '" + code + "'\n" );
                }
            }
            
            insertLink( rules, r );
            
            return r;
        }

        void print( char c ) {
            IO.Std.out.print( "" + c );
        }

        void print( System.String s ) {
            IO.Std.out.print( s );
        }

        void println( System.String s ) {
            IO.Std.out.println( s );
        }

        /* reach - mark all nonterminals in tree t as reachable */
        void reach(Tree t) {
            if( t.op.kind == Kind.NONTERM ) {
                NonTerminal p = cast<NonTerminal>(t.op);

                if( !p.reached ) {
                    ckreach( p );
                }
            }
            if( t.left != null ) {
                reach( t.left );
            }
            if( t.right != null ) {
                reach( t.right );
            }
        }

        /* ckreach - mark all nonterminals reachable from p */
        void ckreach(NonTerminal p) {
            Rule r;
            
            p.reached = true;
            // IO.Std.err.println( "reachable: '" + p + "'" );
            for(r = p.rules; r != null; r = r.decode) {
                reach(r.pattern);
            }
        }


	System.String expand( Tree t, System.String pattern ) {
	    System.StringBuffer result = new System.StringBuffer();
	    Util.Vector v = new Util.Vector();
	    t.findArgs( "a", v );
	    // IO.Std.err.println( "emit-expand: args is: " + v );
	    for( int i = 0; i < pattern.getLength(); i = i + 1 ) {
		if( pattern.charAt(i) != '$' ) {
		    result.append( pattern.charAt(i) );
		} else {
		    i = i + 1;
		    int n = cast<int>(pattern.charAt(i) - '0');
		    result.append( cast<System.String>(v.get(n)) );
		}
	    }
	    return result;
	}

	static int last_case = 0;

        /* emitcase - emit one case in function state */
        void emitcase(Terminal p, int ntnumber) {
            Rule r;

	    if( p.esn > last_case ) {
		last_case = p.esn;
	    }

            println( "\t\t" + "case " + p.esn + ": /* " + p + " */" );
	    // println( "\t\tIO.Std.err.println( " + quote + "matched: " + p.esn + ": " + p + quote + ");" );
            switch (p.arity) {
            case 0, -1:
                ;

            case 1:
                println( "\t\t" + "label(a.getLeft());");
            case 2:
                println( "\t\t" + "label(a.getLeft());");
                println( "\t\t" + "label(a.getRight());");
            default:
                throw new System.Exception( "unexpected arity: " + p.arity + " in " + p );
            }


            for(r = p.rules; r != null; r = r.next) {
                System.String indent = "\t\t";

                switch (p.arity) {
                case 0, -1:
		    println( "\t\t//" + r + "->" + p + " ?" );

                    println( "\t\t/* " + r + " arity " + p.arity + " */" );
                    if (r.cost == -1) {
                        print("\t\tc = " + r.code + ";" );
                        emitrecord("\t\t", r, "c", 0);
                    } else {
                        emitrecord("\t\t", r, r.code, 0);
                    }
                    
                case 1:
                    if (r.pattern.nterms > 1) {
                        println( "\t\tif(/* " + r + " arity 1 */");
                        emittest( r.pattern.left, "a.getLeft()", " ");
                        println( "\t\t) {");
                        indent = "\t\t\t";
                    } else {
                        print( "\t\t/* " + r + " */" );
                    }
                    if (r.pattern.nterms == 2 && r.pattern.left != null && r.pattern.right == null) {
                        emitrecalc(indent, r.pattern.op, r.pattern.left.op);
                    }
                    print( indent + "c = " );
                    emitcost( r.pattern.left, "a.getLeft()");
                    println( r.code + ";" );
                    emitrecord(indent, r, "c", 0);
                    if( indent.getLength() > 2 ) {
                        println("\t\t}");
                    }
                    
                case 2:
                    if (r.pattern.nterms > 1) {
                        println("\t\tif(/* " + r + " arity 2 */");
                        System.String t;
                        if( r.pattern.right.nterms != 0 ) {
                            t = " && /* CC */ ";
                        } else {
                            t = " ";
                        }
                        emittest(r.pattern.left, "a.getLeft()", t );
                        emittest(r.pattern.right, "a.getRight()", " ");
                        println("\t\t) {");
                        indent = "\t\t\t";
                    } else {
                        println("\t\t/* " + r + " */" );
                    }
                    print( indent + "c = " );
                    emitcost(r.pattern.left, "a.getLeft()");
                    emitcost(r.pattern.right, "a.getRight()");
                    println( r.code + ";" );
                    emitrecord(indent, r, "c", 0);
                    if(indent.getLength() > 2) {
                        print("}\n");
                    }
                    
                default:
                    throw new System.Exception( "unexpected arity: " + p.arity + " in " + p );
                }
            }
            print("\t\tbreak;\n");
        }
   

        /* emitclosure - emit the closure functions */
        void emitclosure(NonTerminal nts) {
            NonTerminal p;  
            for( p = nts; p != null; p = p.link) {
                if( p.chain != null ) {
                    Rule r;
                    println("void closure_" + p + "(" + tree_name + " a, int c) {\n\tState p = a.get" + name_space + "State();" );
                    for( r = p.chain; r != null; r = r.chain) {
                        emitrecord("\t", r, "c", r.cost);
                    }
                    println("}\n");
                }
            }
        }

        /* emitcost - emit cost computation for tree t */
        void emitcost(Tree t, System.String v) {
            Symbol p = t.op;
            
            if( p.kind == Kind.TERM ) {
                if( t.left != null ) {
                    emitcost( t.left, v + ".getLeft()" );
                }
                if( t.right != null ) {
                    emitcost( t.right, v + ".getRight()" );
                }
            } else {
                println( v + ".get" + name_space + "State().cost[" + p + "_NT] + " );
            }
        }

        /* emitdecls - emit nonterminal decls */
        void emitdecls(NonTerminal nts, int ntnumber) {
            NonTerminal p;
            
            for( p = nts; p != null; p = p.link) {
                println("public const int " + p + "_NT = " + p.number + ";" );
            }
            print("\n");
            println( "System.String[] ntname;" );
        }

        /* emitdefs - emit nonterminal defines and data structures */
        void emitdefs(NonTerminal nts, int ntnumber) {
            NonTerminal p;
            
            println("ntname = System.String {\n\tnull,");
            for (p = nts; p != null; p = p.link) {
                print("\t" + quote + p + quote );
                if( p.link != null ) {
                    println( "," );
                } else {
                    print( "\n" );
                }
            }
            
            println("\t\n};\n");
        }



        /* computekids - compute paths to kids in tree t */
        System.String computekids(Tree t, System.String v, int ref ip) {
            Symbol p = t.op;
            System.String result;

            if( p.kind == Kind.NONTERM ) {
                result = "\t\tresult[" + ip + "] = " + v + ";\n";
                ip = ip + 1;
                return result;
            } else {
                Terminal q = cast<Terminal>(p);
                if( q.arity > 0 ) {
                    result = computekids( t.left, v + ".getLeft()", ip );
                    if( q.arity == 2 ) {
                        result = result + computekids( t.right, v + ".getRight()", ip );
                    }
                    return result;
                } else {
                    return "";
                }
            }
        }

        /* emitkids - emit _kids */
        void emitkids(Rule rules, int nrules) {
            int i = 0;
            Rule r;
            Rule[] rc = new Rule[nrules + 2]; // alloc((nrules + 1 + 1)*sizeof *rc);
            System.String[] str = new System.StringBuffer[nrules + 2]; // char **str  = alloc((nrules + 1 + 1)*sizeof *str);
            
            for (r = rules; r != null; r = r.link) {
                int j = 0;
                System.String bp = computekids(r.pattern, "p", j);

                bp = "\t\tresult = new " + tree_name + "[" + j + "];\n" + bp;
                
                for (j = 0; str[j] != null && !str[j].equals(bp); j = j + 1) {
                    // do nothing;
                }
                
                if (str[j] == null) {
                    str[j] = bp;
                }

                r.kids = rc[j];
                rc[j] = r;
            }

            println( tree_name + "[] kids( " + tree_name + " p, int eruleno ) {" );
            println( "\t" + tree_name + "[] result;" );
            println( "\tif( p == null ) throw new System.Exception(" + quote + "kids: null tree" + quote + ");" );
            println( "\tswitch( eruleno ) {");
            for (i = 0; rc[i] != null; i = i + 1) {
                r = rc[i];
                if( r != null ) {
                    println( "\tcase" );
                    for ( ; r != null; r = r.kids) {
                        print( "\t" + r.ern + "/* " + r + " */" );
                        if( r.kids != null ) {
                            println( "," );
                        } else {
                            println( ":" );
                        }
                    }
                    println( str[i] );
		}
            }
            print("\tdefault:\n\t\tthrow new System.Exception(" + quote + "kids: bad rule number " + quote + " + eruleno );\n\t}\n\treturn result;\n}\n");

        }

	void emitrewrites(Terminal terms) {
	    Terminal p;
	    int n = 0;
	    for( p = terms; p != null; p = p.link ) {
		if( p.esn > n ) {
		    n = p.esn;
		}
	    }

	    int[] rewrite_goal = new int[n+1];

	    for( p = terms; p != null; p = p.link ) {
		if( p.rules != null ) {
		    int lhs = 0;
		    System.String s = "unknown";
		    for( Rule r = p.rules; r != null; r = r.next ) {
			IO.Std.err.println( "rewrite goals for " + p + " include " + r );
			if( lhs == 0 ) {
			    lhs = r.lhs.number;
			    s = "rule: " + r + ", lhs: " + r.lhs;
			} else if( lhs != r.lhs.number ) {
			    lhs = 0;
			    s = "multiple";
			    break;
			}
		    }

		    rewrite_goal[p.esn] = lhs;
		}
	    }
	    println( "static int[] rewrite_goal = {" );
	    for( int i = 0; i < n; i = i + 1 ) {
		println( "" + rewrite_goal[i] + "," );
	    }
	    println( "};" );
	    println( "public static int getReWriteGoal(int terminal) { return rewrite_goal[terminal]; }" );
	}

	void emitlabel(Terminal terms, NonTerminal start, int n, int from, int to ) {
            int i;
            Terminal p;
            
            println( "void label" + n + "(" + tree_name + " a, State p) {\n\tint c;" );
	    // println( "\tIO.Std.err.println(" + quote + "label" + n + "(" + from + ".." + (to-1) + ") :" + quote + " + a + " + quote + "," + quote + " + p );" );
            println( "\tif( a == null ) throw new System.Exception(" + quote + "label: null tree" + quote + ");" );
            // println( "\tITree t;" );
            // println( "\tp.rule_stmt = null;" );
            
            println( "\tswitch( a.getOperator() ) {" );
            
	    last_case = 0;

            for( p = terms; p != null; p = p.link) {
		if( p.esn >= from && p.esn < to ) {
		    emitcase(p, ntnumber);
		}
            }
            
            println("\tdefault:" );
            println("\t\tif( a.getOperator() > " + last_case + ") {\n\t\t\tthrow new System.Exception( " + quote + "label: bad terminal " + quote + " + a.getOperator() );\n\t\t}\t}\n}" );
	}

	const int SPLIT = 50;

        /* emitlabel - emit label function */
        void emitlabel(Terminal terms, NonTerminal start, int ntnumber) {
            int i, n, count;
            Terminal p;

            for( p = terms; p != null; p = p.link) {
		if( p.esn >= count ) { 
		    count = p.esn;
		}
	    }

	    n = 0;
	    for( i = 0; i < count; i = i + SPLIT ) {
		emitlabel( terms, start, n, i, i + SPLIT );
		n = n + 1;
	    }
            
            println( "void label(" + tree_name + " a) {\n\tint c;" );

            println( "\tState ts;\n" );
            println( "\tif( a == null ) throw new System.Exception(" + quote + "label: null tree" + quote + ");" );
	    println( "\tState p = new State();" );
            println( "\ta.setState(p);" );
            // println( "\tITree t;" );
            // println( "\tp.rule_stmt = null;" );
            
            for( i = 1; i <= ntnumber; i = i + 1 ) {
                println("\tp.cost[" + i + "] = 0x7FFF;" );
            }

	    println( "\tint o = a.getOperator();" );
	    // println( "\tIO.Std.err.println(" + quote + "label:" + quote + " + o );" );

	    n = 0;
	    print( "\t" );
	    for( i = SPLIT; i < count; i = i + SPLIT ) {
		println( "if( o < " + i + ") { label" + n + "(a,p); }" );
		n = n + 1;
		print( "\telse " );
	    }
	    println( "label" + n + "(a,p); }" );
        }
        
        /* computents - fill in bp with _nts vector for tree t */
        System.String computents(Tree t) {
            if(t != null ) {
                Symbol p = t.op;
                if (p.kind == Kind.NONTERM) {
                    return p.name + "_NT, ";
                } else {
                    // might need reversing due to odd string logic in original
                    return computents(t.left) + computents(t.right);
                }
            } else {
                return "";
            }
        }

        /* emitnts - emit _nts ragged array */
        void emitntsdecls(Rule rules, int nrules) {
            Rule r;
            int i, j;
            int[] nts = new int[nrules + 1];
            System.String[] str = new System.String[nrules + 1];
            
            i = 0;
            for( r = rules; r != null; r = r.link) {
                System.String buf = computents(r.pattern);
                
                for (j = 0; str[j] != null && !str[j].equals(buf); j = j + 1) {
                    // do nothing
                }
                if( str[j] == null ) {
                    println("\tint[] nts_" + j + ";" );
                    str[j] = buf;
                }
                nts[i] = j;
                i = i + 1;
            }
            
            println("\nint[][] nts;" );

            println("\nint[] getNTS(int n) {" );
            println("\treturn nts[n];" );
            println("}\n");
        }

        /* emitnts - emit _nts ragged array */
        void emitntsdefs(Rule rules, int nrules) {
            Rule r;
            int i, j;
            int[] nts = new int[nrules + 1];
            System.String[] str = new System.String[nrules + 1];
            
            i = 0;
            for( r = rules; r != null; r = r.link) {
                System.String buf = computents(r.pattern);
                
                for (j = 0; str[j] != null && !str[j].equals(buf); j = j + 1) {
                    // do nothing
                }
                if( str[j] == null ) {
                    if( buf.getLength() <= 0 ) {
                        println( "\tnts_" + j + " = new int[0];" );
                    } else {
                        println("\tnts_" + j + " = int { " + buf + " };" );
                    }
                    str[j] = buf;
                }
                nts[i] = j;
                i = i + 1;
            }
            
            print("\tnts = int[] {\n");
            i = 0;
            j = 0;
            for( r = rules; r != null; r = r.link ) {
                for ( ; j < r.ern; j = j + 1) {
                    println("\t\tnull,\t/* " + j + " */\n" );
                }
                println("\t\tnts_" + nts[i] + ",\t/* " + j + " */" );
                i = i + 1;
                j = j + 1;
            }
            println("\t};\n");
        }

        /* emitrecalc - emit code that tests for recalculation of INDIR?(VREGP) */
        void emitrecalc(System.String pre, Symbol root, Symbol kid) {
            // do nothing, lcc specific hack
        }
        
        /* emitrecord - emit code that tests for a winning match of rule r */
        void emitrecord(System.String pre, Rule r, System.String c, int cost) {
	    println( pre + "// match " + r + "->" + r.lhs + " ?" );
            // if(trace) {
            // println( pre + "trace(a, " + r.ern + ", " + c + " + " + cost + ", p.cost[" + r.lhs + "_NT]);\n" );
                // }
            print( pre + "if(" );
            println( c + " + " + cost + " < p.cost[" + r.lhs + "_NT]) {" );
            println( pre + "\tp.cost[" + r.lhs + "_NT] = " + c + " + " + cost + ";" );
            println( pre + "\tp.rule[" + r.lhs + "_NT] = " + r.packed + ";" ); 
            if( r.lhs.chain != null ) {
                println( pre + "\tclosure_" + r.lhs + "(a, " + c + " + " + cost + ");" );
            }
            println( pre + "}" );
        }
        
        /* emitrule - emit decoding vectors and _rule */
        void emitruledecls(NonTerminal nts) {
            NonTerminal p;
            
            for( p = nts; p != null; p = p.link ) {
                Rule r;
                println( "int[] decode_" + p + ";" );
            }
            
            println("int rule( State state, int goalnt) {");
            println( "\tif( goalnt < 1 || goalnt > " + ntnumber + ") throw new System.Exception(" + quote + "rule: bad goal nonterminal: " + quote + " + goalnt );" );
            println( "\tif( state == null ) return 0;" );
	    println( "\tint nts = state.rule[goalnt];" );
            println( "\tswitch( goalnt ) {" );            
            for( p = nts; p != null; p = p.link ) {
                println( "\tcase " + p + "_NT:\treturn decode_" + p + "[state.rule[" + p + "_NT]];" );
            }
            println( "\tdefault:\n\t\tthrow new System.Exception(" + quote + "rule: bad goal nonterminal " + quote + " + goalnt );" );
                            println("\n\t\treturn 0;\n\t}\n}\n");
        }

        /* emitrule - emit decoding vectors and _rule */
        void emitruledefs(NonTerminal nts) {
            NonTerminal p;
            
            for( p = nts; p != null; p = p.link ) {
                Rule r;
                println( "\tdecode_" + p + " = {" );
                println( "\t\t0," );
                
                for (r = p.rules; r != null; r = r.decode) {
                    println( "\t\t" + r.ern + "," );
                }
                println("\t};\n");
            }
        }

        /* emitstring - emit arrays of templates, instruction flags, and rules */
        void emitstringdecls(Rule rules) {
            Rule r;
            
            println( "System.String[] nts_name;\n" );

            println("\nSystem.String getNameNTS(int n) {" );
            println("\treturn nts_name[n];\n" );
            println("}\n" );
        }

        void emitmtreedecls() {
            Rule r;
            NonTerminal n;

            println( result_name + "Factory[] result;" );

            println( result_name + " getResult( int ern, " + tree_name + " node, " + result_name + "[] children ) {" );
            println( "\treturn result[ern].create(node, children);" );
            println( "}" );
        }

        void emitmtreeclosure(Rule rules) {
            Rule r;
            NonTerminal n;

            println( "class " + result_name + "Factory {" );
            println( "\t" + result_name + " create(" + tree_name + " node, " + result_name + "[] children) {" );
            println( "\t\treturn null;" );
            println( "\t}" );
            println( "\tvoid init() {}" );
            println( "}" );

            for (r = rules; r != null; r = r.link) {
                println( "class " + result_name + "Factory" + r.ern + " extends " + result_name + "Factory {" );
                println( "\tvoid init() { super.init(); }" );
                println( "\t" + result_name +" create(" + tree_name + " node, " + result_name + "[] children) {" );
		if( r.used_temp & 4 != 0 ) {
		    println( "\tint temp_l = " + tree_name + ".nextLabelNumber();" );
		}
		if( r.used_temp & 8 != 0 ) {
		    println( "\tint temp_m = " + tree_name + ".nextLabelNumber();" );
		}
		if( r.used_temp & 1 != 0 ) {
		    println( "\tint temp_t = " + tree_name + ".nextTemp();" );
		}
		if( r.used_temp & 2 != 0 ) {
		    println( "\tint temp_u = " + tree_name + ".nextTemp();" );
		}

		bool seen_return = false;
		for( int j = 0; j < r.mtree.getLength(); j = j + 1 ) {
		    if( r.mtree.charAt(j) == ';' ) {
			seen_return = true;
		    }
		}

		if( !seen_return ) {
		    print( "\t\treturn " );
		}

                for( int i = 0; i < r.mtree.getLength(); i = i + 1 ) {
                    if( r.mtree.charAt(i) == '$' ) {
                        i = i + 1;
			if( r.mtree.charAt(i) == '$' ) {
			    print( "$" );
			} else if( r.mtree.charAt(i) >= '0' && r.mtree.charAt(i) <= '9' ) {
                            print( "(children[" + r.mtree.charAt(i) + "])" );
                        } else {
                            print( "cast<" );
                            while( r.mtree.charAt(i) != ' ' ) {
                                print( r.mtree.charAt(i) );
                                i = i + 1;
                            }
                            i = i + 1;
                            if( r.mtree.charAt(i) >= '0' && r.mtree.charAt(i) <= '9' ) {
                                print( ">(children[" + r.mtree.charAt(i) + "])" );
                            } else {
                                throw new System.Exception( "expected child number in rule " + r );
                            }
                        }
                    } else if( r.mtree.charAt(i) == '%' ) {
                        i = i + 1;
                        switch( r.mtree.charAt(i) ) {
			case '%': print("%");
			case 't','T': print( "temp_t" );
			case 'u','U': print( "temp_u" );
			case 'l','L': print( "" + quote + ".L" + quote + "+temp_l" );
			case 'm','M': print( "" + quote + ".L" + quote + "+temp_m" );
			case 's','S': print( "(node.getString())" );
                        case 'v','V': print( "(node.getValue())" );
                        case 'i','I': print( "(node.getInt())" );
                        case 'c','C': print( "(new " + result_name + "(node))" );
                        default: throw new System.Exception( "unexpected % value in rule " + r );
                        }
                    } else {
                        print( r.mtree.charAt(i) );
                    }
                }
                println( ";\n" );
                println( "\t}" );
                println( "}" );
            }
        }

        void emitmtreedefs(Rule rules) {
            Rule r;
            NonTerminal n;

            println( "\tresult = " + result_name + "Factory {" );
            println("\t\tnull,");

            for (r = rules; r != null; r = r.link) {
                println( "\n\tnew " + result_name + "Factory" + r.ern + "()," );
            }
           
            println( "\t};" );
        }

        /* emitstring - emit arrays of templates, instruction flags, and rules */
        void emitstringdefs(Rule rules) {
            Rule r;
            NonTerminal n;
            
            println("\tnts_name = System.String {");
            println("\t\tnull,\t/* 0 */");
            for( n = nts; n != null; n = n.link ) {
                println( "\t\t" + quote + n.name + quote + ",\t/* " + n + "*/" );
            }
            println("\t};");

        }


        /* emitstruct - emit the definition of the state structure */
        void emitstruct(NonTerminal nts, int ntnumber) {
            println( "class State extends System.Object {" );
            println( "\tpublic int[] cost;" );
	    println( "\tpublic int[] rule;" );

            println( "\tvoid init() { super.init(); cost = new int[" + (ntnumber + 1) + "]; rule = new int[" + (ntnumber + 1) + "]; }" );
	    println( "\tSystem.String toString() {" );
	    println( "\t\tSystem.StringBuffer b = new System.StringBuffer();" );
	    for( NonTerminal t = nts; t != null; t = t.link ) {
		println( "\t\tif( cost[Selector." + t.name + "_NT] < 32767 ) { b.append(" + quote + t.name + quote + "); b.append('/'); b.append(cost[Selector." + t.name + "_NT]); b.append('/'); b.append(rule[Selector." + t.name + "_NT]); b.append(' '); }" );
	    }
	    println( "\treturn b;" );
	    println( "\t}" );
            println( "}" );
        }
        
        /* emittest - emit clause for testing a match */
        void emittest(Tree t, System.String v, System.String suffix) {
            Symbol p = t.op;
            
            if( p.kind == Kind.TERM ) {
                
                print( "\t\t\t" + v + ".getOperator() == " + cast<Terminal>(p).esn );
                if( t.nterms > 1 ) {
		    if( t.left == null && t.right == null ) {
		        IO.Std.err.println( "oops: probably going to fail for: " + p );
		    }
                    println( " && /* AA " + p + "*/" );
                } else {
                    println( suffix + "/* BB " + p + "*/" );
                }
                
                if( t.left != null ) {
                    System.String s = suffix;
		    s = s + "/*XX*/";
                    if( t.right != null && t.right.nterms != 0 ) {
                        s = " && ";
                    }
                    emittest(t.left, v + ".getLeft()", s );
                }
                if( t.right != null ) {
		    s = s + "/*YY*/";
                    emittest(t.right, v + ".getRight()", suffix );
                }
            }
        }

        void emitfilestart() {
            println( "namespace " + name_space + " {" );
            println( preamble_string );
        }

        void emitfileend() {
            println( "}" );
        }

        void emitclassstart() {
            println( "class Selector {" );
        }

        void emitclassend() {
            println( "}" );
        }

        void emitdefstart() {
            println( "void init() {" );
        }

        void emitdefend() {
            println( "}" );
        }

        void init(Mode m) {
	    this.mode = m;
            symbols = new Util.Map(101);
            quote = '\"';
	    try {
		parse( IO.Std.in );
	    } catch( System.Exception e ) {
		IO.Std.err.println( "around line " + tokenizer.getLineNumber() + " caught: " + e );
		throw e;
	    }

            if( start != null ) {
                ckreach( start );
            }

            for(NonTerminal p = nts; p != null ; p = p.link) {
                if( p.rules == null ) {
                    throw new System.Exception( "undefined nonterminal '" + p.name + "' from " + p );
                }
                if( !p.reached ) {
                    throw new System.Exception( "can't reach nonterminal '" +  p.name + "'" );
                }
            }

            emitfilestart();
            emitstruct(nts, ntnumber);
            // emitheader();
            emitclassstart();
            emitdecls(nts, ntnumber);

            emitntsdecls(rules, nrules);
            emitruledecls(nts);
            emitstringdecls(rules);
            emitmtreedecls();
	    emitrewrites(terms);

            emitdefstart();
            emitntsdefs(rules, nrules);
            emitruledefs(nts);
            emitstringdefs(rules);
            emitmtreedefs(rules);
            emitdefend();

            emitclosure(nts);
            if( start != null ) {
                emitlabel(terms, start, ntnumber);
            }

            emitkids(rules, nrules);
            emitclassend();
            emitmtreeclosure(rules);
            emitfileend();

            // if (!feof(infp))
            //  while ((c = getc(infp)) != EOF)
            // putc(c, outfp);
        }
    }
}
