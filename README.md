# People-Detection-Fixed-Camera--Matlab

# 1. Objectives

The objective of this project is to demonstrate how to detect moving and stand-still people and other objects introduced to a scene monitored by a fixed-camera system. The implemented approach is based on the following 2 steps:

1.  Estimate the backgound image:
    * We explored four different background estimation techniques.
2. Estimate the change between the current frame foreground image and the background.
    * We explored two different change detcetion techniques. 
  
We compared the detection results using the different combinations of the implmented background estimate and chnage detection techniques.

# 2. Data Set

We used the labelled PETS2006 baseline data subset from the ([dataset-2012](http://jacarini.dinf.usherbrooke.ca/dataset2012/)):
* It consist of 1200 color video frames of an indoor scene acquired by fixed camera 
* A sample background and background images from the input data set are illustrated in figure below.

<div class="row">
  <div class="column">
    <img align="left" width="400" src="figures/in000001.jpg">
  </div>
  <div class="column">
    <img lign="right" width="400" src="figures/in000100.jpg">
  </div>
</div>
    
# 3. Approach

 Suppose that at time **t**, we intriduce the following notations:
 * **F(t)**: The camera acquired frame.
 * **B(t)**: The estimated background image.
 * **C(t)**: The detected change image.
 
 The implemented people detection approach is based on the following 2 steps:

1. Estimate the backgound image: We explored the four different background estimation techniques:
   * B(t): The first frame, prior to time t, which is known to contain only the scene background and no foreign objects temporarily introduced to the scene.
   * B(t): The last frame, prior to time t, for which no changes were detected, thus it should contain only the scene background and no foreign objects temporarily introduced to the scene.
   *  B(t): The average of all frames F(s), s<t, for which no changes were detected, thus it should contain only the scene background and no foreign objects temporarily introduced to the scene.
   * B(t): The average of all frames F(s), s<t.
2. Estimate the change between the current frame foreground image and the background: Wee explored two different change detcetion techniques. 
   * Absolute background subtraction: **C(t) = |F(t) - B(t)|**, where **|.|** indicate the absolute value.
   * The cross-correlation: **C(t) = 1 - [cc(F(t), B(t))]^2|**, where **cc(.,.)** indicate the cross-correlation between 2 images
  
Next, we shall illusttate each of these techniques.
  
## 3.1 Background Estimation (BE)

In this section, we briefly illusttate the backgground estimation results using each of the four background subtraction estimation techniques, described above.

<table>
  <tr>
    <td> BE Method 1 </td>
    <td> <img src="figures/estimated-background-method-1-frame-1.jpg" width="400"></td>
  </tr> 
  <tr>
    <td> BE Method 2 </td>
    <td> <img src="figures/estimated-background-method-2-frame-100.jpg" width="400></td>
  </tr>
  <tr>
    <td> BE Method 3 </td>
    <td> <img src="figures/estimated-background-method-3-frame-100.jpg" width="400"></td>
  </tr> 
  <tr>
    <td> BE Method 4 </td>
    <td> <img src="figures/estimated-background-method-4-frame-100.jpg" width="400"></td>
  </tr>
</table>
    


## 3.2 Change Detection (CD)


div class="row">
  <div class="column">
    <img align="center" width="400" src="figures/estimated-background-method-1-frame-1.jpg">
  </div>
  <div class="column">
    <img align="center" width="400" src="figures/estimated-background-method-2-frame-100.jpg">
  </div>
     <div class="column">
    <img align="center" width="400" src="figures/estimated-background-method-3-frame-100.jpg">
  </div>
  <div class="column">
    <img align="center" width="400" src="figures/estimated-background-method-4-frame-100.jpg">
  </div>
  <div class="column">
    <img align="center" width="400" src="figures/estimated-background-method-1-frame-1.jpg">
  </div>
  <div class="column">
    <img align="center" width="400" src="figures/estimated-background-method-2-frame-100.jpg">
  </div>
     <div class="column">
    <img align="center" width="400" src="figures/estimated-background-method-3-frame-100.jpg">
  </div>
  <div class="column">
    <img align="center" width="400" src="figures/estimated-background-method-4-frame-100.jpg">
  </div>
</div>





### 4.6.3 Final Assessment

In this final assessment, we compare the performance, in terms of its prediction accuracy, of the trained SVM model using default paramaters, as well as the more optimal parameters, as identified by the Grid-Search and the Random-Serach algorithms. Clearly, apply the serach algorithms has resulted in using more suitable hyperperameters for our DIGITS data set and yielding better classification accuracy.


| Model Name       | Default Parameters | Random-Search Parameters | Grid-Search Parameters 
|------------------|-------------------|--------------------|---------------------------------|
|SVM          | 0.9416666666666667       | 0.9638212311280369                |  |0.9770349399922571 |


# 5. Comparison of the 5 ML classification algorithms

The table below compares the performance of the 5 evaluated ML classification algorithms on the DIGITS data set using the default parameters as well as the more optimal paramaters as obtained by the grid-search and randon-search algorithms. We note:

* As expected, for every ML algorithm,  the grid-search algorithm consistently yields the significant improvement as compared to using the default hyperparameters
* Also, as expected and for every ML algorithm,  the random-search algorithm consistently yields the significant improvement as compared to using the default hyperparameters but in all the cases the improvment is not as good as the grid-search algorithm. 
* Although, for every ML algorithm, the grid-search algorithm yields the best calssification results, this comes at the expense of expensive computational complexity to search the full grid for more optimal paramaters.
* The SVM algorithm yields the best callification accurary when using the default algorithm paramaters as well as when using the optimized hyperparamaters, as obtained by the grid-search algorithm


| Model Name       | Default Parameters |  Random-Search Parameters |  Grid-Search Parameters
|------------------|-------------------|--------------------|---------------------------------|
|Support Vector Machine (SVM)          | 0.9416666666666667       | 0.9638212311280369               | 0.9770349399922571  |
|Logistric Regression (LR)         |   0.8577777777777778      |   0.9287437004246013             |  0.9406361007847996 |
|Random Forest (RF)          | 0.9333333333333333       |  0.9369451148879789              | 0.9492111885404567  |
| Multi-Layer Perceptron (MLP)          |0.9138888888888889       |  0.9366886072810814        | 0.9617257065427797  |
|Stochastic Gradient Descent (SGD)         | 0.8944444444444445       |  0.9199881063532219              | 0.9276495354239256  |



The implementation of each of these algorithms case be found in **./code/** directory of this repository. 

# 6. Conclusions

In this project, we demonstrated how to use scikit-learn to recognize images of hand-written digits, using various Machine Learning (ML) built-in image classification functionalities and compare their performance. We applied and implemented the standard ML via Scikit-Learn process, and illustrated the output of each step. 
