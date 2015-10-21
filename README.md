                -------------------------------------
                |     The NYTRO Matlab Package      |
                |  NYstrom iTerative RegularizatiOn |
                -------------------------------------

Copyright (C) 2015, Laboratory for Computational and Statistical Learning (IIT@MIT)
All rights reserved.

Please see attached license file.


NYTRO NYstrom iTerative RegularizatiOn - Early Stopping cross validation
  Performs selection of the Early Stopping regularization parameter
  in the context of Nystrom low-rank kernel approximation

  INPUT
  =====

  X : Input samples

  Y : Output signals

  config.  \\ optional configuration structure. See config_set.m for
           \\ default values

         data.
              shuffle : 1/0 flag - Shuffle the training indexes

         crossValidation.
                         storeTrainingError : 1/0 - Store training error
                                              flag

                         validationPart : in (0,1) - Fraction of the
                                          training set used for validation

                         recompute : 1/0 flag - Recompute solution using the
                                     whole training set after cross validation

                         errorFunction : handle to the function used for
                                         error computation

                         codingFunction : handle to the function used for
                                          coding (in classification tasks)

                         stoppingRule : handle to the stopping rule function

                         windowSize : Size of the window used by the
                                      stopping rule (default = 10)

                         threshold : Threshold used by the
                                     stopping rule (default = 0)

         filter.
                fixedIterations : Integer - fixed number of iterations

                maxIterations :  Integer - maximum number of iterations
                                 (for cross validation)

                gamma : Scalar - override gradient descent step

         kernel.
                kernelFunction : handle to the kernel function

                kernelParameters : vector of size r. r is the number of
                                   parameters required by kernelFunction.

                m : Integer - Nystrom subsampling level

  OUTPUT
  ======

  output.

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
