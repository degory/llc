#C

import generic;
import htmlencoder;
import htmlexception;

namespace Web {
    use System.String;
    use System.StringBuffer;
    use Generic.Vector;
    use Generic.Map;
    use Generic.MapPair;

    /** an in memory HTML buffer with methods to add various HTML elements and attributes to the buffer and
     * enforce correct nesting by matching opening and closing HTML tags
     */
    class HTMLBuilder extends System.Object {
	StringBuffer buffer;             // accumulated HTML output
	Vector<HTMLState> tag_stack;     // stack of closing tags for enclosing elements
        Map<String,String> default_tag_classes;   // default CSS style to set for tags via class attribute
	String current_tag_class;        // CSS class of current tag, either from default
	// or from class attribute
	bool is_current_tag_complete; // is the current tag closed with a '>' yet?

	Map<String,String> current_styles;     // accumulated dictionary of values for current
	                                           // tag's 'style' attribute, indexed by name
	Map<String,String> current_attributes;    // accumulated dictionary of attributes for current
	                                              // tag, indexed by name
	bool should_indent;

	bool before_page_start;
	bool seen_form;

	String user_agent;  // browser user agent

	// JavaScriptDataFormat js_data_format;

	public void init() {
	    should_indent = true;
	    before_page_start = true;
	    user_agent = "unknown";

	    buffer = new StringBuffer();
	    tag_stack = new Vector<HTMLState>();
	    default_tag_classes = new Map<String,String>();
	    is_current_tag_complete = true;
	    current_attributes = new Map<String,String>();
	    current_styles = new Map<String,String>();
	}
	
	public void setDefaultTagClass(String tag, String css_class) {
	    tag = makeNakedTag(tag); // .toLowerCase();
	    default_tag_classes[tag] = css_class;
	}
	
	public void clearDefaultTagClass(String tag) {
	    tag = makeNakedTag(tag); // .toLowerCase();
	    
	    default_tag_classes.remove( tag );
	}
	
	public String getDefaultTagClass(String tag) {
	    tag = makeNakedTag(tag); // .toLowerCase();
	    return default_tag_classes[tag];
	}
	
	public void setUserAgent( String user_agent ) {
	    this.user_agent = user_agent;
	    initializeBrowserCapabilities();
	}

	public void initializeBrowserCapabilities() {
	}

	/*
	  public JavaScriptDataFormat getJSDataFormat() {
	  if( js_data_format == null ) {
	  js_data_format = new JavaScriptDataFormat();
	  }
	  
	  return js_data_format;
	  }
	*/
	
	public void openHeading(int outline_level) {
	    open( makeHeadingTag(outline_level) );
	}

	public void closeHeading(int outline_level) {
	    close( makeHeadingTag(outline_level) );
	}


	// output a complete heading tag at given outline level containing supplied text:
	public void heading(int outline_level, String t) {
	    openHeading(outline_level);
	    text(t);
	    closeHeading(outline_level);
	}

	public void title( String title ) {
	    open( "<title>" );
	    text( title );
	    close( "<title>" );
	}
	
	public void appendStyleLink( String href ) {
	    open( "<link>" );
	    attribute( "rel", "Stylesheet" );
	    attribute( "type", "text/css" );
	    attribute( "href", href );
	    closeEmpty( "<link>" );
	}
	
	public void appendJSLink( String src ) {
	    open( "<script>" );
	    attribute( "language", "Javascript" );
	    attribute( "type", "text/javascript" );
	    attribute( "src", src );
	    close( "<script>" ); // note: not closeEmpty() as empty <script> elements don't work in IE
	}

	// if openPage is not used, call this to kick start indentation. Otherwise all output will be unindented and on the same line
	public void startSubPage() {
	    before_page_start = false;
	}

	public bool isPageOpen() {
	    return !before_page_start;
	}
	

	bool getAnyBuffered() {
	    return buffer.Length > 0;
	}

