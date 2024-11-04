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


print(api.dataset)
print(api.recommed_model(['target'], ['sepal length (cm)']))


# In[4]:


dataset = "../Data/archive 2/Iris.csv"
pd.read_csv(dataset)
api.set_local_csv_dataset(dataset=dataset, concat=True)


# In[10]:


print(api.logistic_regression('target', max_epochs=700))
print(api.linear_regression('target', max_epochs=700))
print(api.decision_tree('target', max_epochs=700))


# In[6]:


api = MLAPI()
api.set_local_csv_dataset("social_network")
print(api.dataset)
print(api.svm("Purchased", columns=["Age", "EstimatedSalary"]))


# In[11]:


api.set_local_csv_dataset("../Data/top_rated_9000_movies_on_TMDB.csv")


# In[12]:


api.one_hot_encode()
# print(api.logistic_regression('popularity', max_epochs=700))
# print(api.linear_regression('popularity', max_epochs=10))


# In[6]:


print(api.decision_tree('popularity', max_epochs=10))


# In[7]:


import pandas as pd
pd.read_csv("Worlds Best 50 Hotels.csv", encoding='latin-1')


# In[3]:


get_ipython().system("jupyter nbconvert --to script 'ML_test.ipynb'")


# In[ ]:




