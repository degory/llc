pragma NoMarkUnsafe, NoWarnUnsafe;

namespace Util {
    class Time extends System.Object {
        int seconds; // time in UNIX epoch

	void init( int seconds ) {
	    this.seconds = seconds;
	}

	void init() {
	    init( NowInSeconds );
	}

	static get Time Now {
	    return new Time();
	}

	get int Seconds {
	    return seconds;
	}

	int toInt() {
	    return seconds;
	}

	static get int NowInSeconds {
	    return cast int(native.__get_time());
	}

	Time opAdd( int seconds ) {
	    return new Time( this.seconds + seconds );
	}

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