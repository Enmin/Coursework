# Inputs
#   train_feats: N x d matrix of N features each d descriptor long
#   train_labels: N x 1 array containing values of either -1 (class 0) or 1 (class 1)
#   test_feat: 1 x d image for which we wish to predict a label
#
# Outputs
#   -1 (class 0) or 1 (class 1)
#
# Please turn this into a multi-class classifier for k classes.
# Inputs:
#    As before, except
#    train_labels: N x 1 array of class label integers from 0 to k-1
# Outputs:
#    A class label integer from 0 to k-1
#
def classify(train_feats, train_labels, test_feat):
    # Train classification hyperplane
    classifier = {}
    for i in range(k):
        train_k_label = [1 if i == k else 0 for i in train_labels]
        classifier[i] = train_linear_classifier(train_feats, train_k_label)
    # Compute distance from hyperplane
    scores = {}
    for i in classifier.keys():
        weights, bias - classifier[i]
        test_score = weights * test_feats + bias
        scores[i] = test_score
    highest = [k for k, _ in sorted(scores.items(), lambda x: x[1])][0]

    return highest