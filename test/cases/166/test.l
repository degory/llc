namespace Test166 is
  interface I is
    void test(int i, int j);
  si

  class T do I is
    void init() is
    si

    void test(int i, int j) is
      IO.Std.err.println( "T.I(" + i + "," + j + ")" );
    si
  si

  class Main is
    void init() is
      var t = new T();
      var i = cast I(t);

      t.test(111,222);
      t.test(333,444);
      i.test(555,666);
      i.test(777,888);
    si
  si
si