	// start an HTML page leaving the body element open.
	// Adds a title element with supplied text and links to the grid css and Javascript files
	// Appends supplied attributes/values to html tag and head tag
	public void openPage(String page_title, String[] html_attributes, String[] head_attributes) {
	    open( "<html>");
	    startSubPage();
	    attributes( html_attributes );
	    open( "<head>" );
	    attributes( head_attributes );
	    // appendStyleLink( "grid.css" );
	    title( page_title );
	    close( "<head>" );
	    open( "<body>" );
	    // appendJSLink( "grid.js" );
	}

	public void openPage( String title ) {
	    openPage( title, null, null );
	}

	// closes an HTML page, assuming that the body element is still open
	public void closePage() {
	    close("<body>");
	    close("<html>");
	}

	public void openTable() {
	    open( "<table>" );
	}

	public void closeTable() {
	    close( "<table>" );
	}

	public void openDiv() {
	    open( "<div>" );
	}
	
	public void closeDiv() {
	    close( "<div>" );
	}

	public void openForm( String action, String method ) {
	    open( "<form>" );
	    if( action != null ) {
		attribute( "action", action );
	    }
	    attribute("method", method);
	}

	public void closeForm() {
	    close( "<form>" );
	}
	
	public void openColumn(int width) {
	    open( "<col>", false );
	    attribute("width", width);
	}

	public void closeColumn() {
	    closeEmpty( "<col>" );
	}

	public void appendColumn(int width) {
	    openColumn( width );
	    closeColumn();
	}

	public void openTableHeading() {
	    open( "<th>" );
	}

	public void closeTableHeading() {
	    close( "<th>" );
	}

	public void openTableRow() {
	    open( "<tr>" );
	}

	public void closeTableRow() {
	    close( "<tr>" );
	}

	public void openTableCell() {
	    open( "<td>", false );
	}

	public void closeTableCell() {
	    close( "<td>" );
	}

	public void tableHeading(String t) {
	    openTableHeading();
	    text(t);
	    close();
	}

	public void tableCell(String t) {
	    openTableCell();
	    text(t);
	    close();
	}

	public void openScript() {
	    open( "<script>" );
	    attribute( "language", "Javascript" );
	    attribute( "type", "text/javascript" );
	}
	
	public void closeScript() {
	    close( "<script>" );
	}

	public void script(String text) {
	    textu(text);
	}


	public void appendButton(String text, String action) {
	    open( "<input>" );
	    attribute( "class", "button" );
	    attribute( "type", "button" );
	    attribute( "value", text );
	    attribute( "onClick", action );
	    closeEmpty( "<input>" );
	}

	public void appendInput( String type, String input_id, String text, bool encode ) {
	    open( "<input>" );
	    attribute( "type", type );
	    if( input_id != null ) {
		id( input_id );
		name( input_id );
	    }
	    if( text != null ) {
		if( encode ) {
		    text = HTMLEncode(text);
		}
		attribute( "value", text );
	    } else {
		attribute( "value", "" );
	    }
	    closeEmpty( "<input>" );
	}

	public void appendTextInput( String id, String text ) {
	    appendInput( "text", id, text, true );
	}

	public void appendHiddenInput( String id, String text, bool encode ) {
	    appendInput( "hidden", id, text, encode );
	}

	public void appendHiddenInput( String id, String text ) {
	    appendHiddenInput( id, text, true );
	}
	
	public void appendPasswordInput( String id, String text ) {
	    appendInput( "password", id, text, true );
	}

	public void openSelect() {
	    open( "<select>" );
	}

	public void closeSelect() {
	    close( "<select>" );
	}

	public void appendSelectOption( String text, String value ) {
	    appendSelectOption( text, value, false );
	}

	public void appendSelectOption( String text ) {
	    appendSelectOption( text, text, false );
	}

