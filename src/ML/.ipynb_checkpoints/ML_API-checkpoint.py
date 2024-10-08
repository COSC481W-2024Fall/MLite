#!/usr/bin/env python
# coding: utf-8

# In[175]:


import torch
import subprocess
import pandas as pd
import sklearn
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import numpy as np


# In[176]:





# In[184]:


class MLAPI:
    device = None
    nvidia = False
    dataset_name = None
    dataset = None
    model = None
    
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
        

    def set_local_csv_dataset(self, dataset=None):
        self.dataset_name = dataset
        if dataset == None:
            from sklearn import datasets
            iris = datasets.load_iris()
            irisdf = pd.DataFrame(data= np.c_[iris['data'], iris['target']],
                                 columns= iris['feature_names'] + ['target'])
            self.dataset = irisdf
        else:
            try:
                self.dataset = pd.read_csv(self.dataset_name)
            except:
                print("Not CSV")

    def set_local_json_dataset(self, dataset):
        pass

    def logistic_regression(self,label, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100):
        df_encoded = pd.get_dummies(self.dataset, drop_first=True)
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

        self.model = LogisticRegression(max_iter=max_epochs)
        self.model.fit(X_train, y_train)
        accuracy = self.model.score(X_test, y_test)
        print(f"Model Accuracy: {accuracy}")
        return self.model

    def linear_regression(self,label, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100):
        df_encoded = pd.get_dummies(self.dataset, drop_first=True)

        #TODO: get columns from df_encoded if categorical data that is one hot encoded
        
        y = df_encoded[label]
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
        accuracy = self.model.score(X_test, y_test)
        print(f"Model Accuracy: {accuracy}")
        return self.model

    def svm(self,label, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100):
        # TODO: METHOD STUB
        pass

    def decision_tree(self,label, lr=1e-4, test_size=0.25, random_state=42, columns=None, max_epochs=100):
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
        
        self.model = DecisionTreeClassifier(random_state = random_state)
        self.model.fit(X_train, y_train)
        y_pred = self.model.predict(X_test)
        accuracy = self.model.score(X_test, y_test)
        print(f"Decision Tree Model Accuracy: {accuracy}")
        return self.model
                


# In[185]:


api = MLAPI()
api.set_local_csv_dataset()
print(api.dataset)


# In[186]:


print(api.logistic_regression('target', max_epochs=700))
print(api.linear_regression('target', max_epochs=700))
print(api.decision_tree('target', max_epochs=700))


# In[1]:





