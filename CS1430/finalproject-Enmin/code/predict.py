import numpy as np
import pandas as pd
from sklearn.preprocessing import LabelEncoder
import pickle
from sklearn.metrics import accuracy_score
from train import read_data
import matplotlib.pyplot as plt

class Predict:
    def __init__(self) -> None:
        filename = "../model/best_svc_0.pkl"
        self.svm_model = pickle.load(open(filename, 'rb'))
        self.label_dict = {0: 'A', 1: 'B', 2: 'C', 3: 'D', 4: 'E', 5: 'F', 6: 'G', 7: 'H', 8: 'I', 9: 'J',
                    10: 'K', 11: 'L', 12: 'M', 13: 'N', 14: 'O', 15: 'P', 16: 'Q', 17: 'R', 18: 'S',
                    19: 'T', 20: 'U', 21: 'V', 22: 'W', 23: 'X', 24: 'Y', 25: 'Z', 26: 'del', 27: 'space'}
    
    def svm_predict(self, input):
        
        output = self.svm_model.predict(input)
        return [self.label_dict[i] for i in output], output



def main():
    df = read_data()
    le = LabelEncoder()
    le.fit(df['label'])
    y = le.fit_transform(df['label'])
    x = df.loc[:, ~df.columns.isin(['label', 'image_name', 'Unnamed: 0'])]
    p = Predict()
    classes, predictions = p.svm_predict(x)
    predictions_by_class = {i: (0, 0) for i in p.label_dict.values()}
    for i in range(len(y)):
        if y[i] == predictions[i]:
            first, second = predictions_by_class[classes[i]]
            predictions_by_class[p.label_dict[y[i]]] = (first + 1, second + 1)
        else:
            predictions_by_class[p.label_dict[y[i]]] = (first, second + 1)
    acc = accuracy_score(y, predictions)
    t = [round(v[0]/v[1] * 100, 2) for k, v in predictions_by_class.items()]
    f = [100 - i for i in t]
    fig, ax = plt.subplots()
    width = 0.35
    ax.bar(predictions_by_class.keys(), t, width, label='True')
    ax.bar(predictions_by_class.keys(), f, width, bottom=t,label='False')
    ax.set_ylim(0, 100)
    ax.set_ylabel('Accuracy')
    ax.set_title('SVM performance on hand skeleton coordinates {}%'.format(round(acc, 2)))
    ax.legend()

    plt.show()


if __name__ == "__main__":
    main()