	public void appendSelectOption( String t, String value, bool selected ) {
	    open( "<option>", false );
	    attribute( "value", value );
	    if( selected ) {
		attribute( "selected" );
	    }
	    text( t );
	    close( "<option>" );
	}

	public void openAnchor( String url ) {
	    open( "<a>" );
	    attribute( "href", url );
	}

	public void closeAnchor() {
	    close( "<a>" );
	}

	public void anchor( String url, String t ) {
	    openAnchor(url);
	    text(t);
	    close();
	}

	public void openImage( String url ) {
	    open( "<img>" );
	    attribute( "src", url );
	}

	public void closeImage() {
	    closeEmpty( "<img>" );
	}

	public void image( String url ) {
	    openImage( url );
	    closeImage();
	}

	public void openList( bool ordered ) {
	    if( ordered ) {
		open( "<ol>" );
	    } else {
		open( "<ul>" );
	    }
	}
	
	public void closeList( bool ordered )  {
	    if( ordered ) {
		close( "<ol>" );
	    } else {
		close( "<ul>" );
	    }
	}
	
	public void openListItem()  {
	    open( "<li>" );
	}

	public void closeListItem()  {
	    close( "<li>" );
	}

	public void listItem( String t )  {
	    openListItem();
	    text( t );
	    closeListItem();
	}

	// given an opening tag, stack an appropriate closing tag and output an incomplete
	// version of the tag suitible for appending attributes to. For example
	// '<table>' results in '<table' being output. The incomplete tag will be completed
	// (with '>') when either a nested tag is opened or text is output

	// The opening tag should be a lower case angle bracketed HTML tag with no
	// attributes and no spaces around it.
	public void open( String opening_tag )  {
	    open( opening_tag, null );
	}

	public void open( String opening_tag, String closing_tag )  {
	    open( opening_tag, null, true );
	}

	public void open( String opening_tag, bool indent )  {
	    open( opening_tag, null, indent );
	}

	// do the actual work of opening a tag. If supplied closing tag is null, a closing
	// tag will be constructed from the supplied opening tag. If not then supplied
	// closing tag will be stacked instead (use if tags are not expected to nest correctly
	// for some reason)
	public void open( String opening_tag, String closing_tag, bool want_indent )  {
	    completeCurrentTag();

	    // turn '<tag>' into 'tag':
	    String naked_tag = makeNakedTag( opening_tag );

	    // turn 'tag' into '<tag' and send to output:
	    opening_tag = makeIncompleteOpeningTag(naked_tag);
	    indent( want_indent );
	    append( opening_tag );

	    if( closing_tag == null ) {
		// if no </tag> supplied, make one:
		closing_tag = makeClosingTag( naked_tag );
	    }

	    push( closing_tag, want_indent );

	    // no '>' output for current tag yet, so tag parameters are still possible
	    // and tag must be completed before text or another tag is issued:
	    markCurrentTagNotComplete();

	    // store default class attribute if set:
	    String default_class = getDefaultTagClass(naked_tag);
	    if( default_class != null ) {
		attribute("class", default_class);
	    }
	}

	public void checkClose( String opening_tag )  {
	    HTMLState top_state = top();
	    String closing_tag = makeClosingTag( makeNakedTag(opening_tag) );

	    if( top_state.tag !~ closing_tag ) {
		throw new HTMLException( "mismatched closing tag: given '" + opening_tag + "', generated closing tag '" + closing_tag + "', stack top '" + top_state + "'" );
	    }
	}

	// close empty element (element that has no closing </tag>)
	public void closeEmpty( String opening_tag )  {
	    checkClose( opening_tag );
	    closeEmpty();
	}

	// close the currently open tag. Check that the stacked closing tag matches the
	// supplied opening tag
	public void close( String opening_tag )  {
	    checkClose( opening_tag );
	    close();
	}

	public void closeEmpty()  {
	    close( true );
	}

