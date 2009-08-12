// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import generic;

pragma NoWarnUnsafe;

namespace Gen {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;

    class MBitSet extends Object {
        public int size;
        public int original_size;
        word[] bits;
        bool changed;

	// for iterator:
	int current_index;  // current bit number
	word current_bits;  // bits for current word
	int ai;             // index of current word within bits array
	word bi;            // mask of current bit within current word
	int next_result;

	static int largest;
    
        void init() {
            init( TempFactory.CurrentTemp );
        }

        static int calcStorageSize( int size ) {
            return (size + System.Environment.WORD_BITS) >> System.Environment.WORD_SHIFT;
        }

        void init( int size ) {
            super.init();
            original_size = size;
            this.size = calcStorageSize( size );

	    if( this.size > largest ) {
		IO.Std.err.println( "largest bitset yet: " + (this.size * Machine.WORD) + " bytes" );
		largest = this.size;
	    }

            // IO.Std.err.println( "size + 31 = " + (size + 31) + ", >> 5 = " + ((size + 31) >> 5) );
            // IO.Std.err.println( "number of integers allocated: " + this.size );
            bits = new word[this.size];
            changed = false;
            // IO.Std.err.println( "MBitSet: address: " + cast<int>(this) + ", size: " + original_size + " (approx " + (this.getSize() + this.size*4) + " bytes)" );

        }

        void reserve( int u ) {
            if( u > original_size ) {           
                MBitSet n = new MBitSet( u * 2 );  // * 2 to avoid repeated reallocations
                
		int s = size;
		word ptr b = bits.address;
		word ptr sb = n.bits.address;

                for( int i = 0; i < s; i = i + 1 ) {
                    [b] = [sb];

		    b = b + 1w;
		    sb = sb + 1w;
                }

                size = n.size;
                original_size = n.original_size;
                bits = n.bits;
            }
        }

        void init( MBitSet c ) {
            init( c.original_size );
            copy( c );
        }

	// void dispose() {
	//    System.GC.disable();
	//    IO.Std.err.println( "dispose MBitSet: " + String.hex(cast word(this)) );
	//    System.GC.enable();
	// }
        
        void copy( MBitSet c ) {
	    int s = size;
	    if( s > c.size ) {
		s = c.size;
	    }
	    word ptr b = bits.address;
	    word ptr sb = c.bits.address;

            for( int i = 0; i < s; i = i + 1 ) {
                [b] = [sb];

		b = b + 1w;
		sb = sb + 1w;
            }
        }


        MBitSet shorten( int length ) {
            MBitSet r = new MBitSet( length );
            for( int i = 0; i < length; i = i + 1 ) {
                r.bits[i] = bits[i];
            }

            return r;
        }

        MBitSet copy() {
            return new MBitSet(this);
        }

        void setIsChanged( bool b ) {
            changed = b;
        }

        bool getIsChanged() {
            return changed;
        }

        bool getAnySet() {
	    int s = size;
	    word ptr b = bits.address;

            for( int i = 0; i < s; i = i + 1 ) {
                if( [b] != 0W ) {
                    return true;
                }
		b = b + 1w;
            }

            return false;
        }

	/*
        int getSetCount() {
            int result = 0;
            for( int i = 0; i < size; i = i + 1 ) {
                if( bits[i] != 0W ) {
                    result = result + 1;
                }
            }

            return result;
        }
	*/

        int getLength() {
            return original_size;
        }

        bool tryGet( int u ) {
            if( u < original_size ) {
                return opGet(u);
            } else {
                return false;
            }
        }

	/*
        bool get( int u ) {
            return opGet( u );
        }
	*/

        bool opGet( int u ) {
	    word uu = cast<word>(u);
            word n = uu >> cast<word>(System.Environment.WORD_SHIFT);
            word s = uu & cast<word>(System.Environment.WORD_MASK);
        
            // IO.Std.err.println( "get " + u + " of " + bits.length + ": " + n + "/" + s + ", original_size: " + original_size );
            return bits[n] & ( 1W << s ) != cast<word>(0);
        }

        void opSet( int u, bool b ) {
            if( b ) {
                mark( u );
            } else {
                clear( u );
            }
        }
   
	void mark( int u ) {
	    word uu = cast<word>(u);
	    word n = uu >> cast<word>(System.Environment.WORD_SHIFT);
	    word s = uu & cast<word>(System.Environment.WORD_MASK);
	
	    word orig = bits[n];
	    word new_ = orig | (1w << s); 

	    if( orig != new_ ) {
		changed = true;
	    }

	    // avoid redundant array bounds check:
	    [bits.address + n] = new_;
	}

	void mark( int ai, word b ) {
	    word orig = bits[ai];
	    word new_ = orig | b;

	    if( orig != new_ ) {
		changed = true;
		// avoid redundant array bounds check:
		[bits.address + ai] = new_;	    
	    }	    
	}
    
