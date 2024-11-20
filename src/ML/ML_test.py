#!/usr/bin/env python
# coding: utf-8

# In[1]:


import import_ipynb

import ML_API

from ML_API import MLAPI
import pandas as pd


# In[10]:


api = MLAPI()
api.set_local_csv_dataset()
print(api.dataset)


# In[11]:


print(api.logistic_regression('target', max_epochs=700))
print(api.linear_regression('target', max_epochs=700))
print(api.decision_tree('target', max_epochs=700))


# In[12]:


print(api.dataset)
print(api.recommed_model(['target'], ['sepal length (cm)']))


# In[13]:


api = MLAPI()
api.set_local_csv_dataset("social_network")
print(api.dataset)
svm = api.svm("Purchased", columns=["Age", "EstimatedSalary"])


# In[14]:


mlpr = api.mlpRegressor("Purchased", columns=["Age", "EstimatedSalary"])
mlpr = api.mlpClassifier("Purchased", columns=["Age", "EstimatedSalary"])


# In[21]:


dataset = "../Data/archive 2/Iris.csv"
pd.read_csv(dataset)
api.set_local_csv_dataset(dataset=dataset, concat=True)


# In[22]:


print(svm)


# In[23]:


import pickle as pkl
pkl.dump(svm, open("svm.pkl", 'wb'))


# In[26]:


print(api.decision_tree('Species', max_epochs=10))


# In[27]:


api.one_hot_encode()
# print(api.logistic_regression('popularity', max_epochs=700))
# print(api.linear_regression('popularity', max_epochs=10))


# In[18]:


api.set_local_csv_dataset("../Data/top_rated_9000_movies_on_TMDB.csv")


# In[7]:


import pandas as pd
pd.read_csv("Worlds Best 50 Hotels.csv", encoding='latin-1')


# In[5]:


get_ipython().system("jupyter nbconvert --to script 'ML_test.ipynb'")


# In[ ]:




