
namespace Test167 is
  use System.String;
  use Generic.List;
  use Generic.Vector;

  class Main is
    void init() is
      var a = new String[4];

      var i = a.Iterator; // { "A", "B", "C", "D" }.Iterator;

      i.hasMoreElements();
      i.nextElement();
    si
  si
si