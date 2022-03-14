from random import shuffle
from ID3 import *
from operator import xor
from parse import parse
from modules.pruning import *
#import matplotlib.pyplot as plt
import os.path
from pruning import validation_accuracy
import random

# NOTE: these functions are just for your reference, you will NOT be graded on their output
# so you can feel free to implement them as you choose, or not implement them at all if you want
# to use an entirely different method for graphing

def get_graph_accuracy_partial(train_set, attribute_metadata, validate_set, numerical_splits_count, pct):
    '''
    get_graph_accuracy_partial - Given a training set, attribute metadata, validation set, numerical splits count, and percentage,
    this function will return the validation accuracy of a specified (percentage) portion of the trainging setself.
    '''
    depth = 20
    length = len(train_set)
    num = int(float(pct)*float(length/100.0))
    TS = train_set[0:num]
    tree = ID3(TS, attribute_metadata, numerical_splits_count, depth)
    return validation_accuracy(tree,validate_set)

    pass
def get_graph_data(train_set, attribute_metadata, validate_set, numerical_splits_count, iterations, pcts):
    '''
    Given a training set, attribute metadata, validation set, numerical splits count, iterations, and percentages,
    this function will return an array of the averaged graph accuracy partials based off the number of iterations.
    '''
    out = []
    total = 0
    u = train_set
    for x in range(0, len(pcts)):
        for y in range(0,iterations):
            random.shuffle(u)
            total = total + get_graph_accuracy_partial(u, attribute_metadata, validate_set, numerical_splits_count, pcts[x])
        out.append(total/float(iterations))
        total = 0
    return out
    pass

# get_graph will plot the points of the results from get_graph_data and return a graph
def get_graph(train_set, attribute_metadata, validate_set, numerical_splits_count, depth, iterations, lower, upper, increment):
    '''
    get_graph - Given a training set, attribute metadata, validation set, numerical splits count, depth, iterations, lower(range),
    upper(range), and increment, this function will graph the results from get_graph_data in reference to the drange
    percentages of the data.
    '''
    # I used excel to plot my data, because matplotlib would not work on my pc
    pass
