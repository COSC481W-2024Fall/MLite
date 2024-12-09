# MLite API
Hello! This is the documentation for the underlying machine learning code for MLite.
You want to be reading this if:
- You want to understand how MLite works on the machine learning side
- You want to understand how to utilize the python notebooks or .py files
- You are curious about machine learning in general
- You are attempting to interface ML_API with Flask or Ruby.
  
You are probably lost if:
- You are attempting to debug something on MLite that is broken on the app side
- You are looking to 'just make MLite work'
- You have no idea what python is or what it does
- 
## ML API Structure
The ML_API class, designed to be a singular class able to manage training and deployment of models when encapsulated by a deployment instance, attempts to facilitate simple machine learning processes in as robust and dataset-agnostic way as possible. Additionally, it seeks to encapsulate enough information within itself to avoid looking externally for data where possible; as such, when given data that is critical to its functioning, it stores it as a member rather than saving it to a directory where possible.

### Data Members
Initial class members are as follows:
- device -- Tracks whether or not GPU acceleration is availablee to the local instance; 'None' or 'String'
- nvidia -- Tracks type of GPU acceleration hardware is available; 'True', or 'False'
- dataset_name -- Tracks the file name of the dataset; used for importing; 'None' or 'String'
- dataset -- Raw pandas dataframe of the dataset; is imported using the dataset_name. 'None' or <class 'pandas.core.frame.DataFrame'>
- model -- Raw representation of sklearn model object; 'None' or <class 'sklearn...'>
- accuracy -- Validation results of model accuracy; float.


## ML API Functions
The underlying MLite API includes a handful of different models to encapsulate a relatively broad variety of datasets. All of the current models within the API are based off of the sklearn/keras machine learning pipeline, as it is more lightweight and flexible than Pytorch, even though Pytorch tensor acceleration via GPU is far more powerful. As our current server implementation is intended to be CPU-centric, deep learning framework usage would also be moot.

### Models
The models used by MLite's API are as follows:
- [Linear Regression](https://scikit-learn.org/1.5/modules/generated/sklearn.linear_model.LinearRegression.html)
- [Logistic Regression](https://scikit-learn.org/1.5/modules/generated/sklearn.linear_model.LogisticRegression.html#sklearn.linear_model.LogisticRegression)
- [Support Vector Machines](https://scikit-learn.org/1.5/modules/generated/sklearn.svm.SVC.html#sklearn.svm.SVC)
- [Decision Trees](https://scikit-learn.org/1.5/modules/generated/sklearn.tree.DecisionTreeClassifier.html#sklearn.tree.DecisionTreeClassifier)
- [Multilayer Perceptron (Classification)](https://scikit-learn.org/1.5/modules/generated/sklearn.neural_network.MLPClassifier.html#sklearn.neural_network.MLPClassifier)
- [Multilayer Perceptron (Regression)](https://scikit-learn.org/1.5/modules/generated/sklearn.neural_network.MLPRegressor.html#sklearn.neural_network.MLPRegressor)

### Preprocessing
In order to use these algorithms in as general and robust a fashion as possible, much of the work done on the backend by the API leverages pandas to clean and process the data in as general a fashion as possible before utilizing sklearn. Uniquely, the ML API can also attempt to recommend a model type to use based on an existing dataset.
Utility functions include:
- one_hot_encode: Attempts to encode every categorical column into a one-hot vector, while ignoring the target column. 
- set_local_csv_dataset: Sets the class dataset from a string name, as a pandas dataframe.
- set_local_json_dataset: Method stub; would be used to set the class dataset via json.
- calculate_r2: Calculates the r^2 value for the entire dataset. Used to recommend models.
- recommed_model: Attempts to recommend the best model available from the existing implemented model by computing a simple least squares solution. A high r^2 return from that indicates that the data is highly linear and can be modeled by a linear regression function; low returns mean that we need to utilize a decision tree, svm or MLP solution. 
