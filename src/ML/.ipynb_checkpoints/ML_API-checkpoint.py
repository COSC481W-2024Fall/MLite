#!/usr/bin/env python
# coding: utf-8

# In[2]:


import torch
import subprocess
import pandas as pd
import sklearn
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import numpy as np
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score
import argparse
from sklearn.neural_network import MLPClassifier, MLPRegressor


# In[1]:


class MLAPI:
    device = None
    nvidia = False
    dataset_name = None
    dataset = None
    model = None
    accuracy = 0.0
    
    def __init__(self, checkpoint=""):
        try:
            subprocess.check_output('nvidia-smi')
            nvidia = True
            print("Nvidia drivers available!")
        except Exception: 
            # this command not being found can raise quite a few 
            # different errors depending on the configuration
            print('No Nvidia GPU in system!')
        try:
            self.device = torch.device('cuda:0')
            print("GPU available!")
        except:
            print("No GPU available in system!")
        
    def __str__(self):
        try:
            return self.accuracy
        except:
            return 0

    def one_hot_encode(self, inplace=True, dataset=None, cutoff = 10, columns=None):
        # TODO: Fix this
        
        # do a one hot encode of the current dataset and then return 
        # the new column names alongside the new dataframe
        print("TESTING")
        try:
            print("Columns: ")
            print ([self.dataset[col].unique().tolist() for col in self.dataset.columns])
            one_hot_df = pd.get_dummies(self.dataset)
        
            new_columns = one_hot_df.columns.difference(self.dataset.columns).tolist()
            
        # catch when df1 is None
        except AttributeError as e:
            print(e)
            return None, None
        # catch when it hasn't even been defined
        except NameError as e:
            print(e)
            return None, None
            
        if inplace:
            self.dataset = one_hot_df
            
        return one_hot_df, new_columns
    
    def set_local_csv_dataset(self, dataset=None, encoding=None, concat=False):
        self.dataset_name = dataset
        if dataset == None:
            from sklearn import datasets
            iris = datasets.load_iris()
            irisdf = pd.DataFrame(data= np.c_[iris['data'], iris['target']],
                                 columns= iris['feature_names'] + ['target'])
            self.dataset = irisdf
            
        if dataset == "social_network":
            self.dataset = pd.read_csv("../Data/Social_Network_Ads.csv")
            
        else:
            try:
                if concat == True:
                    if encoding != None:
                        new_dataset = pd.read_csv(self.dataset_name, encoding=encoding)
                    else:
                        new_dataset = pd.read_csv(self.dataset_name)
                    self.dataset = pd.concat([self.dataset, new_dataset])
                if encoding != None:
                    self.dataset = pd.read_csv(self.dataset_name, encoding=encoding)
                else:
                    self.dataset = pd.read_csv(self.dataset_name)
            except Exception as e:
                print(e)
                return False
        return True

    def set_local_json_dataset(self, dataset):
        pass


    
    def calculate_r2(self, y_true, y_pred):
        """
        Calculate the R² score directly using predictions.
        
        Parameters:
        y_true (array-like): True target values.
        y_pred (array-like): Predicted target values from a simple linear model.
        
        Returns:
        float: R² score.
        """
        ss_res = np.sum((y_true - y_pred) ** 2)  # Residual sum of squares
        ss_tot = np.sum((y_true - np.mean(y_true)) ** 2)  # Total sum of squares
        r2 = 1 - (ss_res / ss_tot)
        return r2
        
    def recommed_model(self, columns, features):
        # should probably mostly rely upon user input to recommend a model
        # if data is linear and wants easy explanation -> linear
        # linear data + categorical data -> logistic regression
        # we can get linearity from R^2 score?
        # high dimensional data + easy explanation or large amount of entries -> decision tree
        # high dimensional data + higher accuracy + fewer entries -> SVM
        # SVM takes longer to train than most trees
        # TODO: add naive bayes algorithm to class

        X = self.dataset[features].values
        y = self.dataset[columns].values.flatten()

        coefficients = np.linalg.lstsq(X, y, rcond=None)[0]  # Least squares solution
        y_pred = np.dot(X, coefficients)
        print(y, y_pred)
        r2 = self.calculate_r2(y, y_pred)

        if r2 > 0.7:
            return "Linear Regression: Data is highly linear."
        elif len(np.unique(y)) == 2:
            return "Logistic Regression: Linear data with binary outcome."
        
            


        if X.shape[1] > 10:  # Arbitrary threshold for high-dimensional data
            return "Decision Tree Classifier: High-dimensional data with many entries."
        else:
            return "SVM: High-dimensional data with fewer entries, aiming for higher accuracy."

        
        
        
    def logistic_regression(self,label=None, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100, verbose=1):
        df_encoded = pd.get_dummies(self.dataset, drop_first=True)
        if label == None:
            y = self.dataset[-1]
        else:
            y = self.dataset[label]
            
        if columns == None:
            #assume all other columns and set X_columns to all features not label
            X_columns = [col for col in self.dataset.columns if label not in col]
        else:
            # use only given columns
            X_columns = columns
        X = self.dataset[X_columns]

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=random_state)

        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        self.model = LogisticRegression(max_iter=max_epochs, verbose = verbose)
        self.model.fit(X_train, y_train)
        self.accuracy = self.model.score(X_test, y_test)
        print(f"Model Accuracy: {self.accuracy}")
        return self.model

    def linear_regression(self,label=None, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100, verbose=1):
        # worth noting that the linear regression method via sklearn is very sparsely implemented
        # takes almost no method arguments
        df_encoded = pd.get_dummies(self.dataset, drop_first=True)

        #TODO: get columns from df_encoded if categorical data that is one hot encoded
        
        if label == None:
            y = self.dataset[-1]
        else:
            y = self.dataset[label]
            
        if columns == None:
            #assume all other columns and set X_columns to all features not label
            X_columns = [col for col in df_encoded.columns if label not in col]
        else:
            # use only given columns
            X_columns = columns
        X = df_encoded[X_columns]

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=random_state)

        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        self.model = LinearRegression()
        self.model.fit(X_train, y_train)
        self.accuracy = self.model.score(X_test, y_test)
        print(f"Model Accuracy: {self.accuracy}")
        return self.model

    def svm(self,label=None, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100, verbose=1):
        if label == None:
            y = self.dataset[-1]
        else:
            y = self.dataset[label]
            
        X_columns = None
        if columns == None:
            #assume all other columns and set X_columns to all features not label
            X_columns = [col for col in self.dataset.columns if label not in col]
        else:
            X_columns = columns
            
        X = self.dataset[X_columns]
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = test_size, random_state = random_state)
        sc = StandardScaler()
        X_train = sc.fit_transform(X_train)
        X_test = sc.transform(X_test)
        self.model = SVC(kernel = 'rbf', random_state = random_state, verbose = verbose)
        self.model.fit(X_train, y_train)
        y_pred = self.model.predict(X_test)
        self.accuracy = accuracy_score(y_test,y_pred)
        print(f"Model Accuracy: {self.accuracy}")
        return self.model

    def decision_tree(self,label=None, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100, verbose=1):
        if label == None:
            y = self.dataset[-1]
        else:
            y = self.dataset[label]
        if columns == None:
            #assume all other columns and set X_columns to all features not label
            X_columns = [col for col in self.dataset.columns if label not in col]
        else:
            # use only given columns
            X_columns = columns
        X = self.dataset[X_columns]

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=random_state)

        scaler = StandardScaler()
        try:
            X_train_scaled = scaler.fit_transform(X_train)
        except:
            X_train_scaled = X_train

        try:
            X_test_scaled = scaler.transform(X_test)
        except:
            X_test_scaled = X_test

        #TODO: Add verbosity to decision tree classifier?
        self.model = DecisionTreeClassifier(random_state = random_state)
        self.model.fit(X_train_scaled, y_train)
        y_pred = self.model.predict(X_test_scaled)
        self.accuracy = self.model.score(X_test_scaled, y_test)
        print(f"Model Accuracy: {self.accuracy}")
        return self.model

    def mlpClassifier(self,label=None, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100, verbose=1):
        if label == None:
            y = self.dataset[-1]
        else:
            y = self.dataset[label]
        if columns == None:
            #assume all other columns and set X_columns to all features not label
            X_columns = [col for col in self.dataset.columns if label not in col]
        else:
            # use only given columns
            X_columns = columns
        X = self.dataset[X_columns]

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=random_state)

        scaler = StandardScaler()

         try:
            X_train_scaled = scaler.fit_transform(X_train)
            X_test_scaled = scaler.transform(X_test)
        except:
            X_train_scaled = X_train
            X_test_scaled = X_test   
        
        self.model = MLPClassifier(random_state=1, max_iter=300).fit(X_train_scaled, y_train)
        y_pred = self.model.predict(X_test_scaled)
        self.accuracy = self.model.score(X_test_scaled, y_test)
        print(f"Model Accuracy: {self.accuracy}")
        return self.model

    def mlpRegressor(self,label=None, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100, verbose=1):
        if label == None:
            y = self.dataset[-1]
        else:
            y = self.dataset[label]
        if columns == None:
            #assume all other columns and set X_columns to all features not label
            X_columns = [col for col in self.dataset.columns if label not in col]
        else:
            # use only given columns
            X_columns = columns
        X = self.dataset[X_columns]

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=random_state)

        scaler = StandardScaler()

         try:
            X_train_scaled = scaler.fit_transform(X_train)
            X_test_scaled = scaler.transform(X_test)
        except:
            X_train_scaled = X_train
            X_test_scaled = X_test            
            
        self.model = MLPRegressor(random_state=1, max_iter=300).fit(X_train_scaled, y_train)
        y_pred = self.model.predict(X_test_scaled)
        self.accuracy = self.model.score(X_test_scaled, y_test)
        print(f"Model Accuracy: {self.accuracy}")
        return self.model
        

        

                


