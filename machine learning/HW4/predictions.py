def create_random_array(length_a,length_l):
    out = []
    for i in range(0,length_l):
        array = []
        for x in range(0,length_a)
            a = random.random()
            if a<0.5:
                array.append(0)
            else:
                array.append(1)
        out.append(array)
    return out

# 
# def create_data(length, attributes):
#     test_set, attribute_metadata = parse(predict, True)
#     headers = []
#     test_set = PredictionsSet_Fill(test_set,attribute_metadata)
#     for i in attribute_metadata:
#         headers.append(i['name'])
#     del headers[0]
#     headers.append('winner')
#     c = csv.writer(open("PS2.csv", "wb"))
#     c.writerow(headers)
#     winner= []
#     for x in test_set:
#         winner.append(tree.classify(x))
#     for index in range(len(test_set)):
#         test_set[index].append(winner[index])
#         del test_set[index][0]
#         c.writerow(test_set[index])
