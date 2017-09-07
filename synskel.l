#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

namespace Parse {
    use System.Object;
    use System.String;
    use System.Exception;


    /** thrown for irrecoverable syntax errors and stack overflow.
     */
    class ParseException extends Exception {
        public void init(String message) {
            super.init(message);
        }
    }

    /** must be implemented by a scanner object to supply input to the parser.
     */
    class yyInput {
        void init() {}
        /** move on to next token.
            @return false if positioned beyond tokens.
            @throws IOException on input error.
        */
        bool nextToken () { return false; }
        /** classifies current token.
            Should not be called if advance() returned false.
            @return current %token or single character.
        */
        int getCurrentToken () { return 0; }
        /** associated with current token.
            Should not be called if advance() returned false.
            @return value for token().
        */
        int getLine() { return 0; }
        System.String getFile() { return "unknown"; }

        System.String getReportingFile() { return "unknown"; }
        void markInArgumentsDeclaration() { IO.Std.err.println( "yyInput - in arguments defintion - should not happen" ); }
        Object getValue () {}
    }

    class YaccParser {
        protected String yytext;
        protected String string_constant_buffer;

        protected int yyMax;
        protected int first_line;
        /** simplified error message.
            @see <a href="#yyerror(java.lang.String, java.lang.String[])">yyerror</a>
        */

        void init() {
            yytext = null;
            string_constant_buffer = null;
            first_line = 0;
        }

        public void yyerror( yyInput tokenizer, String message) {
            yyerror(tokenizer, message, null);
        }

        /** (syntax) error message.
            Can be overwritten to control message format.
            @param message text to be displayed.
            @param expected vector of acceptable tokens, if available.
        */
        public void yyerror( yyInput tokenizer, String message, String[] expected) {
            IO.Std.err.print( tokenizer.ReportingFile + ": " + tokenizer.Line + ",0.." + (tokenizer.Line + 1) + ",0: error: ");

            if (expected != null && expected.length > 0) {
                IO.Std.err.print(message+", expecting");
                for (int n = 0; n < expected.length; n = n + 1) {
                    IO.Std.err.print(" "+expected[n]);
                }
                IO.Std.err.println();
            } else {
                IO.Std.err.println(message);
            }
        }

        /** computes list of expected tokens on error by tracing the tables.
            @param state for which to compute the list.
            @return list of token names.
        */
        protected String[] yyExpecting(int state) {
            System.String[] result;
            try {
                result = yyExpecting2(state);
            } catch( System.Exception e ) {
                return null;
            }
        }

        protected String[] yyExpecting2(int state) {

        }

        /** executed at the beginning of a reduce action.
            Used as $$ = yyDefault($1), prior to the user-specified action, if any.
            Can be overwritten to provide deep copy, etc.
            @param first value for $1, or null.
            @return first.
        */
        protected Object yyDefault (Object first) {
            return first;
        }

  
        /** the generated parser, with debugging messages.
            Maintains a state and a value stack, currently with fixed maximum size.
            @param yyLex scanner.
            @param yydebug debug message writer implementing yyDebug, or null.
            @return result of the last reduction, if any.
            @throws yyException on irrecoverable parse error.
        */
        public Object yyparse (yyInput yyLex, Object yydebug) {
            //t    this.yydebug = cast<jay.yydebug.yyDebug>(yydebug);
            return yyparse(yyLex);
        }

        public Object yyparse( yyInput yyLex ) {
            try {
                return yyparse2( yyLex );
            } catch( System.Exception e ) {
                yyerror( yyLex, "parse error" );

                // IO.Std.err.println( e );
                
                if( CompileState.Instance.WantVeryVerbose ) {
                    yyerror( yyLex, "exception in parser: " + e );
                } else {
                    yyerror( yyLex, "parse error" );
                }
                throw new ParseException( "internal parser error" );
            }
        }

        public Object yyparse2( yyInput yyLex ) {

        }
    }
}