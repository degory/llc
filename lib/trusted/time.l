#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

pragma NoMarkUnsafe, NoWarnUnsafe;

namespace Util {
    /// Holds a number of seconds and can format it as a human readable string
    class Time extends System.Object {
        int seconds; // time in UNIX epoch

	/// Construct a new time representing a given number of seconds
	void init( int seconds ) {
	    this.seconds = seconds;
	}

	/// Construct a new time representing now in seconds into the UNIX epoch
	void init() {
	    init( NowInSeconds );
	}

	/// Return a new time representing now in seconds into the UNIX epoch
	static get Time Now {
	    return new Time();
	}

	/// Get the seconds value for this Time
	get int Seconds {
	    return seconds;
	}
	
	int toInt() {
	    return seconds;
	}

	/// Get the current time as seconds into the UNIX epoch
	static get int NowInSeconds {
	    return cast int(native.__get_time());
	}

	/// Return a new time that represents this Time plus the given number of seconds
	Time opAdd( int seconds ) {
	    return new Time( this.seconds + seconds );
	}

	/// Return a new time that represents this Time minus the given number of seconds
	Time opSub( int seconds ) {
	    return new Time( this.seconds - seconds );
	}	

	System.String toString() {
	    System.StringBuffer result = new System.StringBuffer();

	    int seconds = this.seconds;

	    if( seconds < 0 ) {
		result.append( '-' );
		seconds = -seconds;
	    }

	    int width = 0;
	    int minutes = seconds / 60;
	    int hours = minutes / 60;
	    int days = hours / 24;

	    if( days > 0 ) {
		int fraction = 0;
		if( minutes != 0 ) {
		    minutes = minutes % 1440;
		    fraction =  100 * minutes / 1440;
		    if( fraction > 99 ) {
			fraction = 99;
		    }
		}

		result.append( days );
		result.append( '.' );
		result.append( fraction, 10, 2, '0' );
		result.append( " d" );
		return result;
	    }


	    seconds = seconds % 60;

	    bool want_seconds = true;

	    System.String suffix = " s";

	    if( minutes > 0 ) {
		minutes = minutes % 60;
		suffix = " m";
		if( hours > 0 ) {
		    result.append( hours );
		    result.append( ':' );
		    width = 2;
		    want_seconds = false;
		    
		    suffix = " h";
		}

		result.append( minutes, 10, width, '0' );
		if( hours == 0 ) {
		    result.append( ':' );
		}
		width = 2;
	    }

	    if( hours == 0 ) {
		result.append( seconds, 10, width, '0' );
	    }

	    result.append( suffix );

	    return result;
	}       
    }
}