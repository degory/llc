
import gslist;

namespace Test185 is
  use System.String;
  use IO.Std;
  use Generic.SortedList;

  class ListTest<T> is
    void init() is
      var l = new SortedList<T>();
    si
  si

  class Main is
    void init() is
      ListTest<bool> b;
      ListTest<char> c;
      ListTest<int> i;
      // ListTest<long> l;
      ListTest<String> s;
    si
  si
si