namespace Test168 is
  use System.String;
  use Generic.Vector;
  use Generic.List;
  
  class Main is
    void init() is
      List<String> a = { "A", "B", "C", "D", "E", "F", "G", "H", "I" };
      List<String> v = new Vector<String>();

      foreach var i; a.Iterator do
        IO.Std.err.println( "add: " + i );
        v.add( i );
      od

      foreach var i; a.Iterator do
        IO.Std.err.println( "have: " + i );
      od
    si
  si
si