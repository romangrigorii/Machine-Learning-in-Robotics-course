import math
from node import Node
import sys
def check_homogenous(data_set):
    '''
    ========================================================================================================
    Input:  A data_set
    ========================================================================================================
    Job:    Checks if the output value (index 0) is the same for all examples in the the data_set, if so return that output value, otherwise return None.
    ========================================================================================================
    Output: Return either the homogenous attribute or None
    ========================================================================================================
     '''
    length = len(data_set)
    if length == 0:
        return None
    for x in range(0, length):
        if data_set[0][0] != data_set[x][0]:
            return None
    return data_set[0][0]

# ======== Test Cases =============================
# data_set = [[0],[1],[1],[1],[1],[1]]
# check_homogenous(data_set) ==  None
# data_set = [[0],[1],[None],[0]]
# check_homogenous(data_set) ==  None
# data_set = [[1],[1],[1],[1],[1],[1]]
# check_homogenous(data_set) ==  1

def mode(data_set):
    '''
    ========================================================================================================
    Input:  A data_set
    ========================================================================================================
    Job:    Takes a data_set and finds mode of index 0.
    ========================================================================================================
    Output: mode of index 0.
    ========================================================================================================
    '''
    length = len(data_set)
    total = 0
    for x in range(0, length):
        if data_set[x][0] is not None:
            total = total + data_set[x][0]
    if float(length)/2 < float(total):
        return 1
    else:
        return 0
    pass

# ======== Test case =============================
#data_set = [[0],[1],[1],[1],[1],[1]]
#print mode(data_set) == 1
#data_set = [[0],[1],[0],[0]]
#print mode(data_set) == 0

def entropy(data_set):
    '''
    ========================================================================================================
    Input:  A data_set
    ========================================================================================================
    Job:    Calculates the entropy of the attribute at the 0th index, the value we want to predict.
    ========================================================================================================
    Output: Returns entropy. See Textbook for formula
    ========================================================================================================
    '''
    pos = 0;
    neg = 0;
    length = len(data_set)
    for x in range(0, length):
        if data_set[0][0] == data_set[x][0]:
            pos += 1
        else: neg += 1
    if neg == 0:
        logn = 0.0
    else: logn = float(neg)/float(length)*math.log10(float(neg)/float(length))
    if pos == 0:
        logp = 0.0
    else: logp = float(pos)/float(length)*math.log10(float(pos)/float(length))
    return - (logn + logp)/(math.log10(2.0))
# ======== Test case =============================
# data_set = [[0],[1],[1],[1],[0],[1],[1],[1]]
# entropy(data_set) == 0.811
# data_set = [[0],[0],[1],[1],[0],[1],[1],[0]]
# entropy(data_set) == 1.0
# data_set = [[0],[0],[0],[0],[0],[0],[0],[0]]
# entropy(data_set) == 0


def split_on_nominal(data_set, attribute):
    '''
    ========================================================================================================
    Input:  subset of data set, the index for a nominal attribute.
    ========================================================================================================
    Job:    Creates a dictionary of all values of the attribute.
    ========================================================================================================
    Output: Dictionary of all values pointing to a list of all the data with that attribute
    ========================================================================================================
    '''
    length = len(data_set)
    atr_val = 0;
    total_length = 0;
    data_set_split = {};
    set_of_attr = [];
    ModeLen = 0
    ModeAtt = 0
    missing_vars = False
    for x in range(0,length):
        set_of_attr.append(data_set[x][attribute])
    set_of_attr = list(set(set_of_attr))
    if None in set_of_attr:
        missing_vars = True
    current_data_set = []
    while total_length < length:
        for x in range(0, length):
            if data_set[x][attribute] == set_of_attr[atr_val]:
                total_length += 1
                current_data_set.append(data_set[x])
        if current_data_set != []:
            if len(current_data_set)>ModeLen:
                ModeLen = len(current_data_set)
                ModeAtt = set_of_attr[atr_val]
            data_set_split.update({set_of_attr[atr_val]: current_data_set})
        current_data_set = []
        atr_val += 1
    if missing_vars:
        data_set_split.update({ModeAtt: data_set_split[None] + data_set_split[ModeAtt]})
        data_set_split.pop(None)
    return data_set_split
    pass

