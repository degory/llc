#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved


import stream;
pragma NoWarnUnsafe, NoMarkUnsafe;

import "-L/usr/X11R6/lib";
import "-lX11";
import "-lXft";

namespace X {
    enum XID { }   // opaque handle
    enum XPointer { }

    enum Atom {
    }

    struct Display {
    }

    struct Screen {
    }

    struct Visual {
    }

    struct Window {
    }

    struct Drawable {
    }



    enum Event {	
	KeyPress = 2,
	KeyRelease = 3,
	ButtonPress = 4,
	ButtonRelease =  5,
	MotionNotify = 6,
	EnterNotify = 7,
	LeaveNotify = 8,
	FocusIn = 9,
	FocusOut = 10,
	KeymapNotify = 11,
	Expose = 12,
	GraphicsExpose = 13,
	NoExpose = 14,
	VisibilityNotify = 15,
	CreateNotify = 16,
	DestroyNotify = 17,
	UnmapNotify = 18,
	MapNotify = 19,
	MapRequest = 20,
	ReparentNotify = 21,
	ConfigureNotify = 22,
	ConfigureRequest = 23,
	GravityNotify = 24,
	ResizeRequest = 25,
	CirculateNotify = 26,
	CirculateRequest = 27,
	PropertyNotify = 28,
	SelectionClear = 29,
	SelectionRequest = 30,
	SelectionNotify = 31,
	ColormapNotify = 32,
	ClientMessage = 33,
	MappingNotify = 34,
	LASTEvent = 35
    }

    struct XGlyphInfo {
	int width_height; // packed shorts
	int x_y; // packed shorts
	int xoff_yoff; // packed shorts
	void init() {
	}

	int getWidth() {
	    return width_height & 0xffff;
	}

	int getHeight() {
	    return (width_height & 0xffff0000) >> 16;
	}
    }
    
    struct XEvent {
	// eoooh this is ugly. union, 25 4-bytes long. first 4-byte is type
	Event type;
	int serial;
	bool send_event;
	Display display;
	Window window;
	int p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24;
	void init() {
	}
    }

    struct XKeyEvent {
        int type;               /* of event */
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;          /* "event" window it is reported relative to */
        Window root;            /* root window that the event occurred on */
        Window subwindow;       /* child window */
        int time;              /* milliseconds */
        int x, y;               /* pointer x, y coordinates in event window */
        int x_root, y_root;     /* coordinates relative to root */
        int state;     /* key or button mask */
        int keycode;   /* detail */
        bool same_screen;       /* same screen flag */
    }

    struct XButtonEvent {
        int type;               /* of event */
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;          /* "event" window it is reported relative to */
        Window root;            /* root window that the event occurred on */
        Window subwindow;       /* child window */
        int time;              /* milliseconds */
        int x, y;               /* pointer x, y coordinates in event window */
        int x_root, y_root;     /* coordinates relative to root */
        int state;     /* key or button mask */
        int button;    /* detail */
        bool same_screen;       /* same screen flag */
    }

    struct XMotionEvent {
        int type;               /* of event */
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;          /* "event" window reported relative to */
        Window root;            /* root window that the event occurred on */
        Window subwindow;       /* child window */
        int time;              /* milliseconds */
        int x, y;               /* pointer x, y coordinates in event window */
        int x_root, y_root;     /* coordinates relative to root */
        int state;     /* key or button mask */
        char is_hint;           /* detail */
        bool same_screen;       /* same screen flag */
    }

    struct XCrossingEvent {
        int type;               /* of event */
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;          /* "event" window reported relative to */
        Window root;            /* root window that the event occurred on */
        Window subwindow;       /* child window */
        int time;              /* milliseconds */
        int x, y;               /* pointer x, y coordinates in event window */
        int x_root, y_root;     /* coordinates relative to root */
        int mode;               /* NotifyNormal, NotifyGrab, NotifyUngrab */
        int detail;
        bool same_screen;       /* same screen flag */
        bool focus;             /* boolean focus */
        int state;     /* key or button mask */
    }

    struct XFocusChangeEvent {
        int type;               /* FocusIn or FocusOut */
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;          /* window of event */
        int mode;               /* NotifyNormal, NotifyGrab, NotifyUngrab */
        int detail;
        /*
         * NotifyAncestor, NotifyVirtual, NotifyInferior,
         * NotifyNonlinear,NotifyNonlinearVirtual, NotifyPointer,
         * NotifyPointerRoot, NotifyDetailNone
         */
    }

    /* generated on EnterWindow and FocusIn  when KeyMapState selected */
    struct XKeymapEvent {
        int type;     // 4
        int serial;   // 8
        bool send_event; // 12
        Display display; // 16    
        Window window; // 20
        // char key_vector[32]; // 24
	char getKey(int i) {
	    char ptr p = cast<char ptr>(this) + 24;
	    return [p + i];
	}
    }