# In[3]:


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run machine learning tasks with the MLAPI class.")
    parser.add_argument('--dataset', type=str, help="Path to the local CSV dataset.")
    parser.add_argument("--concat", default=False, action="store_true", help="Concat dataset flag")
    parser.add_argument('--task', type=str, choices=['logistic_regression', 'linear_regression', 'svm', 'decision_tree', 'recommend_model'], 
                        help="The machine learning task to run.")
    parser.add_argument('--label', type=str, help="The label column for training.")
    parser.add_argument('--columns', type=str, nargs='*', help="Feature columns for the model.")
    parser.add_argument('--test_size', type=float, default=0.25, help="Test size for the train/test split.")
    parser.add_argument('--random_state', type=int, default=42, help="Random state for reproducibility.")

    args = parser.parse_args()

    # Create an instance of the class
    ml_api = MLAPI()

    # Load the dataset
    if args.dataset:
        if args.concat:
            ml_api.set_local_csv_dataset(dataset= args.dataset, concat=True)
        else:
            ml_api.set_local_csv_dataset(dataset=args.dataset)
    else:
        if args.concat:
            ml_api.set_local_csv_dataset(concat=True)
        else:
            ml_api.set_local_csv_dataset()

    # Run the specified task
    if args.task == 'logistic_regression':
        ml_api.logistic_regression(label=args.label, columns=args.columns, test_size=args.test_size, random_state=args.random_state)
    elif args.task == 'linear_regression':
        ml_api.linear_regression(label=args.label, columns=args.columns, test_size=args.test_size, random_state=args.random_state)
    elif args.task == 'svm':
        ml_api.svm(label=args.label, columns=args.columns, test_size=args.test_size, random_state=args.random_state)
    elif args.task == 'decision_tree':
        ml_api.decision_tree(label=args.label, columns=args.columns, test_size=args.test_size, random_state=args.random_state)
    elif args.task == 'recommend_model':
        ml_api.recommed_model(columns=args.columns, features=args.label)
    else:
        print("Invalid task specified. Use --help for options.")


# In[6]:


get_ipython().system("jupyter nbconvert --to script 'ML_API.ipynb'")


# In[ ]:




