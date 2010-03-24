#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import stream;
import thread;
import pointer;
import glqueue;

namespace Util {
    use System.Object;
    use System.String;
    use System.Thread;
    use Generic.LockedQueue;

    /// Work objects are processed by ThreadPool Workers. In order to submit work to a ThreadPool, derive a new class from
    /// Work and override its process() method to perform the required work
    class Work extends System.Object {
	/// Construct a new Work object
	void init() { }

	/// Override this method to perform work. A Worker object from ThreadPool will call process() to perform work on caller's behalf
	void process() {
	    // override me
	}

	/// Accessor: get bool Done
	/// Internal accessor. ThreadPool arranges for this accessor to be false to inform Workers to exit
	get bool Done {
	    return false;
	}
    }

    /// A Thread in a ThreadPool that performs work on behalf of clients of ThreadPool
    class Worker extends System.Thread {
	int id;
	LockedQueue<Work> queue;

	/// Construct a new Worker
	/// \param id number of this Worker within its ThreadPool
	/// \param q the LockedQueue of Work that this Worker Thread will receive work from
	void init( int id, LockedQueue<Work> q ) {
	    super.init();
	    this.id = id;
	    queue = q;
	}

	// it's essential that this method does not return until it receives a finished
	// work message - otherwise it will hang the thread pool.

	/// The main loop of a Worker Thread. Repeatedly removes Work from the ThreadPool's LockedQueue
	/// and calls Work.process() until it receives a Work object where Work.Done == true
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

    /// Special subclass of Work that signals Done == true to Worker Threads
    class Finished extends Work {
	void init() {
      	}

	get bool Done {
	    return true;
	}
    }

    // with the exception of 'submit()' this call is not itself thread safe - it should
    // be managed by calls from a single thread:
    /// A pool of Threads that queues received Work until a Worker Thread is available to process it.
    /// Work will generally be processed in order submitted but this is not guarenteed. Multiple Threads
    /// can submit work simultaneously
    class ThreadPool extends System.Object {
	LockedQueue<Work> queue;
	Worker[] worker;

	/// Construct a new ThreadPool
	/// \param size number of Worker Threads to create
	void init( int size ) {
	    queue = new LockedQueue<Work>(size*4);
	    worker = new Worker[size];

	    for( int i = 0; i < worker.length; i = i + 1 ) {
		worker[i] = new Worker(i,queue);
	    }
	}
	
	/// Start the Worker Threads in this pool
	void start() {
	    for( int i = 0; i < worker.length; i = i + 1 ) {
		IO.Std.err.println( "start worker: " + i );
		worker[i].start();
	    }
	}

	/// Wait for all existing Work to process. No further Work can be submitted after this method is called either
	/// by the calling thread or any other thread
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

	/// Submit work to the queue
	/// \param work Work to process
	void submit( Work work ) {
	    queue.add( work );
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