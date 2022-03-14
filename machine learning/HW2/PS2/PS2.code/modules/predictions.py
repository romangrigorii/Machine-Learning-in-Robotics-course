import os.path
from operator import xor
from parse import *
from pruning import *
# DOCUMENTATION
# ========================================
# this function outputs predictions for a given data set.
# NOTE this function is provided only for reference.
# You will not be graded on the details of this function, so you can change the interface if
# you choose, or not complete this function at all if you want to use a different method for
# generating predictions.

def create_predictions(tree, predict):
    '''
    Given a tree and a url to a data_set. Create a csv with a prediction for each result (called 'PS2.csv in current directory)
    using the classify method in node class.
    '''
    test_set, attribute_metadata = parse(predict, True)
    headers = []
    test_set = PredictionsSet_Fill(test_set,attribute_metadata)
    for i in attribute_metadata:
        headers.append(i['name'])
    del headers[0]
    headers.append('winner')
    c = csv.writer(open("PS2.csv", "wb"))
    c.writerow(headers)
    winner= []
    for x in test_set:
        winner.append(tree.classify(x))
    for index in range(len(test_set)):
        test_set[index].append(winner[index])
        del test_set[index][0]
        c.writerow(test_set[index])
    
