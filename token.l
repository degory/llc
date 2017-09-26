#C

// copyright 2004-2010 degs <junk@giantblob.com> all rights reserved

import stream;
import vector;
import map;

namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;

    class TokenBuffer extends Object {
        const int MAX = 32;  // maximum lookahead before we assume we're not in a generic type

        int read_pos;
        int write_pos;

        TokenPair[] values, temp;

        void init() {
            values = new TokenPair[MAX*2];   // additional space to accomodate turning single '>>'
            temp = new TokenPair[MAX*2];     // tokens into two token sequence close-generic close-generic
            read_pos = 0;
            write_pos = 0;
        }

        void reset() {
            // IO.Std.err.println( "clear buffer..." );
            read_pos = 0;
            write_pos = 0;
        }

        get bool Avail {
            return read_pos < write_pos;
        }

        get bool IsFull {
            return write_pos >= MAX;
        } 

        void write( TokenPair t ) {
            // IO.Std.err.println( "buffer token: " + cast<int>(t.token) + ", string: " + t.string );
            values[write_pos] = t;
            write_pos = write_pos + 1;
        }

        TokenPair read() {
            TokenPair result = values[read_pos];
            read_pos = read_pos + 1;
            // IO.Std.err.println( "read buffered token: " + cast<int>(result.token) + ", string: " + result.string );
            return result;
        }

        void makeGeneric() {
            assert( read_pos == 0 );

            // convert '<', '>' and '>>' in the buffer to appropriate open + close generic tokens:
            int vp = 0, tp = 0;

            while( vp < write_pos ) {
                Token r = values[vp].token;
                if( r == Token.LT ) {
                    r = Token.OPEN_GENERIC;
                } else if( r == Token.GT ) {
                    r = Token.CLOSE_GENERIC;
                } else if( r == Token.SHIFT_RIGHT ) {
                    // treat a previously lexed SHIFT_RIGHT ('>>') token as two CLOSE_GENERIC tokens:
                    temp[tp] = new TokenPair( Token.CLOSE_GENERIC, null );
                    tp = tp + 1;
                    r = Token.CLOSE_GENERIC;
                }
                // copy the previously lexed token+string over:
                temp[tp] = values[vp];
                // but override the token to substitute generic brackets where needed:
                temp[tp].token = r;

                vp = vp + 1;
                tp = tp + 1;
            }	    

            TokenPair[] t = values;
            values = temp;
            temp = t;
            write_pos = tp;
        }

    }


    class TokenizerException extends Exception {
        void init( String s ) {
            super.init(s);
        }
    }

    class TokenHolder extends Object {
        public Token token;

        void init( Token token ) {
            super.init();
            this.token = token;
        }
    }

    class TokenMap extends Object {
        Generic.Map<String,TokenHolder> map;

        void init() {
            super.init();
            map = new Generic.Map<String,TokenHolder>(223);
        }

        set Token[String s] = t {
            map[s] = new TokenHolder(t);
        }

        get Token[String s] {
            TokenHolder th = map[s];
            if( th != null ) {
                return th.token;
            } else {
                return Parse.Token.IDENTIFIER;
            }
        }
    }

    class TokenPair extends Object {
        public String string;
        public Token token;

        void init( Token token, String string ) {
            super.init();
            this.token = token;
            this.string = string;
        }

        String getString() {
            return string;
        }

        Token getToken() {
            return token;
        }
    }

    class Tokenizer extends yyInput {
        Token token;
        static TokenMap symbol_tokens_l;
        static TokenMap symbol_tokens_k;
        TokenMap symbol_tokens;
        TokenBuffer buffer;
        String token_string;
        IO.Reader input;
        bool end_of_file;
        char prev_char;

        String current_file;
        int current_line;

        String[] token_name;

        bool want_new_syntax;

        static TokenMap initSymbolTokensCommon() {
            // IO.Std.err.println( "init tokens for common" );
            var symbol_tokens = new TokenMap();
            symbol_tokens["import"] = Token.IMPORT;
            symbol_tokens["namespace"] = Token.NAMESPACE;
            symbol_tokens["class"] = Token.CLASS;
            symbol_tokens["struct"] = Token.STRUCT;
            symbol_tokens["enum"] = Token.ENUM;
            symbol_tokens["public"] = Token.PUBLIC;
            symbol_tokens["protected"] = Token.PROTECTED;
            symbol_tokens["private"] = Token.PRIVATE;
            symbol_tokens["const"] = Token.CONST;
            symbol_tokens["static"] = Token.STATIC;
            symbol_tokens["if"] = Token.IF;
            symbol_tokens["else"] = Token.ELSE;
            symbol_tokens["while"] = Token.WHILE;
            symbol_tokens["do"] = Token.DO;
            symbol_tokens["for"] = Token.FOR;
            symbol_tokens["foreach"] = Token.FOREACH;
            symbol_tokens["case"] = Token.CASE;
            symbol_tokens["default"] = Token.DEFAULT;
            symbol_tokens["break"] = Token.BREAK;
            symbol_tokens["continue"] = Token.CONTINUE;
            symbol_tokens["ref"] = Token.REFERENCE;
            symbol_tokens["ptr"] = Token.POINTER;
            symbol_tokens["int"] = Token.INT;
            symbol_tokens["long"] = Token.LONG;
            symbol_tokens["word"] = Token.WORD;
            symbol_tokens["char"] = Token.CHAR;
            symbol_tokens["bool"] = Token.BOOL;
            symbol_tokens["void"] = Token.VOID;
            symbol_tokens["new"] = Token.NEW;
            symbol_tokens["throw"] = Token.THROW;
            symbol_tokens["return"] = Token.RETURN;
            symbol_tokens["cast"] = Token.CAST;
            symbol_tokens["var"] = Token.VARIABLE;
            symbol_tokens["try"] = Token.TRY;
            symbol_tokens["catch"] = Token.CATCH;
            symbol_tokens["finally"] = Token.FINALLY;
            symbol_tokens["this"] = Token.THIS;
            symbol_tokens["super"] = Token.SUPER;
            symbol_tokens["null"] = Token.CONST_NULL;
            symbol_tokens["true"] = Token.CONST_TRUE;
            symbol_tokens["false"] = Token.CONST_FALSE;
            symbol_tokens["use"] = Token.USE;
            symbol_tokens["native"] = Token.NATIVE;
            symbol_tokens["pragma"] = Token.PRAGMA;
            symbol_tokens["get"] = Token.GET;
            symbol_tokens["set"] = Token.SET;
            symbol_tokens["interface"] = Token.INTERFACE;
            symbol_tokens["proc"] = Token.PROC;
            symbol_tokens["isa"] = Token.ISA;
            symbol_tokens["operator"] = Token.OPERATOR;

            return symbol_tokens;
        }

        void initSymbolTokens() {
            if( want_new_syntax ) {		
                    if( symbol_tokens_k == null ) { 
                    symbol_tokens_k = initSymbolTokensCommon();

                    // IO.Std.err.println( "init tokens for K syntax" );
                    symbol_tokens_k["is"] = Token.IS;
                    // symbol_tokens_k["end"] = Token.END;
                    symbol_tokens_k["si"] = Token.END;
                    symbol_tokens_k["then"] = Token.THEN;
                    symbol_tokens_k["elif"] = Token.ELIF;
                    symbol_tokens_k["fi"] = Token.FI;
                    symbol_tokens_k["esac"] = Token.ESAC;
                    
                    symbol_tokens_k["od"] = Token.OD;
                    symbol_tokens_k["yrt"] = Token.YRT;
                }
                this.symbol_tokens = symbol_tokens_k;		
            } else {
                if( symbol_tokens_l == null ) {
                    symbol_tokens_l = initSymbolTokensCommon();

                    // IO.Std.err.println( "init tokens for L syntax" );
                    symbol_tokens_l["extends"] = Token.EXTENDS;
                    symbol_tokens_l["implements"] = Token.IMPLEMENTS;		    
                    symbol_tokens_l["switch"] = Token.SWITCH;		    
                }
                    this.symbol_tokens = symbol_tokens_l;
            }

            // IO.Std.err.println( "tokens initialized" );

        }

        void init( String current_file, IO.Reader i ) {
            super.init();
            want_new_syntax = true;
            int t = i.read();
            if( t == cast int('#') ) {
                // IO.Std.err.println( "reading syntax marker..." );
                int u = i.read();
                if( u == cast int('C') || u == cast int('L') ) {
                    want_new_syntax = false;
                } else if( u == cast int('K') ) {
                    // IO.Std.err.println( "new syntax selected" );
                    want_new_syntax = true;
                } else {
                    throw new Exception( "unexpected syntax type marker '#" + cast char(u) + "'" );
                }
            } else if( t != -1 ) {
                i.unRead( t );
            }
                
            buffer = new TokenBuffer();

            // stack.add( MAYBE_IN_TYPE );

            end_of_file = false;
            input = i;
            this.current_file = current_file;
            current_line = 1;

            initSymbolTokens();
        }

        void error( String msg ) {
            IO.Std.err.print( ReportingFile + ": " + current_line + ",0.." + (current_line + 1) + ",0: error: " + msg);
        }

        get bool WantNewSyntax {
            return want_new_syntax;
        }

        bool isEndOfFile() {
            return end_of_file;
        }

        void markInArgumentsDeclaration() {
            // generic_state = IN_ARGUMENTS;
        }

        char nextChar() {
            char c;
            if( prev_char != cast<char>(0) ) {
                c = prev_char;
                prev_char = cast<char>(0);
                // IO.Std.err.print(""+c);
                // IO.Std.out.println( "next char: returning buffered: '" + c + "'" );
                return c;     
            }

            int c0 = input.read();

            if( c0 == -1 ) {
                // IO.Std.out.println( "next char: returning eof from: " + new System.Backtrace() );
                end_of_file = true;
                return ' ';
            }
            c = cast<char>(c0);
            if( c == '\n' ) {
                current_line = current_line + 1;
            }
            // IO.Std.err.print(""+c);
            // IO.Std.out.println( "next char: returning '" + c + "'" );
            return c;
        }

        void prevChar( char c ) {
            prev_char = c;
        }

        String getBuffer() {
            return token_string;
        }

        Object getValue() {
            return getBuffer();
        }

        String getName(Token t) {
            return token_name[cast<int>(t)];
        }

        int getLine() {
            return current_line;
        }

        String getFile() {
            return current_file;
        }

        String getReportingFile() {
            if (current_file.endsWith(".lo")) {
                var result = current_file.substring(0, current_file.Length - 3);

                var index = result.lastIndexOf('.');

                result = result.substring(0, index + 1) + "ghul";

                return result;
            } else {
                return current_file;                
            }
        }

        char readEscape() {
            char c = nextChar();

            // IO.Std.out.println( "readEscape: '" + c + "'..." );
            int result = 0;
            if( c == 't' ) {
                // IO.Std.out.println( "escape tab" );
                return cast char(9);
            } else if( c == 'n' ) {
                // IO.Std.out.println( "escape newline" );
                return '\n';
            } else if( c == 'r' ) {
                return cast char(13);
            } else if( c == '\\' ) {
                // IO.Std.out.println( "escape backslash" );
                return '\\';
            } else if( c >= '0' && c <= '7' ) {
                // IO.Std.out.println( "escape octal" );
                while( c >= '0' && c <= '7' ) {
                    result = 8 * result + cast<int>(c);
                    c = nextChar();
                }
                prevChar(c);
                return cast<char>(result);
            } else {
                // IO.Std.out.println( "escape literal: '" + c + "'" );
                return c;
            }
        }

        int getCurrentToken() {
            // IO.Std.err.println( "got: " + YyNameClass.yyName[cast<int>(token)] );
            return cast<int>(token);
        }

        bool nextToken() {
            token = readToken();
            // IO.Std.err.println( "read: " + YyNameClass.yyName[cast<int>(token)] + ", '" + token_string + "'" );
            return token != Token.EOF;
        }

        char skipWhiteSpace() {
            char c;
            do {
                c = nextChar();
                // IO.Std.out.println( "white space: '" + c + "'?" );
            } while( !end_of_file && (c == ' ' || c == cast<char>(9) || c == '\n') );
        
            return c;
        }

        Token readOperatorMethodToken() {
            Token r = readToken2(false);
            switch( r ) {
            case Token.ADD:
                token_string = "opAdd";

            case Token.SUB:
                token_string = "opSub";

            case Token.MUL:
                token_string = "opMul";

            case Token.DIV:
                token_string = "opDiv";

            case Token.MOD:
                token_string = "opMod";

            case Token.SHIFT_LEFT:
                token_string = "opShl";

            case Token.SHIFT_RIGHT:
                token_string = "opShar";

            case Token.AND:
                token_string = "opAnd";

            case Token.OR:
                token_string = "opOr";

            case Token.XOR:
                token_string = "opXor";

            case Token.OBJ_EQ:
                token_string = "opEquals";

            case Token.GT:
                token_string = "opCompare";

            case Token.RANGE:
                token_string = "opRange";

            case Token.RANGE_INCLUSIVE:
                token_string = "opRangeInclusive";

            default:
                // syntax error:
                return r;
            }

            return Token.IDENTIFIER;
        }

        Token readToken() {
            Token r;

            if( buffer.Avail ) {
                // IO.Std.err.println( "token in buffer..." );
                TokenPair p = buffer.read();		
                token_string = p.string;

                // IO.Std.err.println( "returning buffered: " + cast<int>(p.token) );
                return p.token;
            }

            r = readToken2(false);

            if( r != Token.LT /* && r != Token.WHILE */ ) {
                return r;
            }

            // nothing in buffer and current token is '<' - may be looking at a generic type, need to look ahead until we can determine if we're
            // in a generic type or not. 

            buffer.reset();

            buffer.write( new TokenPair( r, token_string ) );
            var bracket_stack = new Token[16];
            bracket_stack[0] = r;
            int generic_level = 0;
            // int do_level = 1;
            bool is_generic = true;

            do {
                if( buffer.IsFull ) {
                    IO.Std.err.println( "" + current_file + ": " + current_line + ": warn: ambiguous input: assuming not a generic type" );

                    // will return first buffered token (which will be Token.LT):
                    return readToken();
                }

                r = readToken2(false);

                // IO.Std.err.println( "token is: " + cast<int>(r) + ", string: " + token_string );

                buffer.write( new TokenPair(r, token_string) );

                if( r == Token.LT ) {
                    generic_level = generic_level + 1;
                    bracket_stack[generic_level] = r;
                    // IO.Std.err.println( "OK: open angle bracket..." );
                } else if( r == Token.GT ) {
                    // IO.Std.err.println( "OK: close angle bracket..." );
                    if( bracket_stack[generic_level] != Token.LT ) {
                        is_generic = false;
                        break;
                    }
                    generic_level = generic_level - 1;
                } else if( r == Token.SHIFT_RIGHT ) {
                    // IO.Std.err.println( "OK: shift right..." );
                    if( generic_level < 1 || bracket_stack[generic_level] != Token.LT || bracket_stack[generic_level-1] != Token.LT ) {
                        is_generic = false;
                        break;
                    }
                    generic_level = generic_level - 2;
                } else if( r == Token.CLOSE_PAREN ) {
                    if( bracket_stack[generic_level] != Token.OPEN_PAREN ) {
                        is_generic = false;
                        break;
                    }
                    generic_level = generic_level - 1;
                } else if( r == Token.PROC ) {
                    r = readToken2(false);
                    buffer.write( new TokenPair(r, token_string) );

                    if( r != Token.OPEN_PAREN ) {
                        is_generic = false;
                        break;
                    } else {
                        generic_level = generic_level + 1;
                        bracket_stack[generic_level] = r;
                    }
                } else if( r == Token.DOT || r == Token.COMMA || r == Token.IDENTIFIER ||
                           (r >= Token.ARRAY_DEF && r <= Token.REFERENCE ) || r == Token.VOID ) {
                    // IO.Std.err.println( "OK: basic type, identifier or dot..." );
                } else {
                    // IO.Std.err.println( "" + current_file + ": " + current_line + ": doesn't look like a generic - leaving buffered input alone" );
                    is_generic = false;
                    break;
                }
            } while( generic_level >= 0 );

            /*
            if( generic_level < 0 ) {
                // IO.Std.err.println( "" + current_file + ": " + current_line + ": doesn't look like a generic - leaving buffered input alone" );
                is_generic = false;
            }
            */

            if( is_generic ) {
                // IO.Std.err.println( "was generic - convert buffer..." );		
                buffer.makeGeneric();
            }
            // IO.Std.err.println( "read token: " + cast<int>(r) + " generic state now: " + generic_state + " generic level now: " + generic_level );

            return readToken();
        }

        
        Token readToken2(bool for_comment) {
            Token r;

            char c = skipWhiteSpace();
            if( end_of_file ) {
                return Token.EOF;
            }

            int open_line = current_line;

            StringBuffer buffer = null;
            token_string = null; // new StringBuffer("");

            // IO.Std.out.println( "number/letter: '" + c + "'?" );
            if( c >= '0' && c <= '9' ) {
                // IO.Std.out.println( "number: '" + c + "'" );
                buffer = new StringBuffer();
                buffer.append( c );
                c = nextChar();
                if( c == 'x' || c == 'X' ) {
                    buffer.append( c );
                    c = nextChar();
                    while( (c >= '0' && c <= '9') || 
                           (c >= 'A' && c <= 'F') || 
                           (c >= 'a' && c <= 'f') ||
                           c == 'x' || c == 'w' || c == 'W' || c == 'l' || c == 'L' ) {
                        buffer.append(c);
                        c = nextChar();
                    }
                    // IO.Std.err.println( "read hex const: '" + buffer + "'" );
                } else {
                    while( (c >= '0' && c <= '9') || c == 'x' || c == 'w' || c == 'W' || c == 'l' || c == 'L' || c == 'c' || c == 'C' ) {
                        buffer.append(c);
                        c = nextChar();
                    }
                }
                token_string = buffer.Freeze;
                prevChar(c);
                // IO.Std.err.println( "read const int: '" + token_string + "'" );
                return Token.CONST_INT;
            } else if( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' ) {
                // IO.Std.out.println( "letter: '" + c + "'" );
                buffer = new StringBuffer();
                while( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' ) {
                    buffer.append(c);
                    c = nextChar();
                }
                token_string = buffer.Freeze;
                prevChar(c);
                r = symbol_tokens[token_string];

                if( r == Token.OPERATOR ) {
                    return readOperatorMethodToken();
                }

                /*
                if( r == Token.OF ) {
                    // IO.Std.err.println( "seen of - in type..." );
                    in_type = true;
                    return readToken2();
                }
                */
                return r;
            }


            switch( c ) {
            case cast<char>(34): // double quote
                buffer = new StringBuffer();
                c = nextChar(); 
                while( c != cast<char>(34) ) {
                    if( c == cast<char>(92) ) { // backslash
                        c = readEscape();
                        buffer.append(c);
                        c = nextChar();
                    } else {
                        buffer.append(c);
                        c = nextChar();
                    }
                    if( end_of_file ) {
                        error( "end of file in string literal at line " + open_line );
                        break;
                    }
                }
                token_string = buffer.Freeze;
                return Token.CONST_STRING;

            case cast<char>(39): // single quote
                buffer = new StringBuffer();
                c = nextChar();
                while( c != cast<char>(39) ) {
                    if( c == cast<char>(92) ) { // backslash
                        c = readEscape();
                        buffer.append(c);
                        c = nextChar();
                    } else {
                        buffer.append(c);
                        c = nextChar();
                    }
                    if( end_of_file ) {
                        error( "end of file in character literal at line " + open_line );
                        break;
                    }
                }
                if( buffer.Length < 1 ) {
                    error( "zero length character literal" );
                }
                token_string = buffer.Freeze;
                // IO.Std.err.println( "const char: '" + token_string + "'" );
                return Token.CONST_CHAR;

            case '`':
                buffer = new StringBuffer();
                c = nextChar();
                while( c != '`' ) {
                    if( c == cast<char>(92) ) { // backslash
                        c = readEscape();
                        buffer.append(c);
                        c = nextChar();
                    } else {
                        buffer.append(c);
                        c = nextChar();
                    }
                    if( end_of_file ) {
                        error( "end of file in char ptr literal at line " + open_line );
                        break;
                    }
                }
                token_string = buffer.Freeze;
                return Token.CONST_CSTRING;
                    
            case '=':
                /*
                if( generic_level == 0 ) {
                    generic_state = IN_OTHER;
                    // IO.Std.err.println( "seen assign token: cannot be in a type now" );
                }
                */

                c = nextChar();
                if( c == '=' ) {
                    return Token.EQ;
                } else if( c == '~' ) {
                    return Token.OBJ_EQ;
                } else {
                    prevChar(c);
                    return Token.ASSIGN;
                }

            case '>':
                /*
                if( generic_level > 0 ) {
                    generic_level = generic_level - 1;
                    if( generic_level == 0 ) {
                        in_type = false;
                    }

                    // IO.Std.err.println( "in type > is close-generic, genric level now: " + generic_level );
                    return Token.CLOSE_GENERIC;
                }
                */

                // IO.Std.err.println( "> is not part of type" );

                c = nextChar();
                if( c == '=' ) {
                    return Token.GE;
                } else if( c == '>' ) {
                    return Token.SHIFT_RIGHT;
                } else {
                    prevChar(c);
                    return Token.GT;
                }

            case '<':
                /*
                if( generic_state == IN_ARGUMENTS || generic_state == IN_CAST || generic_state == MAYBE_IN_TYPE ) {
                    generic_level = generic_level + 1;
                    return Token.OPEN_GENERIC;
                }
                */

                // IO.Std.err.println( "< is not part of type" );

                /*
                if( in_type ) {
                    generic_level = generic_level + 1;
                    // IO.Std.err.println( "in type < is open-generic, genric level now: " + generic_level );
                    return Token.OPEN_GENERIC;
                }
                */

                c = nextChar();
                if( c == '=' ) {
                    return Token.LE;
                } else if( c == '<' ) {
                    return Token.SHIFT_LEFT;
                } else {
                    prevChar(c);
                    return Token.LT;
                }

            case '!':
                c = nextChar();
                if( c == '=' ) {
                    return Token.NE;
                } else if( c == '~' ) {
                    return Token.OBJ_NE;
                } else {
                    prevChar(c);
                    return Token.BOOL_NOT;
                }

            case '&':
                c = nextChar();
                if( c == '&' ) {
                    return Token.BOOL_AND;
                } else {
                    prevChar(c);
                    return Token.AND;
                }
                
            case '|':
                c = nextChar();
                if( c == '|' ) {
                    return Token.BOOL_OR;
                } else {
                    prevChar(c);
                    return Token.OR;
                }

            case '~': return Token.NOT;
            case '^': return Token.XOR;

            case '{':
                // generic_state = MAYBE_IN_TYPE;
                return Token.START_BLOCK;

            case '}': return Token.END_BLOCK;

            case '(':
                /*
                if( generic_state == IN_ARGUMENTS ) {
                    generic_state = MAYBE_IN_TYPE;
                } else if( generic_level == 0 ) {
                    if( generic_state != IN_FOR ) {
                        // IO.Std.err.println( "seen left paren: cannot be in type" );
                        generic_state = IN_OTHER;
                    }
                    paren_level = paren_level + 1;
                }
                */
                return Token.OPEN_PAREN;

            case ')':
                /*
                paren_level = paren_level - 1;
                if( generic_state == IN_ARGUMENTS && paren_level == 0 ) {
                    generic_state = IN_OTHER;
                }
                */
                return Token.CLOSE_PAREN;

            case '[':
                c = skipWhiteSpace();
                if( end_of_file ) {
                    return Token.OPEN_SQUARE;
                } else if( c == ']' ) {
                    return Token.ARRAY_DEF;
                } else {
                    prevChar(c);
                    return Token.OPEN_SQUARE;
                }

            case ']': return Token.CLOSE_SQUARE;

            case '+': return Token.ADD;
            case '-': return Token.SUB;
            case '*': return Token.MUL;
            case '/':
                c = nextChar();
                if( c == '/' ) {
                    buffer = new StringBuffer("//");
                    do {
                        c = nextChar();
                        if( c != '\n' ) {
                            buffer.append( c );
                        }
                    } while( !end_of_file && c != '\n' );

                    if( buffer.startsWith("///" ) ) {			
                        buffer.append( "\n" );
                        if( for_comment ) {
                            // IO.Std.err.println( "from: " + new System.Backtrace() );
                            // IO.Std.err.println( "appending comment: " + buffer );
                            ParseTree.appendLastComment(buffer);
                        } else {
                            ParseTree.LastComment = buffer;
                        }
                        return readToken2(true);
                    } else {
                        return readToken2(false);
                    }
                } else if( c == '*' ) { 
                    buffer = new StringBuffer("/*");
                    do {
                        c = nextChar();

                        if( c == '*' ) {
                            c = nextChar();
                            if( c == '/' ) {
                                break;
                            }
                            buffer.append( '*' );
                        }
                        buffer.append( c );

                    } while( !end_of_file );

                    if( buffer.startsWith( "/**" ) ) {
                        buffer.append( "*/" );
                        if( for_comment ) {
                            IO.Std.err.println( "from: " + new System.Backtrace() );
                            IO.Std.err.println( "appending comment: " + buffer );
                            ParseTree.appendLastComment(buffer);
                        } else {
                            ParseTree.LastComment = buffer;
                        }
                        return readToken2(true);		    
                    } else {
                        return readToken2(false);
                    }
                } else {
                    prevChar(c);
                    return Token.DIV;
                }
            case '%': return Token.MOD;	    

            case '.': 
                c = nextChar();
                if( c == '.' ) {
                    return Token.RANGE;
                } else {
                    prevChar(c);
                    return Token.DOT;
                }

            case ',': return Token.COMMA;

            case ':': 
                c = nextChar();
                if( c == ':' ) {
                    return Token.RANGE_INCLUSIVE;
                } else {
                    prevChar(c);
                    return Token.COLON;
                }

            case ';': 
                return Token.END_STATEMENT;

            case '@':
                return Token.PRAGMA;

            case '#':
                buffer = new StringBuffer();
                do {
                    c = nextChar();
                    if( c < '0' || c > '9' ) { 
                        prevChar(c);
                        break;
                    }
                    buffer.append(c);
                } while(true);

                current_line = buffer.parseInt();

                return readToken2(false);
            }
            
            // IO.Std.out.println( "unknown: '" + c + "'" );
            return Token.UNKNOWN;
        }
    }
}