	// close the currently open tag using the stacked closing tag.
	public void close()  {
	    close( false );
	}

	public void close(bool empty)  {
	    completeCurrentTag(empty);
	    HTMLState state = pop();
	    should_indent = state.indent && !empty;
	    indent();
	    should_indent = state.indent;
	    if( !empty ) {
		append( state.tag );
	    }
	}


	// reset page to initial state ready for re-use (drop everything on the stack, discard the output buffer and reset before page start flag)
	public void clear() {
	    tag_stack.Length = 0;
	    buffer = new StringBuffer();
	    before_page_start = true;
	}

	// close all open tags
	public void closeAll()  {
	    while( tag_stack.Length > 0 ) {
		close();
	    }
	}

	public void id( String id )  {
	    attribute( "id", id );
	}

	public void name( String name )  {
	    attribute( "name", name );
	}

	public void attribute( String name )  {
	    attribute( name, null );
	}

	public void attribute( String name, int value )  {
	    attribute( name, "" + value );
	}

	// store a tag attribute with the supplied name and value. Supplied value should be HTML encoded
	public void attribute( String name, String value )  {
	    if( isCurrentTagComplete() ) {
		throw new HTMLException( "cannot add params to current tag '" + top() + "', tag is already complete" );
	    }

	    // storing a string pair saves enumerating over Hashtable's keys and then
	    // looking them all up one by one later
	    current_attributes[name] = value;

	}

	// Directly output a name/attribute pair. Current tag must be incomplete or resulting
	// HTML will be malformed. No checking is done. Name and value must be HTML encoded
	void appendAttribute( String name, String value ) {
	    append( " " );
	    append( name );
	    if( value != null ) {
		append( "=\"" );
		// not HTML encoding here. If required, supply encoded value:
		append( value );
		append( "\"" );
	    }
	}

	// append a list of tag attributes. Array alternates attribute names and values for example:
	// new String[] { "class", "print", "width", "25" }
	public void attributes( String[] attributes )  {
	    if( attributes == null || attributes.length == 0 ) {
		return;
	    }

	    if( attributes.length % 2 != 0 ) {
		throw new HTMLException( "attribute names and values not correctly paired" );
	    }

	    for( int i = 0; i < attributes.length; i = i + 2 ) {
		attribute( attributes[i], attributes[i+1] );
	    }
	}

	public void comment( String text )  {
	    textu( "<!-- " + text + " -->" );
	}

	// append supplied style "name: value;" pair to the accumulated style attributes
	// for the current tag. Supplied value should be HTML encoded:
	public void style(String name, String value)  {
	    current_styles[name] = value;
	}
	
	// output supplied text.
	// Current tag will first be completed (with '>') if needed.
	// Text will be HTML encoded.
	// null text is acceptable, in which case the current tag is still completed
	// but nothing is output.
	/**
	 * output text HTML encoded, including spaces converted to HTML non breaking spaces and newlines converted
	 * to <br> elements
	 */
	public void textExact(String text)  {
	    completeCurrentTag();
	    indent();
	    if( text != null ) {
		appendQuotedExact( text );
	    }
	}

	/** output text HTML encoded with newlines converted to <br> elements but white space left as is
	 */
	public void text( String text )  {
	    completeCurrentTag();
	    indent();
	    if( text != null ) {
		appendQuoted( text );
	    }
	}

	public void textu(String text)  {
	    completeCurrentTag();
	    indent();
	    if( text != null ) {
		append( text );
	    }
	}

	public void textUnquoted( String text ) {
	    textu(text);
	}

	public String HTMLEncode( String s ) {
	    return HTMLEncoder.encode( s );
	}

	/*
	public String formatJSStringLiteral( String s ) {
	    return getJSDataFormat().formatJSStringLiteral(s);
	}

	public String formatJSStringLiteralNonNullOrBlank( String s ) {
	    return getJSDataFormat().formatJSStringLiteralNonNullOrBlank( s );
	}
	*/

