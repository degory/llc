#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved


import stream;
import x11;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace Kit {
    class KitException extends System.Exception {
        void init( System.String m ) {
            super.init( m );
	}
    }

    /// Connection to an X server
    class Connection {
	X.Display display;
	EventLoop loop;
	int n;

	void init( System.String d ) {
	    char ptr dc = null;
	    if( d != null ) {
		dc = d.toCString();
	    }
	    display = X.Lib.XOpenDisplay( dc );
	    n = 0;
	    loop = new EventLoop(this);
	}

	EventLoop getLoop() {
	    return loop;
	}
    }

    /// An X Drawable
    class Drawable extends System.Object {
	X.Display display;
	X.Drawable drawable;
	X.XftDraw xft_draw;
	void init() {
	    super.init();
	}
    }

    /// An X Window
    class Window extends Drawable {
	Window parent;
        GC _gc;
	int events;
        
	void init( Connection c, Window parent, int x, int y, int w, int h ) {
	    super.init();
	    // IO.Std.out.println( "Window: x = " + x + ", y = " + y + ", w = " + w + ", h = " + h ); 
	    this.parent = parent;
	    this.display = c.display;
	    X.Window parent_window = null;
	    if( parent == null ) {
		parent_window = X.Lib.XRootWindow( c.display, c.n ); 
	    } else {
		parent_window = cast<X.Window>(parent.drawable);
	    }

	    drawable = cast<X.Drawable>(X.Lib.XCreateSimpleWindow( display, parent_window, x, y, w, h, 0, X.Lib.XWhitePixel(c.display,c.n), X.Lib.XWhitePixel(c.display,c.n) ));
	    xft_draw = X.Lib.XftDrawCreate( c.display, drawable, X.Lib.XDefaultVisual(display,0), X.Lib.XDefaultColormap(display,0) );
            
	    addExposeEvents();

	    c.getLoop().add( this );
	}
        
        GC getGC() {
	    if( _gc == null ) {
		_gc = new GC(this);
	    }
            return _gc;
        }

	void addEvents( int mask ) {
	    events = events | mask;
	    X.Lib.XSelectInput( display, drawable, events );
	}

	void removeEvents( int mask ) {
	    events = (~events) & mask;
	    X.Lib.XSelectInput( display, drawable, events );
	}

	void addExposeEvents() {
	    addEvents( X.Lib.ExposureMask );
	}

	void addButtonEvents() {
	    addEvents( X.Lib.ButtonPressMask | X.Lib.ButtonReleaseMask );
	}

	void addKeyEvents() {
	    addEvents( X.Lib.KeyPressMask );
	}

	void addButtonMotionEvents() {
	    addEvents( X.Lib.ButtonMotionMask );
	}

	void addMotionEvents() {
	    addEvents( X.Lib.PointerMotionMask );
	}

	void addEnterEvents() {
	    addEvents( X.Lib.EnterWindowMask | X.Lib.LeaveWindowMask );
	}

	void show() {
	    X.Lib.XMapWindow( display, cast<X.Window>(drawable) );
	}
        

	void resize( int w, int h ) {
	    int r = X.Lib.XResizeWindow( display, cast<X.Window>(drawable), w, h );
	    // IO.Std.out.println( "resizing " + cast<int>(this) + ": " + w + "," + h + " -> " + r );

	}

	void move( int x, int y ) {
	    int r = X.Lib.XMoveWindow( display, cast<X.Window>(drawable), x, y );
	    // IO.Std.out.println( "moving " + x + "," + y + " -> " + r );
	}

	void event( Event e ) {
	    // IO.Std.out.print( "Event is: " + cast<int>(e.x_event.type) + "\n" );
	    switch( e.x_event.type ) {
	    case X.Event.Expose:
		exposeEvent(e);
	    case X.Event.ButtonPress,X.Event.ButtonRelease:
		buttonEvent(e);
	    case X.Event.EnterNotify,X.Event.LeaveNotify:
		enterEvent(e);
	    case X.Event.MotionNotify:
		motionEvent(e);
	    }
	}
        
        void repaint() {
            // should request a repaint
            paint( getGC() );
        }        
           
        void paint( GC gc ) {
        }

	// override these in your subclass to receive events. 
	// some events will need adding with addEvent
	void exposeEvent( Event e ) {
            repaint();
	}

	void buttonEvent( Event e ) {
	}

	void enterEvent( Event e ) {
	}

	void motionEvent( Event e ) {
	}

	System.String toString() {
	    if( parent != null ) {
		return parent.toString() + "/" + getName();
	    } else {
		return getName();
	    }
	}

	System.String getName() {
	    return "Window";
	}
    }

    /// An Xft Font
    class Font {
	X.Display display;
	X.XftFont font;
	
	void init( X.Display d ) {
	    display = d;
	}

	void set( System.String name ) {
	    font = X.Lib.XftFontOpenName( display, 0, name.toCString() );
	}
    }

    /// An X ColorMap
    class ColorMap {
	X.Display display;
	X.Colormap colormap;

	void init( X.Display d ) {
	    display = d;
	    colormap = X.Lib.XDefaultColormap( d, 0 );
	}

	void parseColor( X.XColor color, char ptr name ) {
	    X.Lib.XParseColor( display, colormap, name, color );
	    X.Lib.XAllocColor( display, colormap, color );
	}

	void parseColor( X.XftColor color, char ptr name ) {
	    X.Lib.XftColorAllocName( display, X.Lib.XDefaultVisual(display,0), colormap, name, color );
	}

	void freeColor( X.XColor color ) {
	}

	void freeColor( X.XftColor color ) {
	}
    }

    /// An Xft Color
    class TextColor {
	ColorMap map;
	X.XftColor xft_color;

	void init( ColorMap m ) {
	    this.map = m;
	    this.xft_color = null;
	}

	void set( System.String name ) {
	    if( xft_color == null ) {
		xft_color = new X.XftColor();
	    } else {
		map.freeColor( xft_color );
	    }
	    map.parseColor( xft_color, name.toCString() );
	}

	X.XftColor getXftColor() {
	    return xft_color;
	}
    }

    /// An X Color
    class Color {
	ColorMap map;
	X.XColor x_color;

	void init( ColorMap m ) {
	    this.map = m;
	    this.x_color = null;
	}

	void set( System.String name ) {
	    if( x_color == null ) {
		x_color = new X.XColor();
	    } else {
		map.freeColor( x_color );
	    }
	    map.parseColor( x_color, name.toCString() );
	}

	X.XColor getXColor() {
	    return x_color;
	}
    }
    
    /// Thrown if a Layout fails
    class LayoutException extends System.Exception {
        Layout layout;
        void init( Layout l, System.String message ) {
            super.init( message );
            layout = l;
        }
    }
    

    /// A Widget that can hold other Widgets
    class Container extends Widget {
	Util.Vector contents;

	void init( Connection c, Window parent, int x, int y, int w, int h ) {
	    super.init( c, parent, x, y, w, h );

	    contents = new Util.Vector();
	}

	void add( Widget w ) {
	    contents.add( w );
	}
    }

    /// Abstract: a Container that can arrange its Widgets
    class Layout extends Container {        
        void init( Connection c, Window parent, int x, int y, int w, int h ) {
            super.init( c, parent, x, y, w, h );
        }
        
        void layout() {
        }
    }

    /// A Layout that arranges Widgets vertically
    class StackLayout extends Layout {
	void init( Connection c, Window parent, int x, int y, int w, int h ) {
	    super.init( c, parent, x, y, w, h );
	}
       
        void layout() {
            Dimension[] da = new Dimension[ contents.length() ];
            int i, h = 0, w = 0;
            
            foreach( Widget e; contents.elements() ) {
                Dimension d = e.getPreferredSize();
		IO.Std.out.println( d );

                da[i] = d;
                h = h + d.h;
                if( d.w > w ) {
                    w = d.w;
                }
                i = i + 1;
            }

	    IO.Std.out.println( "Total size is: " + w + "," + h );

            int spare_w = bounds.w - w;
            if( spare_w < 0 ) { 
                throw new LayoutException( this, this.toString() + ": not enough width: " + w + ">" + bounds.w );
            }
            
            int spare_h = bounds.h - h;
            if( spare_h < 0 ) {
                throw new LayoutException( this, this.toString() + ": not enough height: " + h + ">" + bounds.h  );
            }
            
            spare_w = spare_w / 2;
            
	    int gap_y = spare_h/(da.length + 1);
            h = gap_y;
            i = 0;
            foreach( Widget f; contents.elements() ) {
		f.move( spare_w, h );
                d = da[i];
		f.resize( w, d.h );
                h = h + d.h + gap_y;
                
                i = i + 1;
            } 
        }

	Dimension getMinimumSize() {
	    Dimension result = new Dimension(0,0);
	    foreach( Widget f; contents.elements() ) {
		Dimension d = f.getMinimumSize();
		if( d.w > result.w ) {
		    result.w = d.w;
		}
		result.h = result.h + d.h;
	    }
	    return result;
	}

	Dimension getPreferredSize() {
	    Dimension result = new Dimension(0,0);
	    foreach( Widget f; contents.elements() ) {
		Dimension d = f.getPreferredSize();
		if( d.w > result.w ) {
		    result.w = d.w;
		}
		result.h = result.h + d.h;
	    }
	    return result;
	}
    }

// FIXME: this is exactly analoguous to StackLayout, with x substituted for y and vice versa
// should abstract this somehow

    /// A Layout that arranges its Widgets horizontally
    class ListLayout extends Layout {
        void init( Connection c, Window parent, int x, int y, int w, int h ) {
            super.init( c, parent, x, y, w, h );
        }

        void layout() {
            Dimension[] da = new Dimension[ contents.length() ];
            int i, h = 0, w = 0;

            foreach( Widget e; contents.elements() ) {
                Dimension d = e.getPreferredSize();
		IO.Std.out.println( d );

                da[i] = d;
                w = w + d.w;
                if( d.h > h ) {
                    h = d.h;
                }
                i = i + 1;
            }

	    IO.Std.out.println( "Total size is: " + w + "," + h );

            int spare_w = bounds.w - w;
            if( spare_w < 0 ) { 
                throw new LayoutException( this, "not enough width" );
            }
            
            int spare_h = bounds.h - h;
            if( spare_h < 0 ) {
                throw new LayoutException( this, "not enough height" );
            }
            
            spare_h = spare_h / 2;
            
	    int gap_x = spare_w/(da.length + 1);
            w = gap_x;
            i = 0;
            foreach( Widget f; contents.elements() ) {
                f.move( w, spare_h );
                d = da[i];
                f.resize( d.w, h );
                w = w + d.w + gap_x;
                
                i = i + 1;
            } 
        }


	Dimension getMinimumSize() {
	    Dimension result = new Dimension(0,0);
	    foreach( Widget f; contents.elements() ) {
		Dimension d = f.getMinimumSize();
		if( d.h > result.h ) {
		    result.h = d.h;
		}
		result.w = result.w + d.w;
	    }
	    return result;
	}

	Dimension getPreferredSize() {
	    Dimension result = new Dimension(0,0);
	    foreach( Widget f; contents.elements() ) {
		Dimension d = f.getPreferredSize();
		if( d.h > result.h ) {
		    result.h = d.h;
		}
		result.w = result.w + d.w;
	    }
	    return result;
	}
    }

    /// An X GC (graphics context)
    class GC {
	X.GC gc;
	ColorMap color_map;
	Color color;
	TextColor text_color;
	Font font;
	Drawable drawable;
        
        private const int FULL_CIRCLE = 360 * 64;

	void init( Drawable d ) {
	    this.drawable = d;
	    color_map = new ColorMap( d.display );
            gc = X.Lib.XCreateGC( drawable.display, drawable.drawable, 0, null );
	}

	void setDrawColor( System.String name ) {
	    if( color == null ) {
		color = new Color(color_map);
	    }
	    color.set(name);
	    X.Lib.XSetForeground( drawable.display, gc, color.x_color.pixel );
	}

	void setFont( System.String name ) {
	    if( font == null ) {
		font = new Font( drawable.display );
	    }
	    font.set( name );
	}

	void setTextColor( System.String name ) {
	    if( text_color == null ) {
		text_color = new TextColor(color_map);
	    }
	    text_color.set(name);
	}

	void drawRectangle( int x, int y, int w, int h ) {
	    X.Lib.XDrawRectangle( drawable.display, drawable.drawable, gc, x, y, w, h );
	}

	void fillRectangle( int x, int y, int w, int h ) {
	    X.Lib.XFillRectangle( drawable.display, drawable.drawable, gc, x, y, w, h );
	}
        
        void drawEllipse( int x, int y, int w, int h ) {
            X.Lib.XDrawArc( drawable.display, drawable.drawable, gc, x, y, w, h, 0, FULL_CIRCLE );
        }
        
        void fillEllipse( int x, int y, int w, int h ) {
            X.Lib.XFillArc( drawable.display, drawable.drawable, gc, x, y, w, h, 0, FULL_CIRCLE );
        }        

	void drawText( int x, int y, System.String text ) {
	    X.Lib.XftDrawString8(
				 drawable.xft_draw,
				 text_color.xft_color,
				 font.font,
				 x,
				 y,
				 text.toCString(),
				 text.length() ); 
	}

	Dimension getTextSize( System.String text ) {
	    X.XGlyphInfo extents = new X.XGlyphInfo();
	    X.Lib.XftTextExtents8( drawable.display, font.font, text.toCString(), text.length(), extents );
	    // IO.Std.out.print( "got extents width: " + extents.getWidth() + " height: " + extents.getHeight() + "\n" );
	    return new Dimension( extents.getWidth(), extents.getHeight() );
	}
    }

    /// An X Event
    class Event {
	X.XEvent x_event;
    
	void init( X.XEvent e ) {
	    this.x_event = e;
	}
    }

    /// Application event loop
    class EventLoop {
	X.Display display;
	Util.Vector window_list;

	
	void init( Connection c ) {
	    display = c.display;
	    window_list = new Util.Vector();
	}

	void add( Window w ) {
	    window_list.add( w );
	}

	Event nextEvent() {
	    X.XEvent x_event = new X.XEvent();
	    X.Lib.XNextEvent( display, x_event );
	    return new Event(x_event);
	}

	Window routeEvent( Event e ) {
	    foreach( Window w; window_list.elements() ) {
		if( e.x_event.window == cast<X.Window>(w.drawable) ) {
		    return w;
		}
	    }
	}

	void run() {
	    do {
		Event e = nextEvent();
		Window ew = routeEvent( e );

		if( ew != null ) {
		    ew.event( e );
		}
	    } while( true );
	}
    }

    /// A rectangle with x-y position and width-height dimension
    class Rectangle extends System.Object {
	int x, y, w, h;
	void init( int x, int y, int w, int h ) {
	    super.init();
	    this.x = x;
	    this.y = y;
	    this.w = w;
	    this.h = h;
	    // IO.Std.out.println( "x = " + x + ", y = " + y + ", w = " + w + ", h = " + h ); 
	}

	System.String toString() {
	    return new System.String( "(" + x + "," + y + " " + w + "x" + h + ")" );
	}
    }

    /// A dimension with width and height
    class Dimension extends System.Object {
	int w, h;
	void init( int w, int h ) {
	    super.init();
	    this.w = w;
	    this.h = h;
	}

	System.String toString() {
	    return new System.String( "(" + w + "x" + h + ")" );
	}
    }

    /// A Window that has a minimum and preferred size so it can be arranged by a Layout
    class Widget extends Window {
	Rectangle bounds;
	
        void init( Connection c, Window parent, int x, int y, int w, int h ) {
	    super.init( c, parent, x, y, w, h );
	    bounds = new Rectangle( x, y, w, h );	    
	}

	void resize( int w, int h ) {
	    super.resize( w, h );
	    bounds.w = w;
	    bounds.h = h;
	}

	void move( int x, int y ) {
	    super.move( x, y );
	    bounds.x = x;
	    bounds.y = y;
	}
        
        Dimension getPreferredSize() {
	    IO.Std.out.println( this.toString() + ": getPreferredSize()..." );
            return getMinimumSize();
        }

	Dimension getMinimumSize() {
	    IO.Std.out.println( this.toString() + ": getMinimumSize()..." );
	    return new Dimension( bounds.w, bounds.h );
	}
        
        void setNaturalSize() {
            Dimension d = getPreferredSize();
	    IO.Std.out.println( "setNaturalSize(" + d + ")" );
            resize( d.w, d.h );
        }

	System.String getName() {
	    return "Widget" + bounds;
	}
    }

    /// A Widget that can send actions to an ActionListener
    class ActionWidget extends Widget {
	ActionListener listener;

	void init( Connection c, Window parent, int x, int y, int w, int h ) {
	    super.init( c, parent, x, y, w, h );
	}

	void setListener( ActionListener l ) {
	    // IO.Std.out.println( "setting action listener for " + this );
	    listener = l;
	}

	void action( System.String action ) {
	    if( listener != null ) {
		listener.action( action );
	    }
	}

	System.String getName() {
	    return "ActionWidget" + bounds;
	}
    }

    /// A Widget that implements a simple menu bar
    class MenuBar extends Widget {
	Util.Vector menus;

	void init( Connection c, Window parent, int x, int y, int w, int h ) {
	    super.init( c, parent, x, y, w, h );
	    menus = new Util.Vector();
	}

	void paint( GC gc ) {
	    // gc.setDrawColor( "#F0F0F0" );
	    // gc.fillRectangle( 0, 0, bounds.w, bounds.h );
	}

	void add( Connection c, System.String[] names ) {
	    DropMenu dm = new DropMenu( c, this, 50, 50, 10, 10 );

	    for( int i = 0; i < names.length; i = i + 1 ) {
		dm.add( names[i] );
	    }
 
	    menus.add( dm );
	    // loop.add( dm );
 
	    // IO.Std.out.println( "done adding menu items, showing..." );
	    dm.show();
	    dm.repaint();
	    // childResized();
	}

	void setListener( ActionListener listener ) {
	    foreach( DropMenu dm; menus.elements() ) {
		dm.setListener( listener );
	    }
	}

	void childResized() {
	    // IO.Std.out.println( "child resized" );
	    int running_width = 0;

	    foreach( DropMenu dm; menus.elements() ) {
		// IO.Std.out.println( "moving child to " + (bounds.x + running_width) + "," + bounds.y );
		dm.move( bounds.x + running_width, bounds.y );
		running_width = running_width + dm.getWidth();
	    }
            
	    if( running_width > bounds.w ) {
		// IO.Std.out.println( "resizing to menubar " + running_width );
		resize( running_width, bounds.h );
	    }
	}
        
        Dimension getMinimumSize() {
            Dimension result = new Dimension(0,0);
            foreach( DropMenu dm; menus.elements() ) {
                int h = dm.getTopLineHeight();
                Dimension d = dm.getMinimumSize();
                result.w = result.w + d.w;
                if( h > result.h ) {
                    result.h = h;
                }
            }
            
            return result;
        }

	System.String getName() {
	    return "MenuBar" + bounds;
	}
    }

    /// A Widget that implements a simple drop down menu
    class DropMenu extends ActionWidget {
	Util.Vector list;
	bool is_dropped;
	MenuBar owner;
	int selected ;

	const int
	    MENU_HEIGHT = 30,
	    MENU_Y_OFFSET = 5;

	void init( Connection c, MenuBar owner, int x, int y, int w, int h ) {
	    super.init( c, owner.parent, x, y, w, h );

	    selected = -1;

	    this.owner = owner;
	    // IO.Std.out.println( "created new drop menu" );
	    list = new Util.Vector();
	    addButtonEvents();
	    addMotionEvents();
	    addEnterEvents();
	}

	int hitTest( int y ) {
	    int n = 0;
	    int h = 0;
            GC gc = getGC();
            gc.setFont( "Arial-12" );
            
	    foreach( System.String s; list.elements() ) {
		Dimension d = gc.getTextSize( s );

		if( d.h + 5 < MENU_HEIGHT ) {
		    d.h = MENU_HEIGHT;
		}

		h = h + d.h;

		// IO.Std.out.println( "h is " + h + ", y is " + y );

		if( y < h ) {
		    // IO.Std.out.println( "selecting: " + n );
		    return n;
		}

		n = n + 1;
	    }
	    return -1;
	}
        
        int getTopLineHeight() {
            GC gc = getGC();
            Dimension d = gc.getTextSize( cast<System.String>(list.get(0)) );
            return d.h;
        }
        
        Dimension getMinimumSize() {
            Dimension result = new Dimension(0,0);
            GC gc = getGC();
            gc.setFont( "Arial-12" );
            foreach( System.String s; list.elements() ) {
                
		Dimension d = gc.getTextSize( s );
		d.w = d.w + 20;

		if( d.h + 5 < MENU_HEIGHT ) {
		    d.h = MENU_HEIGHT;
		}

		if( d.w > result.w ) {
		    result.w = d.w;		 
		}

		result.h = result.h + d.h;
            }
        }

	void paint( GC gc ) {
	    bool resize = false;
	    // IO.Std.out.println( "DropMenu: painting..." );
	    Dimension t = new Dimension(0,0);
	    gc.setFont( "Arial-12" );
	    gc.setDrawColor( "#F0F0F0" );
	    gc.fillRectangle( 0, 0, bounds.w, bounds.h );
	    gc.setTextColor( "#000000" );
	    gc.setDrawColor( "#808080" );

	    int n = 0;
	    foreach( System.String s; list.elements() ) {
		Dimension d = gc.getTextSize( s );
		d.w = d.w + 20;

		if( d.h + 5 < MENU_HEIGHT ) {
		    d.h = MENU_HEIGHT;
		}

		if( d.w > t.w ) {
		    t.w = d.w;		 
		}

		if( n == selected ) {
		    gc.fillRectangle( 0, t.h, bounds.w, d.h );
		}

		gc.drawText( 10, t.h + d.h - MENU_Y_OFFSET, s );

		t.h = t.h + d.h;

		if( !is_dropped ) {
		    break;
		}

		n = n + 1;
	    }

	    if( t.w > bounds.w || t.h > bounds.h ) {
		// IO.Std.out.println( "resizing to " + t.w + "," + t.h );
		resize( t.w, t.h );
		owner.childResized();
	    }
	}

	int getWidth() {
	    // IO.Std.out.println( "width requested, returning " + bounds.w );
	    return bounds.w;
	}

	void add( System.String s ) {
	    // IO.Std.out.println( "added menu item " + s );
	    list.add( s );
	}

	void cancelDrop() {
	    is_dropped = false;
	    bounds.h = 0;
	    selected = -1;
	}


	void enterEvent( Event e ) {
	    if( e.x_event.type == X.Event.EnterNotify ) {
		is_dropped = true;
	    } else if( e.x_event.type == X.Event.LeaveNotify ) {
		cancelDrop();
	    }
	    repaint();
	}

	void buttonEvent( Event e ) {
	    // IO.Std.out.println( "got button event in DropMenu, selected is " + selected );
	    if( e.x_event.type != X.Event.ButtonPress ) {
		System.String action = null;
		if( selected >= 0 ) {
		    action = cast<System.String>(list.get(selected));
		    // IO.Std.out.println( "action is '" + action + "'" );
		}
		if( action != null ) {
		    action( action );
		}
		cancelDrop();
		repaint();

	    }
	}

	void motionEvent( Event e ) {
	    X.XMotionEvent xme = cast<X.XMotionEvent>(e.x_event);

	    // IO.Std.out.println( "motion event in drop menu, y coord is " + xme.y );
	    
	    int n = hitTest( xme.y );
	    if( n != selected && n > 0 ) {
		// IO.Std.out.println( "motion event in drop menu, selection now " + n );
		selected = n;
		repaint();
	    }
	}

	System.String getName() {
	    return "DropMenu" + bounds;
	}
    }

    /// A Layout that arranges a group of RadioButtons
    class RadioGroup extends StackLayout {
        void init( Connection c, Window parent, int x, int y, int w, int h ) {
            super.init( c, parent, x, y, w, h );
        }
        
        void add( RadioButton b ) {
	    IO.Std.out.println( "RadioGroup add: " + b );
            super.add( b );
            b.setOwner( this );
        }
        
        void setSelected( RadioButton selected ) {
            foreach( RadioButton b; contents.elements() ) {
                b.setSelected( b == selected );
            }
        }

	void layout() {
	    IO.Std.out.println( "RadioGroup.layout..." );
	    super.layout();
	}

	void paint( GC gc ) {
	    gc.setDrawColor( "#808080" );
	    gc.drawRectangle( 0, 0, bounds.w-1, bounds.h-1 );
	}
    }
    
    /// Abstract: a Widget that can be in either selected or not-selected states
    class SelectableButton extends Widget {
        const int
            RING_SIZE = 15,
            BLOB_SIZE = 11;
    
        System.String text;
        bool selected;
        
        void init( Connection c, Window parent, int x, int y, int w, int h, System.String text ) {
            super.init( c, parent, x, y, w, h );
            this.text = text;
            addButtonEvents();
        }

	void drawBlob( GC gc ) {
	    throw new System.NotImplementedException( "SelectableButton is abstract" );
	}
        
        void paint( GC gc ) {
            gc.setTextColor( "#000000" );
            gc.setFont( "Arial-12" );

            Dimension d = gc.getTextSize( text );
            gc.setDrawColor( "#F0F0F0" );
            gc.fillRectangle( 0, 0, bounds.w, bounds.h );

            gc.setDrawColor( "#808080" );

            drawBlob( gc );
            int or = (bounds.h + d.h) / 2;
                      
            gc.drawText( 30, or, text );                 
        }        

	Dimension getMinimumSize() {
	    GC gc = getGC();
	    gc.setFont( "Arial-12" );
	    Dimension d = gc.getTextSize( text );
	    d.w = d.w + RING_SIZE + 30;
	    d.h = d.h + RING_SIZE;
	    if( bounds.w > d.w ) {
		d.w = bounds.w;
	    }
	    if( bounds.h > d.h ) {
		d.h = bounds.h;
	    }
	    return d;
	}
        
        void setSelected( bool s ) {
            bool was_selected = selected;
            selected = s;
            if( selected != was_selected ) {
                repaint();
            }                        
        }

	System.String getName() {
	    return "SelectableButton " + text + " " + bounds;
	}
    }

    /// A check box Widget
    class CheckBox extends SelectableButton {
	RadioGroup owner;

        void init( Connection c, Window parent, int x, int y, int w, int h, System.String text ) {
            super.init( c, parent, x, y, w, h, text );
        }
        
        void setOwner( RadioGroup o ) {
            this.owner = o;
        }
    

        void drawBlob( GC gc ) {
            int or = (bounds.h - RING_SIZE) / 2;

            gc.drawRectangle( or, or, RING_SIZE, RING_SIZE );
            if( selected ) {
                or = (bounds.h - BLOB_SIZE) / 2 + 1;
                gc.fillRectangle( or, or, BLOB_SIZE-1, BLOB_SIZE-1 );
            }             
        }        

        void buttonEvent( Event e ) {
	    if( e.x_event.type == X.Event.ButtonPress ) {
                setSelected( !selected );
	    }
        }

	System.String getName() {
	    return "CheckBox " + text + " " + bounds;
	}   
    }

    /// A radio button Widget
    class RadioButton extends SelectableButton {
        RadioGroup owner;
        
        void init( Connection c, Window parent, int x, int y, int w, int h, System.String text ) {
            super.init( c, parent, x, y, w, h, text );
        }
        
        void setOwner( RadioGroup o ) {
            this.owner = o;
        }
    
        void drawBlob( GC gc ) {
            int or = (bounds.h - RING_SIZE) / 2;

            gc.drawEllipse( or, or, RING_SIZE, RING_SIZE );
            if( selected ) {
                or = (bounds.h - BLOB_SIZE) / 2;
                gc.fillEllipse( or, or, BLOB_SIZE, BLOB_SIZE );
            }             
        }        

        void buttonEvent( Event e ) {
	    if( e.x_event.type == X.Event.ButtonPress ) {
                owner.setSelected( this );
	    }
        }   

	System.String getName() {
	    return "RadioButton " + text + " " + bounds;
	}
    }

    /// Possible orientations for a ScrollBar
    enum Orientation {
	Vertical, Horizontal
    }

    /// A scroll bar Widget
    class ScrollBar extends Widget {
	Orientation orientation;

	bool in_drag;
	int anchor;
        int op;

	int position;
	int size;

	int tp;
	int ts;

	void init( Connection c, Window parent, int x, int y, int w, int h ) {
	    super.init( c, parent, x, y, w, h );

	    position = 0;
	    size = 2;
	    addButtonEvents();
	    addMotionEvents();
	    addButtonMotionEvents();
	}

	void setOrientation( Orientation o ) {
	    orientation = o;
	}

	void paint( GC gc ) {
	    gc.setDrawColor( "#F0F0F0" );
	    gc.fillRectangle( 0, 0, bounds.w-1, bounds.h-1 );

	    gc.setDrawColor( "#808080" );
	    gc.drawRectangle( 0, 0, bounds.w-1, bounds.h-1 );

	    int length, bredth;
	    if( orientation == Orientation.Vertical ) {
		length = bounds.h;
		bredth = bounds.w;
		gc.drawRectangle( 0, 0, bounds.w-1, bounds.w-1 ); 		// draw top end
		gc.drawRectangle( 0, bounds.h - bounds.w, bounds.w-1, bounds.w-1 ); 		// draw bottom end
	    } else {
		length = bounds.w;
		bredth = bounds.h;
		gc.drawRectangle( 0, 0, bounds.h-1, bounds.h-1 );
		gc.drawRectangle( 0, bounds.w - bounds.h, bounds.h-1, bounds.h-1 );
	    }

	    length = length - bredth * 2;

	    if( length <= 0 ) {
		throw new System.Exception( this.toString() + ": too short for bubble" );
	    }

	    

	    tp = position;
	    ts = size;

	    if( ts < bredth ) {
		ts = bredth;
	    }

	    if( ts > length ) {
		ts = length;
	    }

	    if( tp + ts > length ) {
		tp = length - ts;
	    }

	    if( tp < 0 ) {
		tp = 0;
	    }
            
            tp = tp + bredth;

	    if( inDrag() ) {
		if( orientation == Orientation.Vertical ) {
		    gc.fillRectangle( 0, tp, bounds.w-1, ts );
		} else {
		    gc.fillRectangle( tp, 0, ts, bounds.h-1 );
		}
	    } else {
		if( orientation == Orientation.Vertical ) {
		    gc.drawRectangle( 0, tp, bounds.w-1, ts );
		} else {
		    gc.drawRectangle( tp, 0, ts, bounds.h-1 );
		}
	    }
	}

	bool inDrag() {
	    return in_drag;
	}

	void endDrag() {
	    in_drag = false;
	}

	bool inBubble( int x, int y ) {
	    if( orientation == Orientation.Vertical ) {
		return y >= tp && y <= tp + ts;
	    } else {
		return x >= tp && x <= tp + ts;
	    }
	}

	bool inButton( int x, int y ) {
	    if( orientation == Orientation.Vertical ) {
		return y <= bounds.w || y >= bounds.h - bounds.w;
	    } else {
		return x >= bounds.h || x <= bounds.x - bounds.h;
	    }	    
	}

	void startDrag( int x, int y ) {
	    in_drag = true;
            op = position;
	    if( orientation == Orientation.Vertical ) {
		anchor = y;
		IO.Std.out.println( "startDrag: y=" + y + ", tp=" + tp + " -> anchor=" + anchor );
	    } else {
		anchor = y;
	    }	    

	}

	void lineScroll( int x, int y ) {
	    if( orientation == Orientation.Vertical ) {
		if( y <= bounds.w ) {
		    position = position - 1;
		} else if( y >= bounds.h - bounds.w ) {
		    position = position + 1;
		}
	    } else {
		if( x <= bounds.h ) {
		    position = position - 1;
		} else if( x >= bounds.w - bounds.h ) {
		    position = position + 1;
		}
	    }	    
	}

	void pageScroll( int x, int y ) {
	    int p;
	    if( orientation == Orientation.Vertical ) {
		p = y;
	    } else {
		p = x;
	    }

	    if( p <= tp ) {
		position = position - 10;
	    } else if( p >= tp + ts ) {
		position = position + 10;
	    }
	}

	void dragScroll( int x, int y ) {
	    int delta;
	    if( orientation == Orientation.Vertical ) {
	        position = op + (y - anchor);
		IO.Std.out.println( "anchor = " + anchor + ", click = " + y + ", position = " + position );
	    } else {
		position = op + (x - anchor);		
	    }

	    // IO.Std.out.println( "position: " + position + " -> " + (position + delta) );
	    // position = position + delta;
	}

	void buttonEvent( Event e ) {
	    if( e.x_event.type == X.Event.ButtonPress ) {
		X.XButtonEvent xbe = cast<X.XButtonEvent>(e.x_event);
		if( inBubble( xbe.x, xbe.y ) ) {
		    startDrag( xbe.x, xbe.y );
		} else if( inButton( xbe.x, xbe.y ) ) {
		    lineScroll( xbe.x, xbe.y );
		} else {
		    pageScroll( xbe.x, xbe.y );
		}
		repaint();
	    } else {
		endDrag();
		repaint();
	    }

	}


	void motionEvent( Event e ) {
	    X.XMotionEvent xme = cast<X.XMotionEvent>(e.x_event);
	    if( inDrag() ) {
		dragScroll( xme.x, xme.y );
		repaint();
	    }
	}

	System.String getName() {
	    return "ScrollBar" + bounds;
	}
    }

    /// Extend this to be able to receive action events
    class ActionListener extends System.Object {
	void action( System.String action ) {
	}
    }

    /// A button Widget
    class Button extends ActionWidget {
	bool pressed;
	System.String text;
	System.String action;

	void init( Connection c, Window parent, int x, int y, int w, int h, System.String text, System.String action ) {
	    super.init( c, parent, x, y, w, h );
	    // IO.Std.out.println( "Button: x = " + x + ", y = " + y + ", w = " + w + ", h = " + h ); 
	    this.text = text;
	    this.action = action;
	    
            addButtonEvents();
	}
        
        Dimension getMinimumSize() {
	    IO.Std.out.println( this.toString() + ": getPreferredSize()..." );
            GC gc = getGC();
            gc.setFont( "Arial-12" );
            Dimension d = gc.getTextSize( text );
            d.w = d.w + 20;
            d.h = d.h + 10;
            
            return d;
        }

	Dimension getPreferredSize() {
	    IO.Std.out.println( this.toString() + ": getMinimumSize()..." );
	    Dimension d = getMinimumSize();
	    d.w = d.w + 15;
	    d.h = d.h + 8;
	    return d;
	}

	void paint( GC gc ) {
	    gc.setFont( "Arial-12" );
	    Dimension d = gc.getTextSize( text );
	    // IO.Std.out.print( "b.h = " + bounds.h + ", d.h = " + d.h + "\n" );
	    int tx = (bounds.w - d.w)/2;
	    int ty = bounds.h/2 + d.h/2;

	    gc.setDrawColor( "#808080" );
	    gc.fillRectangle( 0, 0, bounds.w-1, bounds.h-1 );
	    if( pressed ) {
		gc.setDrawColor( "#F0F0F0" );
		gc.fillRectangle( 2, 2, bounds.w-5, bounds.h-5 );
		gc.setDrawColor( "#808080" );
		gc.setTextColor( "#808080" );
	    } else {
		gc.setDrawColor( "#A0A0A0" );
		gc.fillRectangle( 2, 2, bounds.w-5, bounds.h-5 );
		gc.setDrawColor( "#000000" );
		gc.setTextColor( "#000000" );
	    }
	    gc.drawRectangle( 1, 1, bounds.w-3, bounds.h-3 );
	    gc.drawText( tx, ty, text );
	}

	void buttonEvent( Event e ) {
	    if( e.x_event.type == X.Event.ButtonPress ) {
		pressed = true;
	    } else {
		pressed = false;
	    }
	    repaint();
	    if( !pressed ) {
		action( action );
	    }
	}

	System.String getName() {
	    return "Button " + text + " " + bounds;
	}
    }

    /// A label Widget
    class Label extends Widget {
	System.String text;

	void init( Connection c, Window parent, int x, int y, int w, int h, System.String text ) {
	    super.init( c, parent, x, y, w, h );
	    this.text = text;
	}

	void setText( System.String text ) {
	    this.text = text;
	    repaint();
	}
        
        Dimension getMinimumSize() {
	    IO.Std.out.println( this.toString() + ": getMinimumSize()..." );
            GC gc = getGC();
	    gc.setFont( "Arial-12" );            
            Dimension d = gc.getTextSize( text );
            d.w = d.w + 20;
            d.h = d.h + 10;
            
            return d;
        }

	void paint( GC gc ) {
	    gc.setFont( "Arial-12" );
	    Dimension d = gc.getTextSize( text );
	    int tx = (bounds.w - d.w)/2;
	    int ty = (bounds.h + d.h)/2;

	    gc.setDrawColor( "#F0F0F0" );
	    gc.fillRectangle( 0, 0, bounds.w, bounds.h );
	    gc.setDrawColor( "#000000" );
	    gc.setTextColor( "#000000" );
	    gc.drawText( tx, ty, text );
	}

	System.String getName() {
	    return "Label " + text + " " + bounds;
	}
    }
}