    struct XExposeEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;
        int x, y;
        int width, height;
        int count;              /* if non-zero, at least this many more */
    }


    struct XGraphicsExposeEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Drawable drawable;
        int x, y;
        int width, height;
        int count;              /* if non-zero, at least this many more */
        int major_code;         /* core is CopyArea or CopyPlane */
        int minor_code;         /* not defined in the core */
    }

    struct XNoExposeEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Drawable drawable;
        int major_code;         /* core is CopyArea or CopyPlane */
        int minor_code;         /* not defined in the core */
    }

    struct XVisibilityEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;
        int state;              /* Visibility state */
    }
   
    struct XCreateWindowEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window parent;          /* parent of the window */
        Window window;          /* window id of window created */
        int x, y;               /* window location */
        int width, height;      /* size of window */
        int border_width;       /* border width */
        bool override_redirect; /* creation should be overridden */
    }

    struct XDestroyWindowEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window event;
        Window window;
    }

    struct XUnmapEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window event;
        Window window;
        bool from_configure;
    }


    struct XMapEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window event;
        Window window;
        bool override_redirect; /* boolean, is override set... */
    }

    struct XMapRequestEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window parent;
        Window window;
    }

    struct XReparentEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window event;
        Window window;
        Window parent;
        int x, y;
        bool override_redirect;
    }
    
    struct XConfigureEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window event;
        Window window;
        int x, y;
        int width, height;
        int border_width;
        Window above;
        bool override_redirect;
    }

    struct XGravityEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window event;
        Window window;
        int x, y;
    }

    struct XResizeRequestEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;
        int width, height;
    }

    struct XConfigureRequestEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window parent;
        Window window;
        int x, y;
        int width, height;
        int border_width;
        Window above;
        int detail;             /* Above, Below, TopIf, BottomIf, Opposite */
        int value_mask;
    }

    struct XCirculateEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window event;
        Window window;
        int place;              /* PlaceOnTop, PlaceOnBottom */
    }

    struct XCirculateRequestEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window parent;
        Window window;
        int place;              /* PlaceOnTop, PlaceOnBottom */
    } 

    struct XPropertyEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;
        Atom atom;
        int time;
        int state;              /* NewValue, Deleted */
    }

    struct XSelectionClearEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;
        Atom selection;
        int time;
    }

    struct XSelectionRequestEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window owner;
        Window requestor;
        Atom selection;
        Atom target;
        Atom property;
        int time;
    }

    struct XSelectionEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window requestor;
        Atom selection;
        Atom target;
        Atom property;          /* ATOM or None */
        int time;
    }

    struct XColormapEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;
        Colormap colormap;      /* COLORMAP or None */
        bool is_new;             /* C++ */
        int state;              /* ColormapInstalled, ColormapUninstalled */
    }


    struct XClientMessageEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;
        Atom message_type;
        int format;
	int l0,l1,l2,l3,l4;
    }

    struct XMappingEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;       /* Display the event was read from */
        Window window;          /* unused */
        int request;            /* one of MappingModifier, MappingKeyboard,
                                   MappingPointer */
        int first_keycode;      /* first keycode */
        int count;              /* defines range of change w. first_keycode*/
    } 

    struct XErrorEvent {
        int type;
        Display display;       /* Display the event was read from */
        XID resourceid;         /* resource id */
        int serial;   /* serial number of failed request */
	int error_code;
        // unsigned char error_code;       /* error code of failed request */
        // unsigned char request_code;     /* Major op-code of failed request */
        // unsigned char minor_code;       /* Minor op-code of failed request */
    }

    struct XAnyEvent {
        int type;
        int serial;   /* # of last request processed by server */
        bool send_event;        /* true if this came from a SendEvent request */
        Display display;/* Display the event was read from */
        Window window;  /* window on which event was requested in event mask */
    }

    struct GC {
    }

    struct XColor {
	int pixel;
	int data1;  // red, green
	int data2;  // blue, flags, pad
	void init() {
	}

	int ptr getPixelAddress() {
	    return cast<int ptr>(this);
	}
    }

    struct Colormap {
    }

    struct XGCValues {
    }

    struct Cursor {
    }

    enum Status {
	
    }

    struct XftFont {
    }

    struct XftDraw {
    }
	
    struct XRenderColor {
	int red_green;
	int blue_alpha;

	void init( int red, int green, int blue, int alpha ) {
	    this.red_green = red << 16 | green;
	    this.blue_alpha = blue << 16 | alpha;
	}

	void init() {
        }
    }

    struct XftColor {
	int pixel;
	int red_green;
	int blue_alpha;

	void init( int red, int green, int blue, int alpha ) {
	    this.red_green = red << 16 | green;
	    this.blue_alpha = blue << 16 | alpha;
	    
	    // x | r | g | b |
	    // 
	    
	    pixel = ((red & 0xFF00) << 8) | ((blue & 0xFF00)) | ((green & 0xFF00) >> 8);
	}

	void init() {
        }

	XRenderColor getXRenderColor() {
	    return cast<XRenderColor>(1 + cast<int ptr>(this));
	}
    }

    struct XSetWindowAttributes {
	void ptr background_pixmap;/* background, None, or ParentRelative */
	int background_pixel;    /* background pixel */
	void ptr border_pixmap;    /* border of the window or CopyFromParent */
	int border_pixel;/* border pixel value */
	int bit_gravity;         /* one of bit gravity values */
	int win_gravity;         /* one of the window gravity values */
	int backing_store;       /* NotUseful, WhenMapped, Always */
	int backing_planes;/* planes to be preserved if possible */
	int backing_pixel;/* value to use in restoring planes */
	bool save_under;         /* should bits under be saved? (popups) */
	int event_mask;         /* set of events that should be saved */
	int do_not_propagate_mask;/* set of events that should not propagate */
	bool override_redirect;  /* boolean value for override_redirect */
	Colormap colormap;       /* color map to be associated with window */
	Cursor cursor;           /* cursor to be displayed (or None) */
    }

    class Lib {
	const int 
	    KeyPressMask = (1<<0),
	    KeyReleaseMask = (1<<1),
	    ButtonPressMask = (1<<2),
	    ButtonReleaseMask               = (1<<3),
	    EnterWindowMask                 = (1<<4),
	    LeaveWindowMask                 = (1<<5),
	    PointerMotionMask               = (1<<6),
	    PointerMotionHintMask           = (1<<7),
	    Button1MotionMask               = (1<<8),
	    Button2MotionMask               = (1<<9),
	    Button3MotionMask               = (1<<10),
	    Button4MotionMask               = (1<<11),
	    Button5MotionMask               = (1<<12),
	    ButtonMotionMask                = (1<<13),
	    KeymapStateMask                 = (1<<14),
	    ExposureMask                    = (1<<15),
	    VisibilityChangeMask            = (1<<16),
	    StructureNotifyMask             = (1<<17),
	    ResizeRedirectMask              = (1<<18),
	    SubstructureNotifyMask          = (1<<19),
	    SubstructureRedirectMask        = (1<<20),
	    FocusChangeMask                 = (1<<21),
	    PropertyChangeMask              = (1<<22),
	    ColormapChangeMask              = (1<<23),
	    OwnerGrabButtonMask             = (1<<24);


	static native Display XOpenDisplay(char ptr name);
	static native Screen XScreenOfDisplay( Display dis );
	static native Window XCreateSimpleWindow( Display d, Window parent, int x, int y, int w, int h, int bw, int border, int background );
	static native Window XCreateWindow( Display d, Window parent, int x, int y, int w, int h, int bw, int depth, int klass, Visual visual, int value_mask, XSetWindowAttributes attributes );
	static native Window XRootWindow( Display d, int n );
	static native int XBlackPixel( Display d, int n );
	static native int XWhitePixel( Display d, int n );
	static native int XMapWindow( Display d, Window w );
	static native int XResizeWindow( Display d, Window w, int width, int height );
	static native int XMoveWindow( Display d, Window w, int x, int y );
	static native Colormap XDefaultColormap( Display d, int n );
	static native GC XCreateGC( Display dis, Drawable d, int mask, XGCValues ptr values );
	static native Status XFreeGC( Display dis, GC gc );
	static native Status XParseColor( Display dis, Colormap cm, char ptr c, XColor result );
	static native Status XAllocColor( Display dis, Colormap cm, XColor color );
	static native Status XSetForeground( Display dis, GC gc, int color );
	static native Status XSelectInput( Display dis, Drawable d, int mask );
	static native Status XDrawRectangle( Display dis, Drawable d, GC gc, int x, int y, int width, int height ); 
	static native Status XFillRectangle( Display dis, Drawable d, GC gc, int x, int y, int width, int height ); 
        static native Status XDrawArc( Display dis, Drawable d, GC gc, int x, int y, int width, int height, int angle1, int angle2);
        static native Status XFillArc( Display dis, Drawable d, GC gc, int x, int y, int width, int height, int angle1, int angle2);
	static native Status XFlush( Display dis );
	static native Status XNextEvent( Display dis, XEvent evt );
	static native Visual XDefaultVisual( Display dis, int n );
	static native void XftTextExtents8( Display dis, XftFont font, char ptr string, int len, XGlyphInfo extents );
	static native XftFont XftFontOpenName( Display dis, int n, char ptr name );
	static native XftDraw XftDrawCreate( Display dis, Drawable d, Visual v, Colormap cm );
	static native bool XftColorAllocName( Display  dis, Visual visual, Colormap cmap, char ptr name, XftColor result);
	static native bool XftColorAllocValue( Display dpy, Visual visual, Colormap cmap, XRenderColor color, XftColor result);
	static native bool XftColorFree( Display dis, Visual visual, Colormap cmap, XftColor color);
	static native bool XftDrawString8( XftDraw draw, XftColor color, XftFont font, int x, int y, char ptr s, int len); 
    }
}

