import random
from random import shuffle
import os.path
import csv

def create_random_array(length_a,length_l):
    out = []
    for i in range(0,length_l):
        array = []
        for x in range(0,length_a):
            a = random.random()
            if a<0.5:
                array.append(1)
            else:
                array.append(0)
        out.append(array)
    return out

def binary_decomp(number):
    MSB = 32768
    num = number
    out = []
    if number>(MSB*2 + 1):
        return Null
    else:
        while MSB >= 1:
            if num>=MSB:
                out.append(1)
                num = num - MSB
            else:
                out.append(0)
            MSB = MSB/2
    return out

def binary_incomp(array):
    bit = 1
    out = 0
    ar = array[::-1]
    for x in range(0, len(array)):
        if ar[x]==1:
            out += bit
        bit *=2
    return out

def processlist(array):
    out = []
    for x in range(0,len(array)):
        if array[x] == 1:
            out.append('present')
        else:
            out.append('absent')
    return out
    
def create_data(length_a, length_l):
    unclassified_set = create_random_array(length_a,length_l)
    unclassified_set2 = create_random_array(length_a,length_l)
    unclassified_set3 = create_random_array(length_a,length_l)
    unclassified_set4 = create_random_array(length_a,length_l)
    classified_set = []
    for x in range(0, length_l):
        if binary_incomp(unclassified_set[x])>39415 and random.random()<.95:
            classified_set.append(processlist(unclassified_set[x] + unclassified_set2[x] + unclassified_set3[x]) + ['win'])
        else:
            classified_set.append(processlist(unclassified_set[x] + unclassified_set2[x] + unclassified_set3[x]) + ['lose'])
    return classified_set

def print_out(data_set,name,n):
    FILE = csv.writer(open(name, "wb"))
    if n==1:
        FILE.writerow(['Alex','Nancy','Howard','Roman','Lucy','Dean','Zack','Matthew','Greg','Antonio','Elena','Peter','Jake','Pat','Connor','John','Forest','Nash','Lennon','Clyde','Coby','Daren','Clark',
        'Bret','Fabian','Enrique,','Ernesto','Dino','Marco','Luke','Ned','Leonard','Valentin','Tray','Rock','Ryle','Paul','Richie','Paco','Percy','Rio','Jax','Lisa','Margo','Claire','Gale','Olga','Natalie',
        'game outcome'])
    elif n==2:
        FILE.writerow(['Alex','Nancy','Howard','Roman','Lucy','Dean','Zack','Matthew','Greg','Antonio','Elena','Peter','Jake','Pat','Connor','John','game outcome'])
    for index in range(len(data_set)):
        FILE.writerow(data_set[index])


print_out(create_data(16,1000),"data.csv",1)

def meana(array):
    total = 0.0
    for x in range(len(array)):
        total = total + array[x]
    return float(total/len(array))

def xoraganza(array):
    a = len(array)/2
    if a == 2:
        return array[1]
    arro = []
    for y in range(0,a):
        arro.append((array[y] and not array[a+y]) or (not array[y] and array[a+y]))
    return xoraganza(arro)


def create_data2(length_a, length_l):
    unclassified_set = create_random_array(length_a,length_l)
    classified_set = []
    xorcase = []
    for x in range(0, length_l):
        if xoraganza(unclassified_set[x]) == 1 and random.random()<.95:
             classified_set.append(processlist(unclassified_set[x]) + ['win'])
        else:
            classified_set.append(processlist(unclassified_set[x]) + ['lose'])
    return classified_set

print_out(create_data2(16,1000),"data2.csv",2)
