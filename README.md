
-------------------------------------
\>\>\> The NYTRO Matlab Package  \>\>\> 
========================
***NYstrom iTerative RegularizatiOn***

-------------------------------------


Copyright (C) 2015, [Laboratory for Computational and Statistical Learning](http://lcsl.mit.edu/#/home) (IIT@MIT).
All rights reserved.
Please see attached license file.

Introduction
============

This Matlab package provides an implementation of the NYTRO algorithm presented in the following work:

> *Tomas Angles, Raffaello Camoriano, Alessandro Rudi, Lorenzo Rosasco*, ***NYTRO: When Subsampling Meets Early Stopping***, 19 Oct 2015, http://arxiv.org/abs/1510.05684

Early stopping is a well known approach to reduce the time complexity for performing training and model selection of large scale learning machines. On the other hand, memory/space (rather than time) complexity is the main constraint in many applications, and randomized subsampling techniques have been proposed to tackle this issue. In NYTRO, we combine early stopping and subsampling ideas, proposing a form of randomized iterative regularization based on early stopping and subsampling. In this way, we overcome the memory bottle neck of exact Early Stopping algorithms such as the kernelized Landweber iteration. Moreover, NYTRO can also be faster than other subsampled algorithms, such as Nystrom Kernel Regularized Least Squares (NKRLS), especially when a stopping rule is used.

This software package provides a simple and extendible interface to NYTRO. It has been tested on MATLAB r2014b. Examples are available  in the "examples" folder.



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
    * crossValidation.codingFunction = [ ]
    * crossValidation.stoppingRule = @windowLinearFitting
    * crossValidation.windowSize = 10
    * crossValidation.threshold = 0

* **Filter**
    * filter.fixedIterations  = [ ]
    * filter.maxIterations  = 500
    * filter.gamma  = [ ]

* **Kernel**
    * kernel.kernelFunction  = @gaussianKernel
    * kernel.kernelParameters = 1
    * kernel.m = 100
    
    
    
    
Output structures
======

*nytro_train*
----

         best.
              validationError
              iteration
              alpha

         nysIdx : Vector - selected Nystrom approximation indexes

         time.
              kernelComputation
              crossValidationTrain
              crossValidationEval
              crossValidationTotal

         errorPath.
                   training
                   validation
```

*nytro_test*
