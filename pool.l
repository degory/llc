/**
 * Java Thread Pool
 * 
 * This is a thread pool that for Java, it is
 * simple to use and gets the job done. This program and
 * all supporting files are distributed under the Limited
 * GNU Public License (LGPL, http://www.gnu.org).
 * 
 * This is the main class for the thread pool. You should
 * create an instance of this class and assign tasks to it.
 * 
 * For more information visit http://www.jeffheaton.com.
 * 
 * @author Jeff Heaton (http://www.jeffheaton.com)
 * @version 1.0
 * 
 */

namespace Util {
    use Util.Thread;
    use Util.Signal;
    use Generic.Vector;

    class Queue<T> extends System.Object {
	T[] values;
	int head, tail;

	void init( int length ) {

	bool getFull() { 
	    return 
	}
	

    }

    class ThreadPool {
	Signal lock;

	/**
	 * The threads in the pool.
	 */
	Thread[] threads;
	/**
	 * The backlog of assignments, which are waiting
	 * for the thread pool.
	 */
	Vector<Work> assignments;
	/**
	 * A Done object that is used to track when the
	 * thread pool is done, that is has no more work
	 * to perform.
	 */
	Done done = new Done();
	
	/**
	 * The constructor.
	 * 
	 * @param size  How many threads in the thread pool.
	 */
	void init(int size) {
	    lock = new Signal();

	    assignments = new Vector<Work>();
	    threads = new WorkerThread[size];
	    for( int i = 0; i < threads.length; i = i + 1 ) {
		threads[i] = new WorkerThread(this);
		threads[i].start();
	    }
	}
	
	/**
	 * Add a task to the thread pool. Any class
	 * which implements the Runnable interface
	 * may be assienged. When this task runs, its
	 * run method will be called.
	 * 
	 * @param r   An object that implements the Runnable interface
	 */
	void assign(Runnable r) {
	    try {
		lock.lock();
		done.workerBegin();
		assignments.add(r);
		lock.signal();
	    } finally {
		lock.unlock();
	    }
	}

	/**
	 * Get a new work assignment.
	 * 
	 * @return A new assignment
	 */
	public synchronized Runnable getAssignment() {
	    try {
		lock.lock();
		while( assignments.Length == 0 )
		    lock.wait();
		
		Work r = assignments.pull();
		return r;
	    } catch (InterruptedException e) {
		done.workerEnd();
		return null;
	    } finally {
		lock.unlock();
	    }
	}

	/**
	 * Called to block the current thread until
	 * the thread pool has no more work.
	 */
	public void complete() {
	    done.waitBegin();
	    done.waitDone();
	}

	/*
	protected void finalize() {
	    done.reset();
	    for (int i=0;i<threads.length;i++) {
		threads[i].interrupt();
		done.workerBegin();
		threads[i].destroy();
	    }
	    done.waitDone();
	}
	*/
    }

    /**
     * The worker threads that make up the thread pool.
     * 
     * @author Jeff Heaton
     * @version 1.0
     */
    class WorkerThread extends Thread {
	/**
	 * True if this thread is currently processing.
	 */
	public boolean busy;
	/**
	 * The thread pool that this object belongs to.
	 */
	public ThreadPool owner;
	
	/**
	 * The constructor.
	 * 
	 * @param o the thread pool 
	 */
	void init(ThreadPool o) {
	    owner = o;
	}
	
	/**
	 * Scan for and execute tasks.
	 */
	void run() {
	    Work target = null;
	    
	    do {
		target = owner.getAssignment();
		if (target!=null) {
		    target.run();      
		    owner.done.workerEnd();
		}
	    } while (target!=null);
	}
    }
    
    /**
     * 
     * This is a thread pool for Java, it is
     * simple to use and gets the job done. This program and
     * all supporting files are distributed under the Limited
     * GNU Public License (LGPL, http://www.gnu.org).
     * 
     * This is a very simple object that
     * allows the TheadPool to determine when 
     * it is done. This object implements
     * a simple lock that the ThreadPool class
     * can wait on to determine completion.
     * Done is defined as the ThreadPool having
     * no more work to complete.
     * 
     * Copyright 2001 by Jeff Heaton
     *
     * @author Jeff Heaton (http://www.jeffheaton.com)
     * @version 1.0
     */
    public class Done {
	Signal lock;
	/**
	 * The number of Worker object
	 * threads that are currently working
	 * on something.
	 */
	private int _activeThreads = 0;
	
	/**
	 * This boolean keeps track of if
	 * the very first thread has started
	 * or not. This prevents this object
	 * from falsely reporting that the ThreadPool 
	 * is done, just because the first thread
	 * has not yet started.
	 */
	private boolean _started = false;
	/**
	 * This method can be called to block
	 * the current thread until the ThreadPool
	 * is done.
	 */

	void init() {
	    lock = new Signal();
	}
	
	void waitDone() {
	    try {
		lock.lock();

		while ( _activeThreads>0 ) {
		    lock.wait();
		}
	    } finally {
		lock.unlock();
	    }
	}
	/**
	 * Called to wait for the first thread to 
	 * start. Once this method returns the
	 * process has begun.
	 */
	
	public void waitBegin()
	{	    
	    try {
		lock.lock();
		while ( !_started ) {
		    lock.wait();
		}
	    } finally {
		lock.unlock();
	    }
	}
	

	/**
	 * Called by a Worker object
	 * to indicate that it has begun 
	 * working on a workload.
	 */
	public void workerBegin()
	{
	    try {
		lock.lock();
		_activeThreads = _activeThreads + 1;
		_started = true;
		lock.signal();
	    } finally {
		lock.unlock();
	    }
	}

	/**
	 * Called by a Worker object to 
	 * indicate that it has completed a 
	 * workload.
	 */
	public void workerEnd()
	{
	    try {
		lock.lock();

		_activeThreads = _activeThreads + 1;
		lock.signal();
	    } finally {
		lock.unlock();
	    }
	}

	/**
	 * Called to reset this object to
	 * its initial state.
	 */
	public void reset()
	{
	    try {
		lock.lock();

		_activeThreads = 0;
	    } finally {
		lock.unlock();
	    }
	}

    }

    /**
     * This class shows an example worker thread that can
     * be used with the thread pool. It demonstrates the main
     * points that should be included in any worker thread. Use
     * this as a starting point for your own threads.
     * 
     * @author Jeff Heaton (http://www.jeffheaton.com)
     * @version 1.0
     */
    public class TestWorkerThread extends Thread {
	static private int count = 0;
	private int taskNumber;
	protected Done done;
	
	/**
	 * 
	 * @param done
	 */
	void init() {
	    count++;
	    taskNumber = count;
	}
	
	public void run()
	{
	    for (int i=0;i<100;i = i + 1) {
		System.out.println("Task number: " + taskNumber + 
				   ",percent complete = " + i );
		Thread.sleep(Util.random(3));
	    }
	}
    }

    /**
     * Main class used to test the thread pool.
     * 
     * @author Jeff Heaton (http://www.jeffheaton.com)
     * @version 1.0
     */
    public class Main {
	/**
	 * Main entry point.
	 * 
	 * @param args  No arguments are used.
	 */
	public void init() {
	    ThreadPool pool = new ThreadPool(10);
	    
	    for( int i = 0; i < 25; i = i + 1 ) {
		pool.assign(new TestWorkerThread());
	    }
	    
	    pool.complete();
	    
	    System.out.println("All tasks are done.");
	}
    }
}