	void clear( int u ) {
	    word uu = cast<word>(u);
	    word n = uu >> cast<word>(System.Environment.WORD_SHIFT);
	    word s = uu & cast<word>(System.Environment.WORD_MASK);
	
	    word orig = bits[n];
	    word new_ = orig & ~( 1w << s );
	
	    if( orig != new_ ) {
		changed = true;
		// avoid redundant array bounds check:
		[bits.address + n] = new_;
	    }
	}

	int getSizeWith( MBitSet s ) {
	    if( size == s.size ) {
		return size;
	    } else if ( size < s.size ) {
		IO.Std.err.println( "too short" );
		return size;
	    } else {
		IO.Std.err.println( "too long" );
		return s.size;
	    }
	}
    
      	bool and( MBitSet set_ ) {
	    int s = size;
	    if( s > set_.size ) {
		s = set_.size;
	    }
	    word ptr b = bits.address;
	    word ptr sb = set_.bits.address;

	    for( int i = 0; i < s; i = i + 1 ) {
		word orig = [b];
		word new_ = orig & [sb]; 

		if( orig != new_ ) {
		    changed = true;
		    [b] = new_;
		}

		b = b + 1w;
		sb = sb + 1w;
	    }
	    return changed;
	}

	// does this set have any temporaries in common with the other set - i.e. is
	// (this & set) != 0
	bool hasAnyInCommon( MBitSet set_ ) {
	    int s = size;
	    if( s > set_.size ) {
		s = set_.size;
	    }
	    word ptr b = bits.address;
	    word ptr sb = set_.bits.address;

	    for( int i = 0; i < s; i = i + 1 ) {
		if( [b] & [sb] != 0w ) {
		    return true;
		}

		b = b + 1w;
		sb = sb + 1w;
	    }
	    return false;
	}
        
	bool or( MBitSet set_ ) {
	    int s = size;
	    if( s > set_.size ) {
		s = set_.size;
	    }
	    word ptr b = bits.address;
	    word ptr sb = set_.bits.address;

	    for( int i = 0; i < s; i = i + 1 ) {
		word orig = [b];
		word new_ = orig | [sb];

		if( orig != new_ ) {
		    changed = true;
		    [b] = new_;
		}

		b = b + 1w;
		sb = sb + 1w;
	    }
	    return changed;
	}
        
	bool andnot( MBitSet set_ ) {
	    int s = size;
	    if( s > set_.size ) {
		s = set_.size;
	    }
	    word ptr b = bits.address;
	    word ptr sb = set_.bits.address;

	    for( int i = 0; i < s; i = i + 1 ) {
		word orig = [b];
		word new_ = orig & ~[sb];

		if( orig != new_ ) {
		    changed = true;
		    [b] = new_;	       
		}	

		b = b + 1w;
		sb = sb + 1w;
	    }
	    return changed;
	}
        
	bool equals( MBitSet set_ ) {
	    int s = size;
	    if( s > set_.size ) {
		s = set_.size;
	    }
	    word ptr b = bits.address;
	    word ptr sb = set_.bits.address;

	    for( int i = 0; i < s; i = i + 1 ) {
		if( [b] != [sb] ) {
		    return false;
		}
		b = b + 1w;
		sb = sb + 1w;
	    }
	
	    return true;
	}
        
	void assign( MBitSet set_ ) {
	    int s = size;
	    if( s > set_.size ) {
		s = set_.size;
	    }
	    word ptr b = bits.address;
	    word ptr sb = set_.bits.address;

	    for( int i = 0; i < s; i = i + 1 ) {
		[b] = [sb];

		b = b + 1w;
		sb = sb + 1w;
	    }
	}
    
	void clear() {
	    int s = size;
	    word ptr b = bits.address;

	    for( int i = 0; i < s; i = i + 1 ) {
		[b] = 0w;
		b = b + 1w;
	    }
	}
        
	void setAll() {
	    int s = size;
	    word ptr b = bits.address;
	    for( int i = 0; i < s; i = i + 1 ) {
		[b] = cast<word>(-1);
		b = b + 1w;
	    }
	}

	void dump( IO.Writer f ) {
	    for( int i = 0; i < size; i = i + 1 ) {
		if( opGet( i ) ) {
		    if( i <= Machine.LAST_MACHINE_REG ) {
			f.write( "R" +  (i - Machine.FIRST_MACHINE_REG) + " " );
		    } else if( i <= Machine.LAST_VAR_REG ) {
			f.write( "RV" + i + " " );
		    } else if( i <= Machine.LAST_TEMP_REG ) {
			f.write( "T" + i + " " );
		    } else {
			f.write( "#" + i + " " );
		    }
		}
	    }
	}

	String toString() {
	    return toString(null);
	}