	// return the accumulated HTML output as a string:
	public String toString() {
	    return buffer.toString();
	}

	// retain existing state but remove and return all currently buffered output:
	public String mark() {
	    IO.Std.err.println( "html output mark: " + buffer );
	    System.String result = buffer;
	    buffer = new System.StringBuffer();
	    return result;
	}

	// pretty indent the HTML by outputting spaces based on the current element
	// nesting level
	void indent() {
	    if( before_page_start || !should_indent ) {
		// log.println( "not indenting because: before_page_start: " + before_page_start + ", should_indent: " + should_indent );
		// log.println( "stack is: " + tag_stack );
		return;
	    }
	    int depth = tag_stack.Length;
	    append( "\n" );
	    for( int i = 0; i < depth; i = i + 1 ) {
		append( "  " );
	    }
	}

	void indent( bool want_indent ) {
	    if( !should_indent && want_indent ) {
		should_indent = want_indent;
		indent();
	    } else {
		indent();
		should_indent = want_indent;
	    }
	    // log.println( "indent: " + indent + " from: " + new System.Backtrace() );
	}

	void markCurrentTagComplete() {
	    is_current_tag_complete = true;
	}

	void markCurrentTagNotComplete() {
	    is_current_tag_complete = false;
	}

	bool isCurrentTagComplete() {
	    return is_current_tag_complete;
	}

	void push( String tag, bool indent ) {
	    HTMLState state = new HTMLState(tag, indent);
	    tag_stack.add( state );
	}

	// get the current closing tag from the stack top. Do not alter the stack.
	// Throw an exception if the stack is empty.
	HTMLState top()  {
	    return tag_stack.Top;
	}

	// remove and return the current closing tag from the stack top. Throw an
	// exception if attempting to remove an element from an empty stack
	HTMLState pop()  {
	    int last = tag_stack.Length - 1;
	    if( last < 0 ) {
		throw new HTMLException( "HTML tag stack underflow" );
	    }

	    return tag_stack.pop();
	}

	// output quoted text without completing current open tag:
	void appendQuotedExact( String text ) {
	    // Java does not appear to provide a mechanism for this (!)
	    append( HTMLEncoder.encode(text) );
	}

	// output quoted text without completing current open tag:
	void appendQuoted( String text ) {
	    // Java does not appear to provide a mechanism for this (!)
	    append( HTMLEncoder.encodeLax( text ) );
	}


	// output stored attributes for the current open tag. Tag must be incomplete (not checked)
	void appendAttributes() {
	    foreach( MapPair<String,String> p; current_attributes.pairs() ) {
		appendAttribute( p.key, p.value );
	    }
	}

	/** output stored attribute value pairs for the current HTML element and then clear the stored
	 * attributes. Current element must be incomplete (not checked)
	 */
	void appendAndClearAttributes() {
	    appendAttributes();
	    current_attributes.clear();
	}

	// output stored style values for the current open tag. Tag must be incomplete (not checked)
	void appendStyles() {
	    StringBuffer style = new StringBuffer();
	    foreach( MapPair<String,String> p; current_styles.pairs() ) {
		style
		    .append( p.key )
		    .append( ':' )
		    .append( p.value )
		    .append( ';' );
	    }
	    if( style.Length > 0 ) {
		appendAttribute( "style", style );
	    }
	}

	void appendAndClearStyles() {
	    appendStyles();
	    current_styles.clear();
	}

	// simply output supplied text verbatim
	void append( String text ) {
	    buffer.append( text );
	}

	// construct a heading ('H') tag for supplied outline level
	String makeHeadingTag(int outline_level) {
	    StringBuffer tag = new StringBuffer();

	    tag
		.append("<h")
		.append(outline_level)
		.append(">");

	    return tag.toString();
	}