# ======== Test case =============================
#data_set, attr = [[0, 4], [1, 3], [1, 2], [0, 0], [0, 0], [0, 4], [1, 4], [0, 2], [1, 2], [0, 1]], 1
#split_on_nominal(data_set, attr) == {0: [[0, 0], [0, 0]], 1: [[0, 1]], 2: [[1, 2], [0, 2], [1, 2]], 3: [[1, 3]], 4: [[0, 4], [0, 4], [1, 4]]}
#data_set, attr = [[1, 2], [1, 0], [0, 1], [1, 3], [0, 2], [0, 3], [0, 4], [0, 4], [1, 2], [0, 0]], 1
#print str(split_on_nominal(data_set, attr))
#data_set == {0: [[1, 0], [0, 0]], 1: [[0, 1]], 2: [[1, 2], [0, 2], [1, 2]], 3: [[1, 3], [0, 3]], 4: [[0, 4], [0, 4]]}
#data_set, attr = [[0, 4], [1, 3], [1, 2], [0, None], [0, 0], [0, 4], [1, None], [0, 0], [1, 2], [0, 2]], 1
#print str(split_on_nominal(data_set,attr))

def AverageVal(data_set, attribute, nominal):
    average = 0
    if nominal:
        Keys = []
        for x in range(0,len(data_set)):
            if data_set[x][attribute] is not None:
                Keys.append(data_set[x][attribute])
        Keys = list(set(Keys))
        data_split = split_on_nominal(data_set,attribute)
        Max = 0;
        for x in range(0, len(Keys)):
            if len(data_split[Keys[x]]) > Max:
                Max = len(data_split[Keys[x]])
                average = Keys[x]
    else:
        total = 0.0
        for x in range(0,len(data_set)):
            if data_set[x][attribute] is not None:
                total = total + data_set[x][attribute]
        average = float(total)/float(len(data_set))
    return average

#dataset = [[0, 4], [1, 3], [1, 2], [0, 0], [0, None], [0, 4], [1, 4], [0, 2], [1, 2], [0, 1]]
#print AverageVal(dataset,1, False)

def ReplaceNone(instance,list_average):
    out_instance = []
    for x in range(0,len(instance)):
        if instance[x] is not None:
            out_instance.append(instance[x])
        else:
            out_instance.append(list_average[x])
    return out_instance

def ReplaceNone2(instance,list_average):
    out_instance = [instance[0]]
    for x in range(1,len(instance)):
        if instance[x] is not None:
            out_instance.append(instance[x])
        else:
            out_instance.append(list_average[x])
    return out_instance

def split_on_numerical(data_set, attribute, splitting_value):
    '''
    ========================================================================================================
    Input:  Subset of data set, the index for a numeric attribute, threshold (splitting) value
    ========================================================================================================
    Job:    Splits data_set into a tuple of two lists, the first list contains the examples where the given
	attribute has value less than the splitting value, the second list contains the other examples
    ========================================================================================================
    Output: Tuple of two lists as described above
    ========================================================================================================
    '''
    length = len(data_set)
    left_list=[]
    right_list=[]
    unknown_list=[]
    total_att_val = 0
    for x in range(0, length):
        if data_set[x][attribute] is None :
             unknown_list.append(data_set[x])
        else:
            total_att_val = total_att_val + data_set[x][attribute]/float(length)
            if data_set[x][attribute] < splitting_value:
                left_list.append(data_set[x])
            else:
                right_list.append(data_set[x])
    if total_att_val < splitting_value:
        left_list = left_list + unknown_list
    else:
        right_list = right_list + unknown_list
    return left_list,right_list
    pass
