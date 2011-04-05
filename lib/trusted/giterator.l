#K

pragma NoWarnHide;

namespace Generic is
    use System.String;
    use System.RuntimeException;

    class IteratorException isa RuntimeException is
        void init() is
            super.init();
        si

        void init(String message) is
            super.init(message);
        si
    si
 
    /// Interface. Objects implementing Iterable<T> can be iterated over using Iterator<T>
    interface Iterable<T> is
	get Iterator<T> Iterator;
    si

    /// Interface. Iterator<T> over some collection of T returns each value in the collection in turn.
    interface Iterator<T> isa Iterable<T> is
        /// Are there more values remaining? 
        bool hasMoreElements();
        /// Return the next value. Behaviour is undefined if nextElement() is called after hasMoreElements() has returned false
	T nextElement();
    si
si