	// make sure that the current tag is completed by outputting a closing '>', if needed
	// if tag requires completion, also output any accumulated style attribute before
	// completion:
	void completeCurrentTag(bool empty)  {
	    if( !isCurrentTagComplete() ) {
		appendAndClearAttributes();
		appendAndClearStyles();

		if( empty ) {
		    append( " /" );
		}

		// complete the tag with a closing ">":
		append(">");
		markCurrentTagComplete();
	    }
	}

	void completeCurrentTag()  {
	    completeCurrentTag( false );
	}

	// given a naked tag (i.e. just 'tag' with no enclosing '<'/'>' brackets, construct a
	// closing tag '</tag>'
	String makeClosingTag( String naked_tag ) {
	    StringBuffer closing_tag = new StringBuffer("</");
	    closing_tag
		.append( naked_tag )
		.append( '>' );

	    return closing_tag.toString();
	}

	// given a naked tag, 'tag', construct an incomplete tag '<tag', suitible for appending
	// tag attributes (e.g. class="print" to)
	String makeIncompleteOpeningTag( String naked_tag ) {
	    StringBuffer incomplete_tag = new StringBuffer("<");
	    incomplete_tag.append( naked_tag );
	    return incomplete_tag.toString();
	}

	// given a naked tag, 'tag', construct a complete tag '<tag>'
	String makeOpeningTag( String naked_tag ) {
	    StringBuffer opening_tag = new StringBuffer("<");
	    opening_tag
		.append( naked_tag )
		.append( '>' );

	    return opening_tag.toString();
	}

	// given a complete or incomplete opening or closing tag, or an already naked tag
	// construct a naked tag, i.e. '<tag', '<tag>', '<tag class="print">', '</tag>' etc.
	// all result in 'tag':
	String makeNakedTag( String tag ) {
	    // System.err.println( "make naked tag from: '" + tag + "'..." );
	    String naked_tag = tag;

	    // if the tag contains a space, remove any characters including and following
	    // that space
	    int i = tag.indexOf(' ');
	    if( i >= 0 ) {
		naked_tag = naked_tag.substring(0,i);
	    }

	    // if the tag starts with a open angle bracket, remove it:
	    if( naked_tag.charAt(0) == '<' ) {
		naked_tag = naked_tag.substring(1);
	    }

	    // if, having removed any opening bracket, the tag now starts with
	    // a slash (i.e. if it was a </close> tag, remove the slash:
	    if( naked_tag.charAt(0) == '/' ) {
		naked_tag = naked_tag.substring(1);
	    }

	    // if the tag ends in a closing angle bracket, remove it:
	    int last = naked_tag.Length - 1;
	    if( naked_tag.charAt(last) == '>' ) {
		naked_tag = naked_tag.substring(0,last);
	    }

	    return naked_tag;
	}
    }

    class TableBuilder extends Builder {
	void init() {
	    super.init();
	}

	void openRow() {
	    super.openTableRow();
	}

	void closeRow() {
	    super.closeTableRow();
	}

	void openHeading() {
	    super.openTableHeading();
	}

	void closeHeading() {
	    super.closeTableHeading();
	}

	void openCell() {
	    super.openTableCell();
	}

	void closeCell() {
	    super.closeTableCell();
	}

	void cell(String text) {
	    super.tableCell(text);
	}

	void heading(String text) {
	    super.tableHeading(text);
	}       
    }

    /** represents the state of an HTMLOutput object at a particular level of element nesting. HTMLStates are
     * stored on a stack so that previous states can be restored when elements are closed
     */
    class HTMLState extends System.Object {
	/** should HTML output be pretty indented (true) or output with no newlines or whitespace (false)
	 */
	public bool indent;

	/** what tag opened the element at this level of nesting?
	 */
	public String tag;

	public void init( String tag, bool indent ) {
	    this.tag = tag;
	    this.indent = indent;
	}

	public String toString() {
	    return "[tag: " + tag + ", indent: " + indent + "]";
	}
    }
}