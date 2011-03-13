
namespace Test165 is
  class Test is
    void init() is
      ;
    si

    get int Stuff[int i] is
      return i;
    si

    set int Stuff[int i] = v is
      IO.Std.err.println( "set Stuff[" + i + "] = " + v );
    si
  si

  class Main is
    void init() is
      var s = new Test();

      s.Stuff[1] = 1;
      s.Stuff[2] = 2;      
    si
  si
si