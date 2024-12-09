#!/usr/bin/env python
# coding: utf-8

# In[1]:


import import_ipynb

import ML_API

from ML_API import MLAPI
import pandas as pd


# In[2]:


api = MLAPI()
api.set_local_csv_dataset()
print(api.dataset)


# In[3]:


one_hot_df, new_columns = api.one_hot_encode(target="target")
print(one_hot_df)
print(new_columns)
one_hot_df, new_columns = api.one_hot_encode(columns=["sepal length (cm)", "target"], target="target")
print(one_hot_df)
print(new_columns)


# In[3]:


print(api.logistic_regression('target', max_epochs=700))
print(api.linear_regression('target', max_epochs=700))
print(api.decision_tree('target', max_epochs=700))


# In[4]:


print(api.dataset)
print(api.recommed_model(['target'], ['sepal length (cm)']))


# In[5]:


api = MLAPI()
api.set_local_csv_dataset("social_network")
print(api.dataset)
svm = api.svm("Purchased", columns=["Age", "EstimatedSalary"])


# In[6]:


mlpr = api.mlpRegressor("Purchased", columns=["Age", "EstimatedSalary"])
mlpr = api.mlpClassifier("Purchased", columns=["Age", "EstimatedSalary"])


# In[7]:


dataset = "../Data/archive 2/Iris.csv"
pd.read_csv(dataset)
api.set_local_csv_dataset(dataset=dataset, concat=True)


# In[8]:


print(svm)


# In[9]:


import pickle as pkl
pkl.dump(svm, open("svm.pkl", 'wb'))


# In[10]:


print(api.decision_tree('Species', max_epochs=10))


# In[11]:


api.one_hot_encode()
# print(api.logistic_regression('popularity', max_epochs=700))
# print(api.linear_regression('popularity', max_epochs=10))


# In[4]:




# In[ ]:




