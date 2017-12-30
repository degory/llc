#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import stream;
import vector;
import gmap;

namespace LGen {
    class TokenizerException extends System.Exception {
        void init( System.String s ) {
            super.init(s);
        }
    }

    class TokenHolder extends System.Object {
        public Token token;
        void init( Token token ) {
            super.init();
            this.token = token;
        }
    }

    class TokenMap extends System.Object {
        Generic.Map<System.String,TokenHolder> map;

        void init() {
            super.init();
            map = new Generic.Map<System.String,TokenHolder>(31);
        }

        void opSet( System.String s, Token t ) {
            map[s] = new TokenHolder(t);
        }

        Token opGet( System.String s ) {
            TokenHolder th = map[s];
            if( th != null ) {
                return th.token;
            } else {
                return Token.IDENTIFIER;
            }
        }
    }

    class TokenPair extends System.Object {
        System.String string;
        Token token;

        void init( Token token, System.String string ) {
            super.init();
            this.token = token;
            this.string = string;
        }

        System.String getString() {
            return string;
        }

        Token getToken() {
            return token;
        }
    }

    class Tokenizer extends System.Object {
        Token token;
        TokenMap symbol_tokens;
        System.String token_string;
        IO.Reader input;
        bool end_of_file, buffer_tokens;
        char prev_char;

        int read_index;
        int line_number;

        System.String[] token_name;
        Util.Vector read_buffer;
        Util.Vector mark_buffer;

        void init( IO.Reader i ) {
            super.init();

            end_of_file = false;
            input = i;
            token_name = {
                "Identifier",
                "Number",
                "String",
                "Code string",
                "Tree code",
                "Character",
                
                "{",
                "}",
                "(",
                ")",
                "[",
                "]",
                
                "=",
                
                "<",
                "<=",
                ">",
                ">=",
                "==",
                "!=",
                
                "!",
                "&&",
                "||",
                
                "~",
                "&",
                "|",
                
                "+",
                "-",
                "*",
                "/",
                
                "<<",
                ">>",

                ".",
                ",",
                ":",
                ";",
                "$",

                "terminal",
                "rule",
                "start",
                "rewrite",
                "machine",

                "unknown",
                "end of file"
            };

            symbol_tokens = new TokenMap();

            symbol_tokens["terminal"] = Token.TERMINAL;
            symbol_tokens["rule"] = Token.RULE;
            symbol_tokens["start"] = Token.START;
            symbol_tokens["rewrite"] = Token.REWRITE;
            symbol_tokens["machine"] = Token.MACHINE;

            read_buffer = new Util.Vector();
            mark_buffer = new Util.Vector();
        }

        bool isEndOfFile() {
            return end_of_file;
        }


        int mark() {
            // start buffering tokens in the mark buffer (if not already)
            // return the current mark buffer depth. caller must supply this depth when rolling back
            buffer_tokens = true;
            int result = mark_buffer.getLength();
            mark_buffer.add( new TokenPair( token, token_string ) );
            return result;
        }

        void commit(int depth) {
            mark_buffer.setLength(depth);
        }

        void rollBack(int depth) {
            IO.Std.out.println( "rolling back to mark depth " + depth );
            // roll back to previous state - all tokens in the mark buffer above depth need to be
            // shifted to the token buffer and then the mark buffer must be cleared above depth.
            TokenPair p = null;
            int s = mark_buffer.getLength();
            IO.Std.out.println( "shifting " + (s - depth) + " (" + s + "-" + depth + ") tokens..." );
            for( int i = depth; i < s; i = i + 1 ) {
                p = cast<TokenPair>(mark_buffer[i]);
                IO.Std.out.println( "buffering: " + getName(p.getToken()) + "/" + p.getString() );
                read_buffer.add(p);
            }

            mark_buffer.setLength(depth);
            if( depth <= 0 ) {
                buffer_tokens = false;
            }

            nextToken();
        }

        char nextChar() {
            char c;
            if( prev_char != cast<char>(0) ) {
                c = prev_char;
                prev_char = cast<char>(0);
                // IO.Std.out.println( "next char: returning buffered: '" + c + "'" );
                return c;     
            }

            int c0 = input.read();

            if( c0 == -1 ) {
                // IO.Std.out.println( "next char: returning eof" );
                end_of_file = true;
                return ' ';
            }
            c = cast<char>(c0);
            // IO.Std.out.println( "next char: returning '" + c + "'" );
            return c;
        }

        void prevChar( char c ) {
            prev_char = c;
        }

        System.String getBuffer() {
            return token_string;
        }

        System.String getName(Token t) {
            return token_name[cast<int>(t)];
        }

        int getLineNumber() {
            return line_number;
        }

