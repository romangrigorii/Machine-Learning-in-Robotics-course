# DOCUMENTATION
# =====================================
# Class node attributes:
# ----------------------------
# children - dictionary containing the children where the key is child number (1,...,k) and the value is the actual node object
# if node has no children, self.children = None
# value - value at the node
#
#
# The values for bfs should be returned as simply a string of value space value space value. For example if the tree looks like the following:
#     5
#   2   3
#
# The tree data structure is a node with value 5, with a dictionary of children {1: b, 2: c} where b is a node with value 2 and c is a node with value 3.  Both b and c have children of None.
# The bfs traversal of the above tree should return the string '5 2 3'

class Node:
	def __init__(self):
		self.value = None
		self.children = None
	def get_value(self):
	    return self.value
	def get_children(self):
		return self.children

# ValsOnLevel takes root, which is a node with or without children, and n
# and returns the string value of the values of nodes at that level
# for example if the node we gave as input ha the following structure:
#             a
#			/  \
#		  b		c
#		/  \  /  \
#	  d    e f    g
# for n = 0, the returned value would be "a"
# for n = 1, the returned value would be "b c"
# for n = 2, the returned value would be "d e f g"

def ValsOnLevel(root, n):
	result = ''
	if root.get_value() is None: # at an empty node we want to return ''
			return result
	elif n is 0:
			return str(root.get_value()) + ' ' # at desired row we return node value
	else:
		if root.get_children() is None: # if a node has no children we stop
			return result
		else: # for a node that does have children, we recurse the function on n-1
			length = len(root.get_children()) + 1
			for x in range(1, length):
				result = result + str(ValsOnLevel(root.get_children()[x],n-1))
			return result

def breadth_first_search(root):
	result = ''
	n = 0
	out = ValsOnLevel(root, n)
	while out is not '':
		n = n + 1;
		result = result + out
		out = ValsOnLevel(root, n)
	result = result[:-1] # getting rid of last space
	return result


def tester():
    a = Node()
    a.value = 5
    b = Node()
    b.value = 7
    a.children = {1: b}
    c = Node()
    c.value = 1
    d = Node()
    d.value = 2
    e = Node()
    e.value = 3
    c.children = {1: d, 2: e}
    f = Node()
    f.value = 4
    g = Node()
    g.value = 5
    d.children= {1: f, 2: g}
    h = Node()
    h.value= 6
    i = Node()
    i.value= 7
    e.children = {1: h, 2: i}
    j = Node()
    j.value = 8
    k = Node()
    k.value = 9
    g.children = {1: j, 2:k}
    l = Node()
    l.value= 10
    i.children = {1: l}
    print str(a.get_value()) + ' should be 5.'
    print str(a.get_children()) + ' should be {1: ' + str(b) + '}.'
    print str(breadth_first_search(c)) + ' should be 5 7.'
tester()