# ======== Test case =============================
# d_set,a,sval = [[1, 0.25], [1, None], [0, 0.93], [0, 0.48], [1, 0.19], [1, 0.49], [0, 0.6], [0, 0.6], [1, 0.34], [1, 0.19]],1,0.48
# print split_on_numerical(d_set,a,sval)
#split_on_numerical(d_set,a,sval) == ([[1, 0.25], [1, 0.19], [1, 0.34], [1, 0.19]],[[1, 0.89], [0, 0.93], [0, 0.48], [1, 0.49], [0, 0.6], [0, 0.6]])
#d_set,a,sval = [[0, 0.91], [0, 0.84], [1, 0.82], [1, 0.07], [0, 0.82],[0, 0.59], [0, 0.87], [0, 0.17], [1, 0.05], [1, 0.76]],1,0.17
#split_on_numerical(d_set,a,sval) == ([[1, 0.07], [1, 0.05]],[[0, 0.91],[0, 0.84], [1, 0.82], [0, 0.82], [0, 0.59], [0, 0.87], [0, 0.17], [1, 0.76]])
#d_set,a,sval = [[0, 0.91], [0, 0.84], [1, 0.82], [1, 0.07], [0, 0.82],[0, 0.59], [0, None], [0, 0.17], [1, 0.05], [1, 0.76]],1,0.17
#print split_on_numerical(d_set,a,sval)

def gain_ratio_nominal(data_set, attribute):
    '''
    ========================================================================================================
    Input:  Subset of data_set, index for a nominal attribute
    ========================================================================================================
    Job:    Finds the gain ratio of a nominal attribute in relation to the variable we are training on.
    ========================================================================================================
    Output: Returns gain_ratio. See https://en.wikipedia.org/wiki/Information_gain_ratio
    ========================================================================================================
    '''
    length = len(data_set)
    thined_data_set = []
    for x in range (0, length):
        thined_data_set.append([data_set[x][0],data_set[x][attribute]])
    IG = entropy(thined_data_set)
    IV = 0;
    atr = 0;
    total_length = 0;
    data_set_split = split_on_nominal(data_set,attribute)
    current_data_set = []
    set_of_attr = []
    for x in range(0,length):
        set_of_attr.append(data_set[x][attribute])
    set_of_attr = list(set(set_of_attr))
    for x in range(0, len(set_of_attr)):
        if set_of_attr[x] != None:
            xEx = float(len(data_set_split[set_of_attr[x]]))/float(length)
            IG = IG - xEx*entropy(data_set_split[set_of_attr[x]])
            IV = IV - xEx*math.log10(xEx)
    IV /= math.log10(2.000)
    if IV == 0:
        return 0
    return IG/IV
    pass
# ======== Test case =============================
# data_set, attr = [[1, 2], [1, 0], [1, 0], [0, 2], [0, 2], [0, 0], [1, 3], [0, 4], [0, 3], [1, 1]], 1
# gain_ratio_nominal(data_set,attr) == 0.11470666361703151
# data_set, attr = [[1, 2], [1, 2], [0, 4], [0, 0], [0, 1], [0, 3], [0, 0], [0, 0], [0, 4], [0, 2]], 1
# gain_ratio_nominal(data_set,attr) == 0.2056423328155741
# data_set, attr = [[0, 3], [0, 3], [0, 3], [0, 4], [0, 4], [0, 4], [0, 0], [0, 2], [1, 4], [0, 4]], 1
# print gain_ratio_nominal(data_set,attr) == 0.06409559743967516
# print str(gain_ratio_nominal([[0, 3], [0, 3], [0, 3], [0, 4], [0, 4], [0, 4], [0, 0], [0, 2], [1, 4], [0, 4]], 1))

