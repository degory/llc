import stream;
import thread;
import pointer;

namespace Util {
    use System.Object;
    use System.String;
    use System.Thread;
    use System.Lock;
    use System.Signal;

    class Work extends System.Object {
	void init() { }

	void process() {
	    // override me
	}

	get bool Done {
	    return false;
	}
    }

    class Worker extends System.Thread {
	int id;
	LockedQueue<Work> queue;

	void init( int id, LockedQueue<Work> q ) {
	    super.init();
	    this.id = id;
	    queue = q;
	}

	// it's essential that this method does not return until it receives a finished
	// work message - otherwise it will hang the thread pool.
	void run() {
	    bool done = false;
	    do { 
		try {

		    // IO.Std.err.println( "worker " + id + ": waiting on queue" );
		    Work w = queue.remove();
		    if( !w.Done ) {
			// IO.Std.err.println( "worker " + id + ": will process" );
			w.process();
		    } else {
			// IO.Std.err.println( "worker " + id + ": done" );
			done = true;
		    }
		} catch( System.Exception e ) {
		    IO.Std.err.println( "oops: worker " + id + " caught: " + e );
		}
		    
		// IO.Std.err.println( "worker " + id + ": loop" );
	    } while( !done );
	    // IO.Std.err.println( "worker " + id + ": exiting" );
	}
    }

    class Finished extends Work {
	void init() {
      	}

	get bool Done {
	    return true;
	}
    }

    // with the exception of 'submit()' this call is not itself thread safe - it should
    // be managed by calls from a single thread:

    class ThreadPool extends System.Object {
	LockedQueue<Work> queue;
	Worker[] worker;

	void init( int size ) {
	    queue = new LockedQueue<Work>(size*4);
	    worker = new Worker[size];

	    for( int i = 0; i < worker.length; i = i + 1 ) {
		worker[i] = new Worker(i,queue);
	    }
	}

	void start() {
	    for( int i = 0; i < worker.length; i = i + 1 ) {
		IO.Std.err.println( "start worker: " + i );
		worker[i].start();
	    }
	}

	void wait() {
	    int i;
	    for( i = 0; i < worker.length; i = i + 1 ) {
		// add one empty work for each worker thread.
		// each worker will take exactly one piece and
		// then exit:
		// IO.Std.err.println( "queue finish job: " + i );
		queue.add( new Finished() );
	    }

	    for( i = 0; i < worker.length; i = i + 1 ) {
		// IO.Std.err.println( "wait exit: " + i );
		worker[i].waitExit();
		// IO.Std.err.println( "now exited: " + i );
	    }

	    // IO.Std.err.println( "all threads exited" );
	}

	void submit( Work work ) {
	    queue.add( work );
	}
    }

    class QueueException extends System.Exception {
	void init( String message ) {
	    super.init(message);
	}
    }

    class LockedQueue<T> extends Queue<T> {
	Lock lock;
	Signal not_full;
	Signal not_empty;

	void init( int size ) {
	    super.init(size);
	    
	    lock = new Lock();
	    not_full = new Signal(lock);
	    not_empty = new Signal(lock);
	}

	void add( T v ) {
	    try {
		lock.lock();
		while( IsFull ) {
		    not_full.wait(3);
		}

		bool was_empty = IsEmpty;
		super.add( v );

		if( was_empty ) {
		    not_empty.signal();
		}
	    } finally {
		lock.unlock();
	    }
	}

	T remove() {
	    try {
		lock.lock();
		while( IsEmpty ) {
		    not_empty.wait(3);
		}

		bool was_full = IsFull;

		T result = super.remove();

		if( was_full ) {
		    not_full.signal();
		}	

		return result;
	    } finally {
		lock.unlock();
	    }
	}      
    }

    class Queue<T> extends System.Object {
	T[] queue;
	int head;  // elements added here
	int tail;  // elements removed here

	void init( int size ) {
	    assert( size > 0 );
	    queue = new T[size];
	}

	get bool IsEmpty {
	    return head == tail;
	}

	int next(int index) {
	    return (index + 1) % queue.length;
	}

	get bool IsFull {
	    return next(head) == tail;
	}

	void add( T v ) {
	    int next_head = next(head);
	    if( next_head == tail ) {
		throw new QueueException( "add on full queue" );
	    } else {
		queue[head] = v;
		head = next_head;
	    }
	}

	bool addQuiet( T v ) {
	    int next_head = next(head);
	    if( next_head == tail ) {
		return false;
	    } else {
		queue[head] = v;
		head = next_head;
		return true;
	    }
	}

	T remove() {
	    if( head == tail ) {
		throw new QueueException( "remove on empty queue" );
	    } else {
		T result = queue[tail];
		tail = next(tail);
		return result;
	    }
	}

	T removeQuiet() {
	    if( head == tail ) {
		// note for non-Object types this is ambiguous but caller has option
		// of checking IsEmpty first:
		return T.none;
	    } else {
		T result = queue[tail];
		tail = next(tail);
		return result;
	    }
	}
    }

    class TestThreadPool {
	const int NUM_PRODUCE = 3;
	const int NUM_CONSUME = 5;

	void init() {
	    int i;
	    Lock io = new Lock();
	    Produce[] produce = new Produce[NUM_PRODUCE];

	    var pool = new ThreadPool(NUM_CONSUME);

	    for( i = 0; i < NUM_PRODUCE; i = i + 1 ) {
		produce[i] = new Produce(io,pool,i);
	    }

	    for( i = 0; i < NUM_PRODUCE; i = i + 1 ) {
		produce[i].start();
	    }

	    pool.start();

	    for( i = 0; i < NUM_PRODUCE; i = i + 1 ) {
		IO.Std.err.println( "wait produce: " + i );
		produce[i].waitExit();
	    }

	    IO.Std.err.println( "wait pool" );
	    pool.wait();
	} 
    }

    class Produce extends Thread {
	int id;
	Lock io;
	ThreadPool p;

	void init(Lock io, ThreadPool p, int id) {
	    this.io = io;
	    this.p = p;
	    this.id = id;
	}

	void run() { 
	    try {
		int n;
		for( int i = 0; i < 10; i = i + 1 ) {
		    p.submit( new Consume( io, id, "produce " + id + ": work: " + (3 * n + id) ) );
		    n = n + 1;
		    
		    sleep(System.Int.random() % (3+id));
		}
	    } catch( System.Exception se ) {
		IO.Std.err.println( "produce caught: " + se );
	    }

	    IO.Std.err.println( "produce exiting" );
	}
    }

    class Consume extends Work {
	int id;
	Lock io;
	String v;

	void init(Lock io, int id, String v ) {
	    this.io = io;
	    this.id = id;
	    this.v = v;
	}

	void process() { 
	    io.lock();
	    IO.Std.err.println("consume " + id + ": " + v );
	    io.unlock();

	    Thread.sleep(System.Int.random() % (3+id));
	}
    }
}