#K

// L version of this code Copyright 2010 <degs@giantblob.com>
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

namespace Generic is

use System.String;
use System.StringBuffer;

/// tree node color for red-black tree
enum NodeColor is RED, BLACK si

/// An associative array that is naturally sorted
/// \param K type of keys in the Map. K must implement int operator>(K,K)
/// \param V type of values in the Map.
class SortedMap<K,V> do Dict<K,V> is
    public TreeNode<K,V> root;

    /// Construct an empty SortedMap<K,V>
    void init() is
        root = null;
    si

    /// Internal method
    private static NodeColor nodeNodeColor(TreeNode<K,V> n) is
	if n == null then
	    return NodeColor.BLACK;
	fi
        return n.color;
    si

    /// Internal method
    private TreeNode<K,V> lookupTreeNode(K key) is
        TreeNode<K,V> n = root;
        while n != null do
            int compResult = key.opCompare(n.key);
            if compResult == 0 then
                return n;
            elif compResult < 0 then
                n = n.left;
            else
                n = n.right;
            fi
        od
        return n;
    si

    bool contains(K key) is
        TreeNode<K,V> n = lookupTreeNode(key);
	return n != null;
    si

    get V[K key] is
        TreeNode<K,V> n = lookupTreeNode(key);
	if n == null then
	    return V.none;
	fi
	return n.value;
    si

    private void rotateLeft(TreeNode<K,V> n) is
        TreeNode<K,V> r = n.right;
        replaceTreeNode(n, r);
        n.right = r.left;
        if r.left != null then
            r.left.parent = n;
        fi
        r.left = n;
        n.parent = r;
    si

    private void rotateRight(TreeNode<K,V> n) is
        TreeNode<K,V> l = n.left;
        replaceTreeNode(n, l);
        n.left = l.right;
        if l.right != null then
            l.right.parent = n;
        fi
        l.right = n;
        n.parent = l;
    si

    private void replaceTreeNode(TreeNode<K,V> oldn, TreeNode<K,V> newn) is
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
        TreeNode<K,V> insertedTreeNode = new TreeNode<K,V>(key, value, NodeColor.RED, null, null);
        if root == null then
            root = insertedTreeNode;
        else
            TreeNode<K,V> n = root;
            do
                int compResult = key.opCompare(n.key);
                if compResult == 0 then
                    n.value = value;
                    return;
                elif compResult < 0 then
                    if n.left == null then
                        n.left = insertedTreeNode;
                        break;
                    else
                        n = n.left;
                    fi
                else
                    if n.right == null then
                        n.right = insertedTreeNode;
                        break;
                    else
                        n = n.right;
                    fi
                fi
            od
            insertedTreeNode.parent = n;
        fi
        insertCase1(insertedTreeNode);
    si

    private void insertCase1(TreeNode<K,V> n) is
        if n.parent == null then
            n.color = NodeColor.BLACK;
        else
            insertCase2(n);
	fi
    si

    private void insertCase2(TreeNode<K,V> n) is
        if nodeNodeColor(n.parent) == NodeColor.BLACK then
            return; // Tree is still valid
        else
            insertCase3(n);
        fi
    si

    void insertCase3(TreeNode<K,V> n) is
        if nodeNodeColor(n.uncle()) == NodeColor.RED then
            n.parent.color = NodeColor.BLACK;
            n.uncle().color = NodeColor.BLACK;
            n.grandparent().color = NodeColor.RED;
            insertCase1(n.grandparent());
        else
            insertCase4(n);
        fi
    si

    void insertCase4(TreeNode<K,V> n) is
        if n == n.parent.right && n.parent == n.grandparent().left then
            rotateLeft(n.parent);
            n = n.left;
        elif n == n.parent.left && n.parent == n.grandparent().right then
            rotateRight(n.parent);
            n = n.right;
        fi
        insertCase5(n);
    si

    void insertCase5(TreeNode<K,V> n) is
        n.parent.color = NodeColor.BLACK;
        n.grandparent().color = NodeColor.RED;
        if n == n.parent.left && n.parent == n.grandparent().left then
            rotateRight(n.grandparent());
        else
            rotateLeft(n.grandparent());
        fi
    si

    V remove(K key) is
        TreeNode<K,V> n = lookupTreeNode(key);
        if n == null then
            return V.none;  // Key not found, do nothing
	fi

        var result = n.value;

        if n.left != null && n.right != null then
            // Copy key/value from predecessor and then delete it instead
            TreeNode<K,V> pred = maximumTreeNode(n.left);
            n.key   = pred.key;
            n.value = pred.value;
            n = pred;
        fi

        TreeNode<K,V> child;
	if n.right == null then
	    child = n.left;
	else
	    child = n.right;
	fi

        if nodeNodeColor(n) == NodeColor.BLACK then
            n.color = nodeNodeColor(child);
            deleteCase1(n);
        fi

        replaceTreeNode(n, child);
        
        if nodeNodeColor(root) == NodeColor.RED then
            root.color = NodeColor.BLACK;
        fi	

        return result;
    si

    static TreeNode<K,V> minimumTreeNode(TreeNode<K,V> n) is
        while n.left != null do
	    n = n.left;
	od

	return n;
    si

   static TreeNode<K,V> maximumTreeNode(TreeNode<K,V> n) is
        while n.right != null do
            n = n.right;
        od
        return n;
    si

    private void deleteCase1(TreeNode<K,V> n) is
        if n.parent == null then
            return;
        else
            deleteCase2(n);
	fi
    si

    private void deleteCase2(TreeNode<K,V> n) is
        if nodeNodeColor(n.sibling()) == NodeColor.RED then
            n.parent.color = NodeColor.RED;
            n.sibling().color = NodeColor.BLACK;
            if n == n.parent.left then
                rotateLeft(n.parent);
            else
                rotateRight(n.parent);
            fi
        fi
        deleteCase3(n);
    si

    private void deleteCase3(TreeNode<K,V> n) is
        if nodeNodeColor(n.parent) == NodeColor.BLACK &&
            nodeNodeColor(n.sibling()) == NodeColor.BLACK &&
            nodeNodeColor(n.sibling().left) == NodeColor.BLACK &&
            nodeNodeColor(n.sibling().right) == NodeColor.BLACK
        then
            n.sibling().color = NodeColor.RED;
            deleteCase1(n.parent);
        else
            deleteCase4(n);
	fi
    si

    private void deleteCase4(TreeNode<K,V> n) is
        if nodeNodeColor(n.parent) == NodeColor.RED &&
            nodeNodeColor(n.sibling()) == NodeColor.BLACK &&
            nodeNodeColor(n.sibling().left) == NodeColor.BLACK &&
            nodeNodeColor(n.sibling().right) == NodeColor.BLACK
        then
            n.sibling().color = NodeColor.RED;
            n.parent.color = NodeColor.BLACK;
        else
            deleteCase5(n);
	fi
    si

    private void deleteCase5(TreeNode<K,V> n) is
        if n == n.parent.left &&
            nodeNodeColor(n.sibling()) == NodeColor.BLACK &&
            nodeNodeColor(n.sibling().left) == NodeColor.RED &&
            nodeNodeColor(n.sibling().right) == NodeColor.BLACK
        then
            n.sibling().color = NodeColor.RED;
            n.sibling().left.color = NodeColor.BLACK;
            rotateRight(n.sibling());
        elif n == n.parent.right &&
            nodeNodeColor(n.sibling()) == NodeColor.BLACK &&
            nodeNodeColor(n.sibling().right) == NodeColor.RED &&
            nodeNodeColor(n.sibling().left) == NodeColor.BLACK
        then
            n.sibling().color = NodeColor.RED;
            n.sibling().right.color = NodeColor.BLACK;
            rotateLeft(n.sibling());
        fi
        deleteCase6(n);
    si

    private void deleteCase6(TreeNode<K,V> n) is
        n.sibling().color = nodeNodeColor(n.parent);
        n.parent.color = NodeColor.BLACK;
        if n == n.parent.left then
            n.sibling().right.color = NodeColor.BLACK;
            rotateLeft(n.parent);
        else
            n.sibling().left.color = NodeColor.BLACK;
            rotateRight(n.parent);
	fi
    si

    String toString() is
	var buffer = new System.StringBuffer();
        toString(root, buffer);
	return buffer;
    si

    bool isEmpty() is
	return root == null;
    si

    void clear() is
        root = null;
    si

    get int Length is
        return length(root);
    si

    private static int length(TreeNode<K,V> n) is
      	if n == null then
	    return 0;
	else
	    return this(n.left) + this(n.right);
	fi
    si

    private static void toString(TreeNode<K,V> n, StringBuffer b) is
        if n == null then
            b.append("()");
            return;
	fi

	b.append('(');

	b.append( n );

        if n.left != null then
	    b.append(',');
            toString(n.left, b);
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

    get SortedMapIterator<K,V> Pairs is
        return new SortedMapIterator<K,V>(root);
    si

    get SortedMapReverseIterator<K,V> ReversePairs is
        return new SortedMapReverseIterator<K,V>(root);
    si

    get PairKeyIterator<K,V> Keys is
        return new PairKeyIterator<K,V>(Pairs);
    si

    get PairValueIterator<K,V> Iterator is
        return new PairValueIterator<K,V>(Pairs);
    si
