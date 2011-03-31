
import gslist;

namespace Test184 is
  use System.String;
  use IO.Std;
  use Generic.SortedList;

  class Main is
    void init() is
      var l = new SortedList<String>();

      foreach var s; { "D", "F", "G", "A", "C", "H", "B", "E" }.Iterator do
        Std.err.println( "add: " + s );
        l.add(s);
      od

      Std.err.println( "list is: " + l );

      var m = new SortedList<int>();

      foreach var s; { 4, 6, 7, 1, 3, 8, 2, 5 }.Iterator do
        Std.err.println( "add: " + s );
        m.add(s);
      od

      Std.err.println( "list is: " + m );
    si
  si
si