def gain_ratio_numeric(data_set, attribute, steps):
    '''
    ========================================================================================================
    Input:  Subset of data set, the index for a numeric attribute, and a step size for normalizing the data.
    ========================================================================================================
    Job:    Calculate the gain_ratio_numeric and find the best single threshold value
            The threshold will be used to split examples into two sets
                 those with attribute value GREATER THAN OR EQUAL TO threshold
                 those with attribute value LESS THAN threshold
            Use the equation here: https://en.wikipedia.org/wiki/Information_gain_ratio
            And restrict your search for possible thresholds to examples with array index mod(step) == 0
    ========================================================================================================
    Output: This function returns the gain ratio and threshold value
    ========================================================================================================
    '''
    length = len(data_set)
    thined_data_set = []
    for x in range (0, length):
        thined_data_set.append([data_set[x][0],data_set[x][attribute]])
    max_IGR = 0
    max_split = 0
    y = 0
    while y < length:
        IG = entropy(thined_data_set)
        IV = 0
        split_val = thined_data_set[y][1]
        if split_val == None:
            y += 1
        else:
            data_set_split = list(split_on_numerical(data_set,attribute,split_val))
            xExL = float(len(data_set_split[0]))/float(length)
            xExR = float(len(data_set_split[1]))/float(length)
            IG = IG - xExL*entropy(data_set_split[0]) - xExR*entropy(data_set_split[1])
            if not (xExL==0 or xExR==0):
                IV = IV - xExL*math.log10(xExL) - xExR*math.log10(xExR)
                IV /= math.log10(2.000)
                if max_IGR < IG/IV:
                    max_IGR = IG/IV
                    max_split = split_val
            y += steps
    return max_IGR, max_split
    pass
# ======== Test case =============================
# data_set,attr,step = [[0,0.05], [1,0.17], [1,0.64], [0,0.38], [0,0.19], [1,0.68], [1,0.69], [1,0.17], [1,0.4], [0,0.53]], 1, 2
# print gain_ratio_numeric(data_set,attr,step) == (0.31918053332474033, 0.64)
# data_set,attr,step = [[1, 0.35], [1, 0.24], [0, 0.67], [0, 0.36], [1, 0.94], [1, 0.4], [1, 0.15], [0, 0.1], [1, 0.61], [1, 0.17]], 1, 4
# print gain_ratio_numeric(data_set,attr,step) =  == (0.11689800358692547, 0.94))
# data_set,attr,step = [[1, 0.1], [0, 0.29], [1, 0.03], [0, 0.47], [1, 0.25], [1, 0.12], [1, 0.67], [1, 0.73], [1, 0.85], [1, 0.25]], 1, 1
# print gain_ratio_numeric(data_set,attr,step) == (0.23645279766002802, 0.29)

def pick_best_attribute(data_set, attribute_metadata, numerical_splits_count):
    '''
    ========================================================================================================
    Input:  A data_set, attribute_metadata, splits counts for numeric
    ========================================================================================================
    Job:    Find the attribute that maximizes the gain ratio. If attribute is numeric return best split value.
            If nominal, then split value is False.
            If gain ratio of all the attributes is 0, then return False, False
            Only consider numeric splits for which numerical_splits_count is greater than zero
    ========================================================================================================
    Output: best attribute, split value if numeric
    ========================================================================================================
    '''
    LenAtt = len(attribute_metadata)
    GRMax = 0
    ATRbest = 0
    SplitVal = False
    for x in range(1, LenAtt):
        if attribute_metadata[x]['is_nominal']:
            GRcurrent = gain_ratio_nominal(data_set,x)
            if GRcurrent > GRMax:
                GRMax = GRcurrent
                ATRbest = x
        elif numerical_splits_count[x]>0:
            GRN = list(gain_ratio_numeric(data_set,x,1))
            GRcurrent = GRN[0]
            if GRcurrent > GRMax:
                GRMax = GRcurrent
                ATRbest = x
                SplitVal = GRN[1]
    if GRMax == 0:
        return False, False
    return ATRbest, SplitVal
    pass

