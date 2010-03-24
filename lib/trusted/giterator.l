#K

pragma NoWarnHide;

namespace Generic is
    /// Interface. Iterator<T> over some collection of T returns each value in the collection in turn.
    interface Iterator<T> is
        /// Are there more values remaining? 
        bool hasMoreElements();
        /// Return the next value. Behaviour is undefined if nextElement() is called after hasMoreElements() has returned false
	T nextElement();
    si

    /// Interface. Objects implementing Iterable<T> can be iterated over using Iterator<T>
    interface Iterable<T> is
	get Iterator<T> Iterator;
    si
si