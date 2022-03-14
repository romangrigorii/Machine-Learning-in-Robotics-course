from modules.ID3 import *
from modules.parse import *
from modules.pruning import *
from modules.graph import *
from modules.predictions import *
import random
from random import shuffle

# DOCUMENATION
# ===========================================
# decision tree driver - takes a dictionary of options and runs the ID3 algorithm.
#   Supports numerical attributes as well as missing attributes. Documentation on the
#   options can be found in README.md

options = {
    'train' : 'data/btrain.csv',
    'validate': 'data/bvalidate.csv',
    'predict': 'data/btest.csv',
    'limit_splits_on_numerical': 30,
    'limit_depth': 20,
    'print_tree': False,
    'print_dnf' : True,
    'prune' : 'data/bvalidate.csv',
    'learning_curve' : {
        'upper_bound' : 0.05,
        'increment' : 0.001
    }
}

def decision_tree_driver(train, validate = False, predict = False, prune = False,
    limit_splits_on_numerical = False, limit_depth = False, print_tree = False,
    print_dnf = False, learning_curve = False):
    train_set, attribute_metadata = parse(train, 1)
    if limit_splits_on_numerical != False:
        numerical_splits_count = [limit_splits_on_numerical] * len(attribute_metadata)
        print str(numerical_splits_count)
    else:
        numerical_splits_count = [float("inf")] * len(attribute_metadata)
    if limit_depth != False:
        depth = limit_depth
    else:
        depth = float("inf")
    print "###\n#  Training Tree\n###"
    #call the ID3 classification algorithm with the appropriate options
    tree = ID3(train_set, attribute_metadata, numerical_splits_count, depth)
    print '\n'
    # call reduced error pruning using the pruning set\
    pruning_set, _ = parse(prune, False)
    pruning_set = Validation_Set_Fill(pruning_set,attribute_metadata)
    print "Unpruned tree validation accuracy is" + str(validation_accuracy(tree,pruning_set))
    if prune != False:
        print '###\n#  Pruning\n###'
        pruned_tree = reduced_error_pruning(tree,tree,[1,0,1,0],pruning_set)
        print "Pruned tree validation accuracy is " + str(validation_accuracy(pruned_tree,pruning_set))
        print ''
    if print_tree:
        print '###\n#  Decision Tree\n###'
        cursor = open('./output/tree.txt','w+')
        cursor.write(tree.print_tree())
        cursor.close()
        print 'Decision Tree written to /output/tree'
        print ''
    # print tree in disjunctive normalized form
    if print_dnf:
         print '###\n#  Decision Tree as DNF\n###'
         cursor = open('./output/DNF.txt','w+')
         cursor.write(tree.print_dnf_tree())
         cursor.close()
         print 'Decision Tree written to /output/DNF'
         print ''

    # # test tree accuracy on validation set
    if validate != False:
         print '###\n#  Validating\n###'
         validate_set, _ = parse(validate, False)
         accuracy = validation_accuracy(tree,validate_set)
         validate_set =  Validation_Set_Fill(pruning_set,attribute_metadata)
         print "Accuracy on validation set: " + str(accuracy)
         print ''

    # # generate predictions on the test set
    if predict != False:
         print '###\n#  Generating Predictions on Test Set\n###'
         create_predictions(tree, predict)
         predict_set, attribute_metadata = parse('PS2.csv', 1)
         print 'Accuracy on prediction set using unpruned model is:' + str(validation_accuracy(tree,predict_set))
         print 'Accuracy on prediction set using pruned model is:' + str(validation_accuracy(pruned_tree,predict_set))
         print ''
    # # generate a learning curve using the validation set
    if learning_curve and validate:
        print '###\n#  Generating Learning Curve\n###'
        iterations = 20 # number of times to test each size
        print get_graph_data(train_set, attribute_metadata, pruning_set, numerical_splits_count, 4, [.001,.002,.003,.004,.005,.006,.007,.009,.001,0.5,1,2,3,4,5,10,20,40,60,80,100])
        print ''

tree = decision_tree_driver( **options )
