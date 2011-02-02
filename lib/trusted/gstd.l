import filter;
import gslist;
import gsort;
import gset;
import gsset;

namespace Generic is
  use System.String;
  use System.StringBuffer;
  use Util.Filter;

  /// StandardGenerics expand templates for some common generics to ensure they're present in the standard shared library
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

  si

  class __StandardGenerics is
    __SG<bool> bool_;
    __SG<char> char_;
    __SG<int> int_;
    __SG<long> long_;
    __SG<String> string_;
  si
si