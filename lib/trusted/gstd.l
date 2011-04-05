import filter;
import gslist;
import gsort;
import gset;
import gsset;
import gcastlist;

namespace Generic is
  use System.String;
  use System.StringBuffer;
  use Util.Filter;
  use Util.Filter2;
  use Util.CastList;
  use Util.ConvertList;

  ///expand templates for some common generics to ensure they're present in the standard shared library
  class __SG<T> is
    T[] at;
    Vector<T> vector;
    Slice<T> slice;
    LinkedList<T> linked_list;
    SortedList<T> sorted_list;
    Sort<T> sort;
    Set<T> set_;
    Map<T,T> map;
    Map<int,T> map_ik;
    Map<String,T> map_sk;
    SortedMap<T,T> sorted_map;
    SortedMap<int,T> sorted_map_ik;
    SortedMap<String,T> sorted_map_sk;
    Filter<T> filter;
    Generator<T> gen;
  si

  class __SG2<T,U> is
    Filter2<T,U> filter2_tu;
    Filter2<U,T> filter2_ut;
    CastList<T,U> cast_list_tu;
    CastList<U,T> cast_list_ut;
    ConvertList<T,U> convert_list_tu;
    ConvertList<U,T> convert_list_ut;
  si

  class __StandardGenerics is
    __SG<bool> bool_;
    __SG<char> char_;
    __SG<int> int_;
    __SG<long> long_;
    __SG<String> string_;
    __SG<StringBuffer> stringbuffer_;
    __SG2<bool,char> _bc;
    __SG2<bool,int> _bi;
    __SG2<bool,long> _bl;
    __SG2<bool,String> _bs;
    __SG2<char,int> _ci;
    __SG2<char,long> _cl;
    __SG2<char,String> _cs;
    __SG2<int,long> _il;
    __SG2<int,String> _is;
    __SG2<long,String> _ls;
  si
si