
namespace Test182 is
  use System.String;
  use System.StringBuffer;
  use IO.Std;
  use Generic.List;

  class Main is
    void init() is
      var b = new StringBuffer();

      Apply<String>.apply(
        { "A", "B", "C", "D", "E", "F", "G" },
	void proc(String s) use b is
	  b.append(s);
	si
      );

      Std.err.println(b);
    si
  si

  class Apply<T> is
    static void apply(List<T> l, void proc(T) f) is
      foreach var t; l.Iterator do
        f(t);
      od
    si
  si
si