# # ======== Test Cases =============================
#numerical_splits_count = [20,20]
# attribute_metadata = [{'name': "winner",'is_nominal': True},{'name': "opprundifferential",'is_nominal': False}]
# data_set = [[1, 0.27], [0, 0.42], [0, 0.86], [0, 0.68], [0, 0.04], [1, 0.01], [1, 0.33], [1, 0.42], [0, 0.51], [1, 0.4]]
# print pick_best_attribute(data_set, attribute_metadata, numerical_splits_count) == (1, 0.51)
# attribute_metadata = [{'name': "winner",'is_nominal': True},{'name': "weather",'is_nominal': True}]
# data_set = [[0, 0], [1, 0], [0, 2], [0, 2], [0, 3], [1, 1], [0, 4], [0, 2], [1, 2], [1, 5]]
# print pick_best_attribute(data_set, attribute_metadata, numerical_splits_count) == (1, False)
# Uses gain_ratio_nominal or gain_ratio_numeric to calculate gain ratio.


def split_count_decrement(numerical_splits_count, attribute):
    if attribute>=len(numerical_splits_count):
        return False
    out = []
    out.extend(numerical_splits_count[0:attribute])
    out.append(numerical_splits_count[attribute]-1)
    out.extend(numerical_splits_count[attribute+1:len(numerical_splits_count)])
    return out

def shiftedSet(dataSet):
    if dataSet[0] == []:
        return 'rs'
    elif dataSet[1] ==[]:
        return 'ls'
    else:
        return False
def ID3(data_set, attribute_metadata, numerical_splits_count, depth):
    nominality = [True,False,False,True,False,False,False,True,True,False,False,True,False,False]
    '''
    See Textbook for algorithm.
    Make sure to handle unknown values, some suggested approaches were
    given in lecture.
    ========================================================================================================
    Input:  A data_set, attribute_metadata, maximum number of splits to consider for numerical attributes,
	maximum depth to search to (depth = 0 indicates that this node should output a label)
    ========================================================================================================
    Output: The node representing the decision tree learned over the given data set
    ========================================================================================================
    '''
    root = Node()
    len1 = len(data_set)
    len2 = len(attribute_metadata)
    homogenous = check_homogenous(data_set)
    root.is_nominal = True #root is nominal until shown otherwise
    if homogenous != None:
        root.label = homogenous
        return root
    if depth == 0:
        root.label = mode(data_set)
        return root
    else:
        FindBest = list(pick_best_attribute(data_set,attribute_metadata,numerical_splits_count))
        BestAtt = FindBest[0]
        SplitVal = FindBest[1]
        if (BestAtt==False and SplitVal==False):
            root.label = mode(data_set)
            return root
        else:
            root.is_nominal = attribute_metadata[BestAtt]['is_nominal']
            root.decision_attribute = BestAtt
            root.name = attribute_metadata[BestAtt]['name']
            split_count = numerical_splits_count
            if root.is_nominal == True:
                Keys = []
                for x in range(0,len1):
                    if data_set[x][BestAtt] is not None:
                        Keys.append(data_set[x][BestAtt])
                Keys = list(set(Keys))
                root.Keys = Keys
                datasplit = split_on_nominal(data_set, BestAtt)
                root.value = 0
                for x in range (0,len(Keys)):
                    if root.value < len(datasplit[Keys[x]]):
                        root.value = Keys[x]
                for x in range(0,len(Keys)):
                    root.children.update({Keys[x]:ID3(datasplit[Keys[x]],attribute_metadata,numerical_splits_count,depth-1)})
            else:
                datasplit = list(split_on_numerical(data_set, BestAtt, SplitVal))
                if datasplit[0] == []:
                    root.label = mode(datasplit[1])
                    return root
                elif datasplit[1] == []:
                    root.label = mode(datasplit[0])
                    return root
                root.splitting_value = SplitVal
                split_count = split_count_decrement(split_count,BestAtt)
                root.children = [ID3(datasplit[0], attribute_metadata, split_count, depth-1),
                ID3(datasplit[1], attribute_metadata, split_count, depth-1)]
    return root
    pass
