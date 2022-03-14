from node import Node
from ID3 import *
from operator import xor
from node import*

# Note, these functions are provided for your reference.  You will not be graded on their behavior,
# so you can implement them as you choose or not implement them at all if you want to use a different
# architecture for pruning.

def backProb(root,MAP,out):
    a = Node()
    a.label = out
    a.is_nominal = True
    if len(MAP) == 0:
        return root
    temp = Node()
    temp.children = {}
    temp.is_nominal = root.is_nominal
    temp.decision_attribute = root.decision_attribute
    temp.name = root.name
    temp.splitting_value = root.splitting_value
    temp.label = root.label
    temp.value = root.value
    if root.label is None:
        if root.is_nominal:
            Keys = root.Keys
            temp.Keys = root.Keys
            for x in range(0, len(Keys)):
                if Keys[x] == MAP[0]:
                    if len(MAP) == 1:
                        temp.children.update({Keys[x]: a})
                    else:
                        temp.children.update({Keys[x]: backProb(root.children[Keys[x]], MAP[-(len(MAP)-1):],out)})
                else:
                    temp.children.update({Keys[x]: root.children[Keys[x]]})
        else:
            if MAP[0] == 0:
                if len(MAP) == 1:
                    temp.children = [a, root.children[1]]
                else:
                    temp.children = [backProb(root.children[0], MAP[-(len(MAP)-1):],out), root.children[1]]
            else:
                if len(MAP) == 1:
                    temp.children = [root.children[0],a]
                else:
                    temp.children = [root.children[0],backProb(root.children[1], MAP[-(len(MAP)-1):],out)]
    else:
        return temp
    return temp

def check_error(root, MAP, validation_set):
    b2 = backProb(root,MAP,1)
    b3 = backProb(root,MAP,0)
    valid1 = validation_accuracy(root,validation_set)
    valid2 = validation_accuracy(b2,validation_set)
    valid3 = validation_accuracy(b3,validation_set)
    if valid1>valid2:
        if valid1>valid3:
            return root
        else:
            return b3
    else: return b2

def reduced_error_pruning(root,branch,MAP,validation_set):
    best_tree = check_error(root,MAP,validation_set)
    tempmap = MAP
    #print MAP
    if branch.label is None:
        if branch.is_nominal:
            Keys = branch.Keys
            if Keys is None or branch.label is not None:
                return best_tree
            for x in range(0, len(Keys)):
                tempmap.append(Keys[x])
                best_tree = reduced_error_pruning(best_tree,branch.children[Keys[x]],tempmap,validation_set)
                tempmap = tempmap[:len(MAP)]
        else:
            tempmap.append(1)
            best_tree = reduced_error_pruning(best_tree,branch.children[1],tempmap,validation_set)
            tempmap = tempmap[:len(MAP)]
            tempmap.append(0)
            best_tree = reduced_error_pruning(best_tree,branch.children[0],tempmap,validation_set)
    return best_tree

def Validation_Set_Fill(validation_set,attribute_metadata):
    Averages = []
    true_set = []
    length = len(validation_set)
    for x in range(0,len(attribute_metadata)):
        Averages.append(AverageVal(validation_set,x,attribute_metadata[x]['is_nominal']))
    for x in range(0,length):
        if len(validation_set[x]) == len(attribute_metadata):
            true_set.append(ReplaceNone(validation_set[x],Averages))
    return true_set

def PredictionsSet_Fill(prediction_set,attribute_metadata):
    Averages = []
    true_set = []
    length = len(prediction_set)
    for x in range(0,len(attribute_metadata)):
        Averages.append(AverageVal(prediction_set,x,attribute_metadata[x]['is_nominal']))
    for x in range(0,length):
        if len(prediction_set[x]) == len(attribute_metadata):
            true_set.append(ReplaceNone2(prediction_set[x],Averages))
    return true_set

def validation_accuracy(tree,validation_set):
    total_counts = 0
    length = len(validation_set)
    for x in range(0,length):
        if tree.classify(validation_set[x]) is validation_set[x][0]:
            total_counts += 1
    return float(total_counts)/float(length)
    pass