	String toString(int[] regs) {
	    StringBuffer b = new StringBuffer();
	    // b.append( "len " + getLength() + "/" + original_size + " " );

	    for( int i = 0; i < original_size; i = i + 1 ) {
		if( opGet( i ) ) {
		    if( i >= Machine.FIRST_MACHINE_REG && i <= Machine.LAST_MACHINE_REG ) {
			b.append( Machine.getRegName( i, Machine.WORD ) );
			b.append( ' ' );
		    } else {
			b.append( 'T' );
			b.append( i );
			if( regs != null && i < regs.length && regs[i] > 0 ) {
			    b.append(':');
			    b.append( Machine.getRegName( regs[i], Machine.WORD ) );
			}
			b.append( ' ' );
		    }
		}
	    }
	    return b;
	}

	void check() {
	    int i, j, k, last;
	    bool[] t = new bool[original_size];
	    reset( Machine.FIRST_SOFT_REG );

	    for( i = 0; i < original_size; i = i + 1 ) {
		t[i] = this[i];
	    }

	    last = Machine.FIRST_SOFT_REG-1;

	    for( j = nextSet(); j != -1; j = nextSet() ) {
		if( !t[j] ) {
		    throw new Exception( "not set but returned T" + k );
		}
		for( k = last+1; k < j; k = k + 1 ) {
		    if( t[k] ) {
			throw new Exception( "AA failed to return T" + k );
		    }
		}
		last = j;
	    }	 

	    for( k = last+1; k < original_size; k = k + 1 ) {
		if( t[k] ) {
		    throw new Exception( "BB failed to return T" + k );
		}
	    }
	}

	void reset( int index ) {
	    // IO.Std.err.println( "mbitset reset " + index + " : " + this );
	    current_index = index;
	    ai = index >> System.Environment.WORD_SHIFT;
	    bi = 1w << (cast<word>(index) & cast<word>(System.Environment.WORD_MASK));

	    // IO.Std.err.println( "bit set iterate reset, index: " + current_index + ", ai: " + ai + ", bi: " + bi );

	    current_bits = bits[ai];

	    /*
	    if( bi == 0w ) {
		IO.Std.err.println( "oops: bi is zero on reset" );	   
	    }
	    */
	}

	// find the next set bit, return it's index or -1 if end of set reached:
	int nextSet() {
	    // IO.Std.err.println( "next set, ai is: " + ai + ", current index: " + current_index );

	    /*
	    if( bi == 0w ) {
		IO.Std.err.println( "oops: bi is zero on entry: " + new System.Backtrace() );	   
	    }
	    */

	    do {
		if( current_bits == 0w || bi == 0w) {
		    do {
			// IO.Std.err.println( "zero word skipping from " + current_index + " " + ai * 64);
			ai = ai + 1;
			if( ai >= size ) {
			    return -1;
			}
			// avoid array bounds check:
			current_bits = [bits.address + ai];
		    } while( current_bits == 0w );

		    current_index = ai * System.Environment.WORD_BITS;
		    
		    // IO.Std.err.println( "zero words skipped to " + current_index + ", array index: " + ai );
		    // IO.Std.err.println( "array index now: " + ai );
		    
		    bi = 1w;
		}

		do {
		    // IO.Std.err.println( "current bits now non-zero, looking for a set bit..." );
		    if( current_bits & bi != 0w ) {
			int result = current_index;

			/*
			if( !this[result] ) {
			    IO.Std.err.println( "oops: returning unset T" + result );

			    IO.Std.err.println( "roughly at " + ai );
			    for( int i = 0; i < 64; i = i + 1 ) {
				if( 1w << cast<word>(i) != 0w ) {
				    IO.Std.err.println( "calculated index is " + ((ai * 64) + i) + " versus " + result );
				}
			    }
			}
			*/

			bi = bi + bi;
			current_index = current_index + 1;
			// IO.Std.err.println( "is set T" + current_index );


			return result;
		    }

		    current_index = current_index + 1;
		    bi = bi + bi;
		} while( bi != 0w );

		current_bits = 0w;
		
		// IO.Std.err.println( "fallen off end of word - go again..." );
	    } while( true );
	}

	int[] getArray() {
	    int count = 0;
	    /*
	    word ptr bp = bits.address;
	    for( int ai = 0; ai < size; ai = ai + 1 ) {
		word b = [bp];
 
		for( bi = 1w; bi != 0w; bi = bi + bi ) {
		    if( b & bi != 0w ) {
			count = count + 1;
		    }
		}
		b = b + 1;
	    }
	    */

	    Generic.Vector<int> result = new Generic.Vector<int>(original_size);

	    int c = 0;
	    reset( Machine.FIRST_SOFT_REG );
	    for( int j = nextSet(); j != -1; j = nextSet() ) {
		result.add( j );
	    }

	    return result.Array;
	}
    }
}