        char readEscape() {
            char c = nextChar();

            // IO.Std.out.println( "readEscape: '" + c + "'..." );
            int result = 0;
            if( c == 't' ) {
                // IO.Std.out.println( "escape tab" );
                return cast<char>(9);
            } else if( c == 'n' ) {
                // IO.Std.out.println( "escape newline" );
                return '\n';
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

        Token getToken() {
            return token;
        }

        Token nextToken() {
            TokenPair tp = null;
            if( read_index < read_buffer.getLength() ) {
                IO.Std.out.println( "" + read_index + " > " + read_buffer.getLength() );
                tp = cast<TokenPair>(read_buffer[read_index]);

                read_index = read_index + 1;
                if( read_index >= read_buffer.getLength() ) {
                    // read the last token stored in the buffer. clear the buffer.
                    read_index = 0;
                    read_buffer.setLength(0);
                }

                token = tp.getToken();
                token_string = tp.getString();
            } else {
                token = readToken();
            }

            if( buffer_tokens ) {
                if( tp == null ) {
                    tp = new TokenPair( token, token_string );
                }
                mark_buffer.add( tp );
            }
            return token;
        }

        Token readToken() {

            char c;
            do {
                c = nextChar();
                if( c == '/' ) {
                    c = nextChar();
                    if( c == '/' ) {
                        do {
                            c = nextChar();
                        } while( c != '\n' && !end_of_file );
                    } else {
                        prevChar(c);
                    }
                }
                // IO.Std.out.println( "white space: '" + c + "'?" );
                if( c == '\n' ) {
                    line_number = line_number + 1;
                    IO.Std.err.println( "read line " + line_number );
                }
            } while( !end_of_file && (c == ' ' || c == cast<char>(9) || c == '\n') );

            if( end_of_file ) {
                IO.Std.err.println( "end of file" );
                return Token.EOF;
            }


            System.StringBuffer buffer;
            int block_level;

            // IO.Std.out.println( "number/letter: '" + c + "'?" );
            if( c == '{' ) {
                // C-style code block - treat as string.
                c = nextChar();
                if( c == '}' ) {
                    token_string = "";
                    return Token.CODE_STRING;
                }

                block_level = 1;

                buffer = new System.StringBuffer();
                while( block_level > 0 && !end_of_file ) {
                    if( c == '}' ) {
                        block_level = block_level - 1;
                    } else if( c == '{' ) {
                        block_level = block_level + 1;
                    } else if( c == '"' ) {
                        do {
                            buffer.append(c);
                            c = nextChar();
                        } while( c != '"' );
                        buffer.append( c );
                    } else {
                        buffer.append( c );
                    }
                    c = nextChar();
                }
                prevChar(c);
                token_string = buffer;
                return Token.CODE_STRING;
            } else if( c >= '0' && c <= '9' ) {
                // IO.Std.out.println( "number: '" + c + "'" );
                buffer = new System.StringBuffer();
                while( c >= '0' && c <= '9' ) {
                    buffer.append(c);
                    c = nextChar();
                }
                token_string = buffer;
                prevChar(c);
                return Token.NUMBER;
            } else if( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' ) {
                // IO.Std.out.println( "letter: '" + c + "'" );
                buffer = new System.StringBuffer();
                while( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' ) {
                    buffer.append(c);
                    c = nextChar();
                }
                token_string = buffer;
                prevChar(c);
                return symbol_tokens[token_string];
            }

            token_string = new System.StringBuffer("");

            switch( c ) {
            case cast<char>(34): // double quote
                buffer = new System.StringBuffer();
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
                }
                token_string = buffer;
                return Token.STRING;

            case cast<char>(39): // single quote
                buffer = new System.StringBuffer();
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
                }
                token_string = buffer;
                return Token.CHARACTER;
                    
            case '=':
                c = nextChar();
                if( c == '=' ) {
                    return Token.EQ;
                } else {
                    prevChar(c);
                    return Token.ASSIGN;
                }

            case '>':
                c = nextChar();
                if( c == '=' ) {
                    return Token.GE;
                } else if( c == '>' ) {
                    return Token.SHR;
                } else {
                    prevChar(c);
                    return Token.GT;
                }

            case '<':
                c = nextChar();
                if( c == '=' ) {
                    return Token.LE;
                } else if( c == '<' ) {
                    return Token.SHL;
                } else {
                    prevChar(c);
                    return Token.LT;
                }

            case '!':
                c = nextChar();
                if( c == '=' ) {
                    return Token.NE;
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
                    return Token.INT_AND;
                }
                
            case '|':
                c = nextChar();
                if( c == '|' ) {
                    return Token.BOOL_OR;
                } else {
                    prevChar(c);
                    return Token.INT_OR;
                }

            case '{': return Token.OPEN_BRACE;
            case '}': return Token.CLOSE_BRACE;
            case '(': return Token.OPEN_PAREN;
            case ')': return Token.CLOSE_PAREN;
            case '[': return Token.OPEN_SQUARE;
            case ']': return Token.CLOSE_SQUARE;

            case '+': return Token.ADD;
            case '-': return Token.SUB;
            case '*': return Token.MUL;
            case '/':
                c = nextChar();
                if( c == '/' ) {
                    do {
                        c = nextChar();
                    } while( !end_of_file && c != '\n' );
                    return readToken();
                } else {
                    prevChar(c);
                    return Token.DIV;
                }

            case '.': return Token.DOT;
            case ',': return Token.COMMA;
            case ':': return Token.COLON;
            case ';': return Token.SEMICOLON;
            case '$': return Token.DOLLAR;
            }
            
            IO.Std.out.println( "unknown: '" + c + "'" );
            return Token.UNKNOWN;
        }
    }
}
