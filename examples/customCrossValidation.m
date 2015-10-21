
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