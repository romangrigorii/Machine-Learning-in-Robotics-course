# DOCUMENTATION
# =====================================
# Class node attributes:
# ----------------------------
# children - a list of 2 nodes if numeric, and a dictionary (key=attribute value, value=node) if nominal.
#            For numeric, the 0 index holds examples < the splitting_value, the
#            index holds examples >= the splitting value
#
# label - is None if there is a decision attribute, and is the output label (0 or 1 for
#	the homework data set) if there are no other attributes
#       to split on or the data is homogenous
#
# decision_attribute - the index of the decision attribute being split on
#
# is_nominal - is the decision attribute nominal
#
# value - Ignore (not used, output class if any goes in label)
#
# splitting_value - if numeric, where to split
#
# name - name of the attribute being split on

class Node:
    def __init__(self):
        # initialize all attributes
        self.label = None
        self.decision_attribute = None
        self.is_nominal = None
        self.value = None #ignored
        self.splitting_value = None
        self.children = {}
        self.name = None
        self.Keys = None

    def classify(self, instance):
        if self.label is None:
            if self.is_nominal:
                if instance[self.decision_attribute] in self.children:
                    return (self.children[instance[self.decision_attribute]]).classify(instance)
                return (self.children[self.value]).classify(instance)
            else:
                if instance[self.decision_attribute]<self.splitting_value:
                    return self.children[0].classify(instance)
                else:
                    return self.children[1].classify(instance)
        else:
            return self.label
	pass

    def print_tree(self, indent = 0):
        '''
        returns a string of the entire tree in human readable form
        IMPLEMENTING THIS FUNCTION IS OPTIONAL
        '''
        pass

    def print_dnf_tree(self):
        result = ''
        if self.is_nominal:
            Keys = list(self.Keys)
            for x in range(0, len(Keys)):
                if self.children[Keys[x]].label is None:
                    pdt = str(self.children[Keys[x]].print_dnf_tree())
                    if pdt is not (None or ''):
                        result = result + '(' + str(self.name) + '=' + str(Keys[x]) + '^(' + pdt + '))'
                    if x < (len(Keys)-1):
                        result = result + 'v'
                else:
                    if self.children[Keys[x]].label:
                        result = result + '(' + str(self.name) + '=' + str(Keys[x]) + ')'
                        if x < (len(Keys)-1):
                            result = result + 'v'
        else:
            if self.children[0].label is None:
                result = result + '(' + str(self.name) + '<' + str(self.splitting_value)
                pdt = self.children[0].print_dnf_tree()
                if pdt is not (None or '()' or '') and self.children[1].label == None:
                    result = result + '^' + str(pdt) + ')'
            else:
                if self.children[0] == 1:
                    result = result + '(' + str(self.name) + '<' + str(self.splitting_value) + ')'
            if (self.children[1].label and self.children[0].label) is (None or 1) :
                result = result + 'v'
            if self.children[1].label is None and (result[-1:] is not '^'):
                result = result + '(' + str(self.name) + '=>' + str(self.splitting_value)
                pdt = self.children[1].print_dnf_tree()
                if pdt is not (None or '()' or ''):
                    result = result + '^' + str(pdt) + ')'
            else:
                if self.children[1].label == 1:
                    result = result + '(' + str(self.name) + '=>' + str(self.splitting_value) + ')'
        return result
        pass