si

/// A node in the SortedMap<K,V> Red-black tree 
class TreeNode<K,V> isa Pair<K,V> is
    public K key;
    public V value;
    public TreeNode<K,V> left;
    public TreeNode<K,V> right;
    public TreeNode<K,V> parent;
    public NodeColor color;

    void init(K key, V value, NodeColor nodeNodeColor, TreeNode<K,V> left, TreeNode<K,V> right) is
        this.key = key;
        this.value = value;
        this.color = nodeNodeColor;
        this.left = left;
        this.right = right;
        if left  != null then
	    left.parent = this;
	fi
        if right != null then
	    right.parent = this;
	fi
        this.parent = null;
    si

    TreeNode<K,V> grandparent() is
        return parent.parent;
    si

    TreeNode<K,V> sibling() is
        if this == parent.left then
            return parent.right;
        else
            return parent.left;
        fi
    si

    TreeNode<K,V> uncle() is
        return parent.sibling();
    si

    String toString() is
    	return new StringBuffer()
	    .append(key)
	    .append("=>")
	    .append(value);
    si
si

/// Iterates over elements of a SortedMap<K,V> in order
class SortedMapIterator<K,V> do Iterator<Pair<K,V>> is
    TreeNode<K,V> current;

    void init(TreeNode<K,V> root) is
        current = SortedMap<K,V>.minimumTreeNode(root);
    si

    bool hasMoreElements() is
        return current != null;
    si

    TreeNode<K,V> nextElement() is
        var result = current;
	current = successor(current);
	return result;
    si
   
    TreeNode<K,V> successor(TreeNode<K,V> x) is
        if x.right != null then
            return SortedMap<K,V>.minimumTreeNode(x.right);
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

/// Iterates over elements of a SortedMap<K,V> in reverse order
class SortedMapReverseIterator<K,V> do Iterator<Pair<K,V>> is
    TreeNode<K,V> current;

    void init(TreeNode<K,V> root) is
        current = SortedMap<K,V>.maximumTreeNode(root);
    si

    bool hasMoreElements() is
        return current != null;
    si

    TreeNode<K,V> nextElement() is
        var result = current;
	current = predecessor(current);
	return result;
    si
   
    TreeNode<K,V> predecessor(TreeNode<K,V> x) is
        if x.left != null then
            return SortedMap<K,V>.maximumTreeNode(x.left);
	else
	    var y = x.parent;
	    while y != null && x == y.left do
	        x = y;
		y = y.parent;
	    od

	    return y;
	fi
    si
si

/*	 
class Main is
    void init() is
	var t = new SortedMap<int,String>();

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