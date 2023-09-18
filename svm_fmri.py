import numpy as np
import tensorly as tl
from tensorly import unfold
# create samples
y1=np.array([0,1])
y=np.repeat(y1,[179,218])

# read features
import pandas as pd
table=pd.read_excel('Z:/User/pcp20wx/fmri/RESULT/mlc/allwithlabs.xlsx')
Columnname=table.columns
ColumnArray=[]
for i in range(len(Columnname)):
    testDat = Columnname[i]
    ColumnArray.append(testDat)
from sklearn.model_selection import train_test_split
feature_train,feature_test,y_train,y_test = train_test_split(table,y,test_size=0.30,random_state=0)

from sklearn.svm import SVC
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
# svm_model_linear = SVC(kernel = 'linear', C=1).fit(feature_train,y_train)
svm_model_linear =make_pipeline(StandardScaler(),SVC(kernel = 'linear', C=1))
svm_model_linear.fit(feature_train,y_train)
svm_predictions = svm_model_linear.predict(feature_test)
accuracy = svm_model_linear.score(feature_test,y_test)
print("Test accuracy:",accuracy)

import matplotlib.pyplot as plt
from sklearn.metrics import accuracy_score
from sklearn.metrics import confusion_matrix
from sklearn.metrics import classification_report
from sklearn.datasets import make_classification
from sklearn.metrics import ConfusionMatrixDisplay, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC 
# svm_model_linear = SVC(kernel = 'linear', C=1).fit(feature_train,y_train)
svm_predictions = svm_model_linear.predict(feature_train)
accuracy = svm_model_linear.score(feature_train,y_train)
print("Train accuracy:",accuracy)

predictions= svm_model_linear.predict(table)
cm = confusion_matrix(y,predictions)
#print(classification_report(y_test,svm_predictions))

disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=svm_model_linear.classes_)
font={'size':'14'}
plt.rc('font',**font)
plt.rcParams['figure.figsize']=[6,6]
disp.plot(cmap='Blues',values_format='0.2f')
#plt.colorbar(im,fraction=0.046, pad=0.04)
plt.show()


from sklearn import svm
from sklearn.model_selection import cross_val_score
# clf = svm.SVC(kernel='linear',random_state=0)
# clf.fit(table_unfold,y)
# print(clf.coef_)

# from matplotlib import pyplot as plt
# from sklearn import svm
# def f_importances(coef,names):
# 	imp = coef
# 	imp,names = zip(*sorted(zip(imp,names)))
# 	plt.barh(range(len(names)),imp,align = 'center')
# 	plt.yticks(range(len(names)),names)
# 	plt.show()

# features_names = ['input1','input2']

# f_importances(abs(clf.coef_[0]),ColumnArray,top=10)

from matplotlib import pyplot as plt
from sklearn import svm

def f_importances(coef, names, top=-1):
    imp = coef
    imp, names = zip(*sorted(list(zip(imp, names))))

    # Show all features
    if top == -1:
        top = len(names)

    plt.barh(range(top), imp[::-1][0:top], align='center')
    plt.yticks(range(top), names[::-1][0:top])
    plt.show()

# Specify your top n features you want to visualize.
f_importances(abs(svm_model_linear.named_steps['svc'].coef_[0]),ColumnArray, top=25)
from scipy.io import savemat
mydictionary = {"coef":svm_model_linear.named_steps['svc'].coef_[0],"name":ColumnArray}
savemat("contributor25.mat",mydictionary)

from sklearn.model_selection import ShuffleSplit
n_samples = table.shape[0]
cv = ShuffleSplit(n_splits = 10, test_size =0.3, random_state=0)
# scores=cross_val_score(clf,table_unfold,y,cv=cv)
scores=cross_val_score(svm_model_linear,table,y,cv=cv)
# clf = make_pipeline(preprocessing.StandardScaler(),SVC(kernel='linear')) scores = cross_val_score(clf,X,y,cv=5)
# print(scores)
print("%0.2f accuracy with a standard deviation of %0.2f" % (scores.mean(),scores.std()))



import numpy as np

n_uncorrelated_features = 480
rng = np.random.RandomState(seed=0)
# Use same number of samples as in iris and 20 features
X_rand = rng.normal(size=(table.shape[0], n_uncorrelated_features))

from sklearn.model_selection import StratifiedKFold
from sklearn.model_selection import permutation_test_score

cv = StratifiedKFold(2, shuffle=True, random_state=0)

score, perm_scores, pvalue = permutation_test_score(
    svm_model_linear, table,y, scoring="accuracy", cv=cv, n_permutations=1000
)

score_rand, perm_scores_rand, pvalue_rand = permutation_test_score(
    svm_model_linear, X_rand, y, scoring="accuracy", cv=cv, n_permutations=1000
)

import matplotlib.pyplot as plt

fig, ax = plt.subplots()

ax.hist(perm_scores, bins=20, density=True)
ax.axvline(score, ls="--", color="r")
score_label = f"Score on original\ndata: {score:.2f}\n(p-value: {pvalue:.3f})"
ax.text(0.7, 10, score_label, fontsize=12)
ax.set_xlabel("Accuracy score")
_ = ax.set_ylabel("Probability")
plt.show()