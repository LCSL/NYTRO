
-------------------------------------
The NYTRO Matlab Package
========================
***NYstrom iTerative RegularizatiOn***

-------------------------------------

Copyright (C) 2015, [Laboratory for Computational and Statistical Learning](http://lcsl.mit.edu/#/home) (IIT@MIT).
All rights reserved.

*By Raffaello Camoriano, Alessandro Rudi and Lorenzo Rosasco*

Please see attached license file.

Introduction
============

This Matlab package provides an implementation of the NYTRO algorithm presented in the following work:

> *Tomas Angles, Raffaello Camoriano, Alessandro Rudi, Lorenzo Rosasco*, ***NYTRO: When Subsampling Meets Early Stopping***, 19 Oct 2015, http://arxiv.org/abs/1510.05684

Early stopping is a well known approach to reduce the time complexity for performing training and model selection of large scale learning machines. On the other hand, memory/space (rather than time) complexity is the main constraint in many applications, and randomized subsampling techniques have been proposed to tackle this issue. In NYTRO, we combine early stopping and subsampling ideas, proposing a form of randomized iterative regularization based on early stopping and subsampling. In this way, we overcome the memory bottle neck of exact Early Stopping algorithms such as the kernelized Landweber iteration. Moreover, NYTRO can also be faster than other subsampled algorithms, such as Nystrom Kernel Regularized Least Squares (NKRLS), especially when a stopping rule is used.

This software package provides a simple and extendible interface to NYTRO. It has been tested on MATLAB r2014b. Examples are available  in the "examples" folder.

Examples
====

Automatic training with default options
----

```matlab

load breastcancer

% Perform default cross validation
[ training_output ] = nytro_train( Xtr , Ytr );

% Perform predictions on the test set and evaluate results
[ prediction_output ] = nytro_test( Xtr , Xte , Yte , training_output);
```

Specifying a custom kernel parameter
----
```matlab

load breastcancer

% Customize configuration
config = config_set('kernel.kernelParameters' , 0.9 , ...           % Change gaussian kernel parameter (sigma)
                    'kernel.kernelFunction' , @gaussianKernel);     % Change kernel function

% Perform default cross validation
[ training_output ] = nytro_train( Xtr , Ytr , config);

% Perform predictions on the test set and evaluate results
[ prediction_output ] = nytro_test( Xtr , Xte , Yte , training_output);
```

Specifying the subsampling level *m*
----
```matlab

load breastcancer

% Customize configuration
config = config_set('kernel.m' , 200);     % Change kernel function

% Perform default cross validation
[ training_output ] = nytro_train( Xtr , Ytr , config);

% Perform predictions on the test set and evaluate results
[ prediction_output ] = nytro_test( Xtr , Xte , Yte , training_output);
```

Some more customizations
----
```matlab

load breastcancer

% Customize configuration
config = config_set('crossValidation.threshold' , -0.002 , ...      % Change stopping rule threshold
                    'crossValidation.recompute' , 1 , ...           % Recompute the solution after cross validation
                    'crossValidation.codingFunction' , @zeroOneBin , ...   % Change coding function
                    'crossValidation.errorFunction' , @classificationError , ...   % Change error function
                    'crossValidation.stoppingRule' , @windowSimple , ...   % Change stopping rule function
                    'kernel.m' , 200 , ...                          % Modify the subsampling level (default m = 100)
                    'kernel.kernelParameters' , 0.9 , ...           % Change gaussian kernel parameter (sigma)
                    'kernel.kernelFunction' , @gaussianKernel);     % Change kernel function

% Perform default cross validation
[ training_output ] = nytro_train( Xtr , Ytr , config);

% Perform predictions on the test set and evaluate results
[ prediction_output ] = nytro_test( Xtr , Xte , Yte , training_output);
```
**For a complete list of customizable configuration options, see the next section.**


Configuration Parameters
====
All the configurable parameters of the algorithm can be set by means of the provided *config_set* function, which returns a custom configuration structure that can be passed to the *nytro_train* function. If no configuration structure is passed, *nytro_train* uses the default configuration parameters listed below. *nytro_train* performs the training by running the NYTRO algorithm. It returns a structure with the trained model, which can then be passed to *nytro_test* for performing predictions and test error assessment.

This is an example of how the configuration parameters can be customized by means of the *config_set* function. See the code in "examples/customCrosValidation" for more details.

```matlab
% Customize configuration
config = config_set('crossValidation.threshold' , -0.002 , ...      % Change stopping rule threshold
                    'crossValidation.recompute' , 1 , ...           % Recompute the solution after cross validation
                    'crossValidation.codingFunction' , @zeroOneBin , ...   % Change coding function
                    'crossValidation.errorFunction' , @classificationError , ...   % Change error function
                    'crossValidation.stoppingRule' , @windowSimple , ...   % Change stopping rule function
                    'kernel.m' , 200 , ...                          % Modify the subsampling level (default m = 100)
                    'kernel.kernelParameters' , 0.9 , ...           % Change kernel parameter (sigma)
                    'kernel.kernelFunction' , @gaussianKernel);     % Change kernel function
```

**The default configuration parametrs are reported below:**
* **Data**
    * data.shuffle = 1

* **Cross Validation**
    * crossValidation.storeTrainingError = 0
    * crossValidation.validationPart = 0.2
    * crossValidation.recompute = 0
    * crossValidation.errorFunction = @rmse
        * Provided functions (*errorFunctions* folder):
            *@rmse: root mean squared error
            *@classificationError : Relative classification error (error rate)
        * Custom functions can be implemented by the user, simply following the input-output structure of any of the provided functions.
    * crossValidation.codingFunction = [ ]
        * Provided functions (*codingFunctions* folder):
            *@plusMinusOneBin: Class 1: +1, class 2: -1
            *@zeroOneBin : Class 1: +1, class 2: 0
        * Custom functions can be implemented by the user, simply following the input-output structure of any of the provided functions.
    * crossValidation.stoppingRule = @windowLinearFitting
        * Provided functions (*stoppingRules* folder):
            *@windowSimple: Stops if the ratio e1/e0 >= (1-threshold). e1 is the error of the most recent iteration. e0 is the error of the oldest iteration in the window
            *@windowAveraged : Works like @windowSimple, but taking e1 and e0 as the mean over the oldest and newest 10% of the points contained in the window (to increase stability).
            *@windowMedian : Works like @windowAveraged, but computes the median rather than the mean.
            *@windowLinearFitting : Works like @windowSimple, but uses a linear fitting of all the points in the window to obtain a more stable estimate of e0 and e1.
        * Custom functions can be implemented by the user, simply following the input-output structure of any of the provided functions.
    * crossValidation.windowSize = 10
    * crossValidation.threshold = 0

* **Filter**
    * filter.fixedIterations  = [ ]
    * filter.maxIterations  = 500
    * filter.gamma  = [ ]

* **Kernel**
    * kernel.kernelFunction  = @gaussianKernel
        * Provided functions:
            *@gaussianKernel : Gaussian kernel function. In this case, the kernel parameter is the bandwidth sigma.
        * Custom functions can be implemented by the user, simply following the input-output structure of any of the provided functions.
    * kernel.kernelParameters = 1
    * kernel.m = 100
    
    
Output structures
======

*nytro_train*
----

* best.
    * validationError : Best validation error found in cross validation
    * iteration : Best filter iteration
    * alpha : Best coefficients vector

* nysIdx : Vector - selected Nystrom training samples indexes

* time.
    * kernelComputation : Time for kernel computation
    * crossValidationTrain : Time for filter iterations during cross validation
    * crossValidationEval : Time for validation error evaluation during cross validation
    * crossValidationTotal : Cumulative cross validation time
    * fullTraining : Training time in the just-train case (no cross validation)

* errorPath.
    * training : Training error path for each of the computed iterations
    * validation : Validation error path for each of the computed iterations

*nytro_test*
----

* YtePred : Predicted output
* testError : Test error
* time.
    * kernelComputation : Kernel computation time
    * prediction : Prediction computation time
    * errorComputation : Error computation time