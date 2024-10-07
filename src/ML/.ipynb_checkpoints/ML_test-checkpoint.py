#!/usr/bin/env python
# coding: utf-8

# In[1]:


from ML_API import MLAPI
api = MLAPI()
api.set_local_csv_dataset()
print(api.dataset)


# In[181]:


print(api.logistic_regression('target', max_epochs=700))
print(api.linear_regression('target', max_epochs=700))
print(api.decision_tree('target', max_epochs=700))


