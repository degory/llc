
namespace Test196 is
  class Main is
    void init() is

    si
  si

  class TestA is
    void init() is
    si
  si

  class TestB isa TestA is
    void init(int a) is
      if a > 50 then
        super.init();
      else 
        super.init();
      fi
    si

    void init() is
      @NoWarnInit;
    si

    void init(int a, int b) is
      // should warn here
    si
  si
si