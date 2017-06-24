pragma NoWarnHide;

namespace Collections is
    use System.String;
    use System.RuntimeException;

    class ITERATOR_EXCEPTION isa RuntimeException is
        void init() is
            super.init();
        si

        void init(String message) is
            super.init(message);
        si
    si
 
    /// Interface. Objects implementing Iterable<T> can be iterated over using Iterator<T>
    interface Iterable<T> is
	    Iterator<T> elements();
    si

    /// Interface. Iterator<T> over some collection of T returns each value in the collection in turn.
    interface Iterator<T> is
        /// Are there more values remaining? 
        bool next();
        /// Return the next value. Behaviour is undefined if nextElement() is called after hasMoreElements() has returned false
	    get T current;
    si
si