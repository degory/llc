// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import token;
import synskel;
import syntaxl;
import syntaxk;
import parsetree;

namespace Parse {

    class Parser {
        Tokenizer tokenizer;

        void init( System.String file_name, IO.Reader in, CompileState state ) {
            Token t;
            tokenizer = new Tokenizer(file_name,in);
            // tokenizer.nextToken();

	    ParseTree.setCurrentFileName( file_name );

	    YaccParser yp;
	    if( tokenizer.WantNewSyntax ) {
		// IO.Std.err.println( "file: '" + file_name + "' is K syntax" );
		yp = new ParseK.YaccParserK();
	    } else {
		// IO.Std.err.println( "file: '" + file_name + "' is L syntax" );
		yp = new YaccParserL();
	    }

	    // var yp = new YaccParserL();
	    Package p = cast<Package>(yp.yyparse(tokenizer));

            state.addPackage( p );
            // IO.Std.out.println( "done state: " + state );
        }
    }
}
