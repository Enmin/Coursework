import numpy as np
import pandas as pd
from scipy.sparse.construct import rand
from sklearn.model_selection import train_test_split, GroupShuffleSplit
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.svm import SVC
from sklearn.model_selection import StratifiedKFold
from sklearn.pipeline import make_pipeline
from sklearn.model_selection import ParameterGrid
from sklearn.model_selection import GridSearchCV
from sklearn.compose import ColumnTransformer
from collections import defaultdict
import pickle

pos_data_path = "../data/pose_data.csv"
def read_data():
    return pd.read_csv(pos_data_path, index_col=None).query("label != 'nothing'")

def pipe(x, y, preprocessor, ML_algo, param_grid):
     
    test_scores = []
    best_models = []
    best_estimators = []
    # loop through 10 random states (2 points)
    for i in range(1):
        # split data to other/test 80/20, and the use KFold with 4 folds (2 points)
        random_state = 42*i
        X_other, X_test, y_other, y_test = train_test_split(x, y, test_size=0.2, random_state = random_state, stratify=y)
        kf = StratifiedKFold(n_splits=5, shuffle=True, random_state = random_state)
        # preprocess the data
        pipe = make_pipeline(preprocessor, ML_algo)
        
        # loop through the hyperparameter combinations or use GridSearchCV (2 points)
        grid = GridSearchCV(estimator=pipe, param_grid=param_grid, scoring='accuracy', cv=kf, return_train_score=True)
        
        # for each combination, calculate the train and validation scores using the evaluation metric
        grid.fit(X_other, y_other)
        
        # find which hyperparameter combination gives the best validation score (1 point)
        test_score = grid.score(X_test, y_test)
        
        # calculate the test score (1 point)
        test_scores.append(test_score)
        best_models.append(grid.best_params_)
        best_estimators.append(grid.best_estimator_)
        # append the test score and the best model to the lists (1 point)        
    return test_scores, best_models, best_estimators

def main():
    df = read_data()
    le = LabelEncoder()
    le.fit(df['label'])
    y = le.fit_transform(df['label'])
    x = df.loc[:, ~df.columns.isin(['label', 'image_name', 'Unnamed: 0'])]
    # x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.1, stratify=y, random_state=42)
    # x_train, x_val, y_train, y_val = train_test_split(x_train, y_train, test_size=0.1, stratify=y, random_state=42)
    scores, best_params, best_estimators = pipe(x, y, StandardScaler(), SVC(), {"svc__C":[1e-3], "svc__kernel": ['linear', 'rbf', 'poly']})
    print("TEST SCORES: ", scores) #0.9232630757220921
    print("BEST PARAMS: ", best_params) # {'svc__C': 0.001, 'svc__kernel': 'linear'}
    for i in range(len(best_estimators)):
        with open('../model/best_svc_{}.pkl'.format(i), 'wb') as file:
            pickle.dump(best_estimators[i], file)

if __name__ == "__main__":
    main()