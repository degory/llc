#K

// L version of this code Copyright 2010-2017 <degs@giantblob.com>
// following notice applies to red black tree in this file only

/* Copyright (c) 2010 the authors listed at the following URL, and/or
the authors of referenced articles or incorporated external code:
http://en.literateprograms.org/Red-black_tree_(Java)?action=history&offset=20100112141306

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Retrieved from: http://en.literateprograms.org/Red-black_tree_(Java)?oldid=16622
*/

import gpair;
import gdict;

namespace Collections is

    use System.String;
    use System.StringBuffer;

    /// tree node color for red-black tree
    enum NODE_COLOR is RED, BLACK si

    /// An associative array that is naturally sorted
    /// \param K type of keys in the Map. K must implement int operator>(K,K)
    /// \param V type of values in the Map.
    class TREE_MAP<K,V> do Dict<K,V> is
        public TREE_MAP_NODE<K,V> root;

        /// Construct an empty TREE_MAP<K,V>
        void init() is
            root = null;
        si

        /// Internal method
        private static NODE_COLOR node_color(TREE_MAP_NODE<K,V> n) is
            if n == null then
                return NODE_COLOR.BLACK;
            fi
            return n.color;
        si

        /// Internal method
        private TREE_MAP_NODE<K,V> lookup_tree_node(K key) is
            var n = root;
            while n != null do
                var comp_result = key.opCompare(n.key);
                if comp_result == 0 then
                    return n;
                elif comp_result < 0 then
                    n = n.left;
                else
                    n = n.right;
                fi
            od

            return n;
        si

        bool contains(K key) is
            var n = lookup_tree_node(key);
            return n != null;
        si

        get V[K key] is
            var n = lookup_tree_node(key);
            if n == null then
                return V.none;
            fi

            return n.value;
        si

        private void rotate_left(TREE_MAP_NODE<K,V> n) is
            var r = n.right;
            replace_tree_node(n, r);
            n.right = r.left;
            if r.left != null then
                r.left.parent = n;
            fi
            r.left = n;
            n.parent = r;
        si

        private void rotate_right(TREE_MAP_NODE<K,V> n) is
            var l = n.left;
            replace_tree_node(n, l);
            n.left = l.right;
            if l.right != null then
                l.right.parent = n;
            fi
            l.right = n;
            n.parent = l;
        si

        private void replace_tree_node(TREE_MAP_NODE<K,V> oldn, TREE_MAP_NODE<K,V> newn) is
            if oldn.parent == null then
                root = newn;
            else
                if oldn == oldn.parent.left then
                    oldn.parent.left = newn;
                else
                    oldn.parent.right = newn;
                fi
            fi

            if newn != null then
                newn.parent = oldn.parent;
            fi
        si

        set V[K key] = value is
            var inserted_tree_node = new TREE_MAP_NODE<K,V>(key, value, NODE_COLOR.RED, null, null);
        
            if root == null then
                root = inserted_tree_node;
            else
                var n = root;
                do
                    var comp_result = key.opCompare(n.key);
                    if comp_result == 0 then
                        n.value = value;
                        return;
                    elif comp_result < 0 then
                        if n.left == null then
                            n.left = inserted_tree_node;
                            break;
                        else
                            n = n.left;
                        fi
                    else
                        if n.right == null then
                            n.right = inserted_tree_node;
                            break;
                        else
                            n = n.right;
                        fi
                    fi
                od
                inserted_tree_node.parent = n;
            fi
            insert_case_1(inserted_tree_node);
        si

        private void insert_case_1(TREE_MAP_NODE<K,V> n) is
            if n.parent == null then
                n.color = NODE_COLOR.BLACK;
            else
                insert_case_2(n);
            fi
        si

        private void insert_case_2(TREE_MAP_NODE<K,V> n) is
            if node_color(n.parent) == NODE_COLOR.BLACK then
                return; // Tree is still valid
            else
                insert_case_3(n);
            fi
        si

        void insert_case_3(TREE_MAP_NODE<K,V> n) is
            if node_color(n.uncle()) == NODE_COLOR.RED then
                n.parent.color = NODE_COLOR.BLACK;
                n.uncle().color = NODE_COLOR.BLACK;
                n.grandparent().color = NODE_COLOR.RED;
                insert_case_1(n.grandparent());
            else
                insert_case_4(n);
            fi
        si

        void insert_case_4(TREE_MAP_NODE<K,V> n) is
            if n == n.parent.right && n.parent == n.grandparent().left then
                rotate_left(n.parent);
                n = n.left;
            elif n == n.parent.left && n.parent == n.grandparent().right then
                rotate_right(n.parent);
                n = n.right;
            fi
            insert_case_5(n);
        si

        void insert_case_5(TREE_MAP_NODE<K,V> n) is
            n.parent.color = NODE_COLOR.BLACK;
            n.grandparent().color = NODE_COLOR.RED;
            if n == n.parent.left && n.parent == n.grandparent().left then
                rotate_right(n.grandparent());
            else
                rotate_left(n.grandparent());
            fi
        si

        V remove(K key) is
            var n = lookup_tree_node(key);
            if n == null then
                return V.none;  // Key not found, do nothing
            fi

            var result = n.value;

            if n.left != null && n.right != null then
                // Copy key/value from predecessor and then delete it instead
                var pred = maximum_tree_node(n.left);
                n.key = pred.key;
                n.value = pred.value;
                n = pred;
            fi

            TREE_MAP_NODE<K,V> child;
            if n.right == null then
                child = n.left;
            else
                child = n.right;
            fi

            if node_color(n) == NODE_COLOR.BLACK then
                n.color = node_color(child);
                delete_case_1(n);
            fi

            replace_tree_node(n, child);
        
            if node_color(root) == NODE_COLOR.RED then
                root.color = NODE_COLOR.BLACK;
            fi  

            return result;
        si

        static TREE_MAP_NODE<K,V> minimum_tree_node(TREE_MAP_NODE<K,V> n) is
            while n.left != null do
                n = n.left;
            od

            return n;
        si

        static TREE_MAP_NODE<K,V> maximum_tree_node(TREE_MAP_NODE<K,V> n) is
            while n.right != null do
                n = n.right;
            od
            return n;
        si

        private void delete_case_1(TREE_MAP_NODE<K,V> n) is
            if n.parent == null then
                return;
            else
                delete_case_2(n);
            fi
        si

        private void delete_case_2(TREE_MAP_NODE<K,V> n) is
            if node_color(n.sibling()) == NODE_COLOR.RED then
                n.parent.color = NODE_COLOR.RED;
                n.sibling().color = NODE_COLOR.BLACK;
                if n == n.parent.left then
                    rotate_left(n.parent);
                else
                    rotate_right(n.parent);
                fi
            fi
            delete_case_3(n);
        si

        private void delete_case_3(TREE_MAP_NODE<K,V> n) is
            if node_color(n.parent) == NODE_COLOR.BLACK &&
                node_color(n.sibling()) == NODE_COLOR.BLACK &&
                node_color(n.sibling().left) == NODE_COLOR.BLACK &&
                node_color(n.sibling().right) == NODE_COLOR.BLACK
            then
                n.sibling().color = NODE_COLOR.RED;
                delete_case_1(n.parent);
            else
                delete_case_4(n);
            fi
        si

        private void delete_case_4(TREE_MAP_NODE<K,V> n) is
            if node_color(n.parent) == NODE_COLOR.RED &&
                node_color(n.sibling()) == NODE_COLOR.BLACK &&
                node_color(n.sibling().left) == NODE_COLOR.BLACK &&
                node_color(n.sibling().right) == NODE_COLOR.BLACK
            then
                n.sibling().color = NODE_COLOR.RED;
                n.parent.color = NODE_COLOR.BLACK;
            else
                delete_case_5(n);
            fi
        si

        private void delete_case_5(TREE_MAP_NODE<K,V> n) is
            if n == n.parent.left &&
                node_color(n.sibling()) == NODE_COLOR.BLACK &&
                node_color(n.sibling().left) == NODE_COLOR.RED &&
                node_color(n.sibling().right) == NODE_COLOR.BLACK
            then
                n.sibling().color = NODE_COLOR.RED;
                n.sibling().left.color = NODE_COLOR.BLACK;
                rotate_right(n.sibling());
            elif n == n.parent.right &&
                node_color(n.sibling()) == NODE_COLOR.BLACK &&
                node_color(n.sibling().right) == NODE_COLOR.RED &&
                node_color(n.sibling().left) == NODE_COLOR.BLACK
            then
                n.sibling().color = NODE_COLOR.RED;
                n.sibling().right.color = NODE_COLOR.BLACK;
                rotate_left(n.sibling());
            fi
            delete_case_6(n);
        si

        private void delete_case_6(TREE_MAP_NODE<K,V> n) is
            n.sibling().color = node_color(n.parent);
            n.parent.color = NODE_COLOR.BLACK;
            if n == n.parent.left then
                n.sibling().right.color = NODE_COLOR.BLACK;
                rotate_left(n.parent);
            else
                n.sibling().left.color = NODE_COLOR.BLACK;
                rotate_right(n.parent);
            fi
        si

        String toString() is
            var buffer = new System.StringBuffer();
            toString(root, buffer);
            return buffer;
        si

        void clear() is
            root = null;
        si

        get int length is
            return length(root);
        si

        private static int length(TREE_MAP_NODE<K,V> n) is
            if n == null then
                return 0;
            else
                return this(n.left) + this(n.right);
            fi
        si

        private static void to_string(TREE_MAP_NODE<K,V> n, StringBuffer b) is
            if n == null then
                b.append("()");
                return;
            fi

            b.append('(');
            b.append( n );

            if n.left != null then
                b.append(',');
                to_string(n.left, b);
            fi

            b
                .append(',')
                .append(n.key)
                .append("=>")
                .append(n.value);

            if n.right != null then
                b.append( ',' );
                toString(n.right, b);
            fi

            b.append(')');
        si    

        TREE_MAP_ITERATOR<K,V> pairs() is
            return new TREE_MAP_ITERATOR<K,V>(root);
        si

        TREE_MAP_REVERSE_ITERATOR<K,V> reverse_pairs() is
            return new TREE_MAP_REVERSE_ITERATOR<K,V>(root);
        si

        PAIR_KEY_ITERATOR<K,V> keys() is
            return new PAIR_KEY_ITERATOR<K,V>(pairs());
        si

        PAIR_VALUE_ITERATOR<K,V> elements() is
            return new PAIR_VALUE_ITERATOR<K,V>(pairs());
        si
    si

    /// A node in the TREE_MAP<K,V> Red-black tree 
    class TREE_MAP_NODE<K,V> isa Pair<K,V> is
        public K key;
        public V value;
        public TREE_MAP_NODE<K,V> left;
        public TREE_MAP_NODE<K,V> right;
        public TREE_MAP_NODE<K,V> parent;
        public NODE_COLOR color;

        void init(K key, V value, NODE_COLOR node_color, TREE_MAP_NODE<K,V> left, TREE_MAP_NODE<K,V> right) is
            @NoWarnInit;
            this.key = key;
            this.value = value;
            this.color = node_color;
            this.left = left;
            this.right = right;
            if left != null then
                left.parent = this;
            fi
            if right != null then
                right.parent = this;
            fi
            this.parent = null;
        si

        TREE_MAP_NODE<K,V> grandparent() is
            return parent.parent;
        si

        TREE_MAP_NODE<K,V> sibling() is
            if this == parent.left then
                return parent.right;
            else
                return parent.left;
            fi
        si

        TREE_MAP_NODE<K,V> uncle() is
            return parent.sibling();
        si

        String toString() is
            return new StringBuffer()
                .append(key)
                .append("=>")
                .append(value);
        si
    si

    /// Iterates over elements of a TREE_MAP<K,V> in order
    class TREE_MAP_ITERATOR<K,V> do Iterator<Pair<K,V>> is
        TREE_MAP_NODE<K,V> current;

        void init(TREE_MAP_NODE<K,V> root) is
            current = TREE_MAP<K,V>.minimum_tree_node(root);
        si

        bool hasMoreElements() is
            return current != null;
        si

        TREE_MAP_NODE<K,V> nextElement() is
            var result = current;
            current = successor(current);
            return result;
        si
   
        TREE_MAP_NODE<K,V> successor(TREE_MAP_NODE<K,V> x) is
            if x.right != null then
                return TREE_MAP<K,V>.minimum_tree_node(x.right);
            else
                var y = x.parent;
                while y != null && x == y.right do
                    x = y;
                    y = y.parent;
                od

                return y;
            fi
        si
    si

    /// Iterates over elements of a TREE_MAP<K,V> in reverse order
    class TREE_MAP_REVERSE_ITERATOR<K,V> do Iterator<Pair<K,V>> is
        TREE_MAP_NODE<K,V> current;

        void init(TREE_MAP_NODE<K,V> root) is
            current = TREE_MAP<K,V>.maximum_tree_node(root);
        si

        bool hasMoreElements() is
        return current != null;
    si

    TREE_MAP_NODE<K,V> nextElement() is
        var result = current;
    current = predecessor(current);
    return result;
    si
   
    TREE_MAP_NODE<K,V> predecessor(TREE_MAP_NODE<K,V> x) is
        if x.left != null then
            return TREE_MAP<K,V>.maximum_tree_node(x.left);
    else
        var y = x.parent;
        while y != null && x == y.left do
            x = y;
        y = y.parent;
        od

        return y;
    fi
    si

    get TREE_MAP_REVERSE_ITERATOR<K,V> Iterator is
        return this;
    si
si

/*   
class Main is
    void init() is
    var t = new TREE_MAP<int,String>();

    for int i = 0; i < 100; i = i + 1 do
        t[i] = "value: " + i;
    od

    IO.Std.out.println( "t is: " + t ); 

    foreach var i; t.ReversePairs do
        IO.Std.err.println( "have: " + i );
    od
    si
si
*/
si
