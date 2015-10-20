function [ output ] = nytro_train( X , Y , varargin )
    % NYTRO NYstrom iTerative RegularizatiOn - Early Stopping cross validation
    %   Performs selection of the Early Stopping regularization parameter
    %   in the context of Nystrom low-rank kernel approximation
    %
    %   INPUT
    %   =====
    %
    %   X : Input samples
    %
    %   Y : Output signals
    %
    %   config.  \\ optional configuration structure. See config_set.m for
    %            \\ default values
    %
    %          data.
    %               shuffle : 1/0 flag - Shuffle the training indexes
    %
    %          crossValidation.
    %                          storeTrainingError : 1/0 - Store training error
    %                                               flag
    %
    %                          validationPart : in (0,1) - Fraction of the
    %                                           training set used for validation
    %
    %                          recompute : 1/0 flag - Recompute solution using the
    %                                      whole training set after cross validation
    %
    %                          errorFunction : handle to the function used for
    %                                          error computation
    %
    %                          codingFunction : handle to the function used for
    %                                           coding (in classification tasks)
    %
    %                          stoppingRule : handle to the stopping rule function
    %
    %                          windowSize : Size of the window used by the
    %                                       stopping rule (default = 10)
    %
    %                          threshold : Threshold used by the
    %                                      stopping rule (default = 0)
    %
    %          filter.
    %                 fixedIterations : Integer - fixed number of iterations
    %
    %                 maxIterations :  Integer - maximum number of iterations
    %                                  (for cross validation)
    %
    %                 gamma : Scalar - override gradient descent step
    %
    %          kernel.
    %                 kernelFunction : handle to the kernel function
    %
    %                 kernelParameters : vector of size r. r is the number of
    %                                    parameters required by kernelFunction.
    %
    %                 m : Integer - Nystrom subsampling level
    %
    %   OUTPUT
    %   ======
    %
    %   output.
    %
    %          best.
    %               validationError
    %               iteration
    %               alpha
    %
    %          time.
    %               kernelComputation
    %               crossValidationTrain
    %               crossValidationEval
    %               crossValidationTotal
    %
    %          errorPath.
    %                    training
    %                    validation

    % Check config struct
    if nargin >2
        config = varargin{1};
    else
        config = config_set();  % Construct default configuration structure
    end

    ntr = size(Y,1);
    t = size(Y,2);  % number of output signals

    % Best parameters variables init
    output.best = struct();
    output.best.alpha = zeros(config.kernel.m,t);

    if (isempty(config.filter.fixedIterations) && isempty(config.filter.maxIterations)) || ...
       (~isempty(config.filter.fixedIterations) && ~isempty(config.filter.maxIterations))

        error('Specify either a fixed or a maximum number of iterations')

    elseif isempty(config.filter.fixedIterations) && ~isempty(config.filter.maxIterations) 

        %%% Perform cross validation

        output.best.validationError = Inf;
        output.best.t = Inf;

        % Error buffers
        if config.crossValidation.storeValidationError == 1
            output.errorPath.validation = zeros(1,config.filter.maxIterations) * NaN;
        else
            output.errorPath.training = [];
        end
        if config.crossValidation.storeTrainingError == 1
            output.errorPath.training = zeros(1,config.filter.maxIterations) * NaN;
        else
            output.errorPath.training = [];
        end

        % Subdivide training set in training1 and validation

        ntr1 = floor( ntr * ( 1 - config.crossValidation.validationPart ));

        if config.data.shuffle == 1

            shuffledIdx = randperm(ntr);
            trainIdx = shuffledIdx(1 : ntr1);
            valIdx = shuffledIdx(ntr1 + 1 : end);

        else

            trainIdx = 1 : ntr1;
            valIdx = ntr1 + 1 : ntr;

        end

        Xtr1 = X(trainIdx,:);
    %     Ytr1 = Y(trainIdx,:);
    %     Xval = X(valIdx,:);
    %     Yval = Y(valIdx,:);

        % Initialize Train kernel

        % Subsample training examples for Nystrom approximation
        nysIdx = randperm(ntr1 , config.kernel.m);

        % Compute kernel
        tic
        Knm = kernelFunction(Xtr, Xtr1(nysIdx,:), config.kernel.kernelParameters);
        Kmm = Knm(trainIdx(nysIdx),:);
        R = chol( ( Kmm + Kmm') / 2 + 1e-10 * eye(config.kernel.m));  % Compute upper Cholesky factor of Kmm
        output.time.kernelComputation = toc;

        alpha = zeros(config.kernel.m,t);
        beta = zeros(config.kernel.m,t);
        if isempty(config.filter.gamma)
            gamma = 1/(norm(Knm/R)^2);
        else
            gamma = config.filter.gamma;
        end

        indZ = zeros(ntr, t);
        indZ(trainIdx,:) = ones(ntr1,t);

        for iter = 1:config.filter.maxIterations

            % Update filter
            tic
            tmp0 = Knm * alpha - Y;
            tmp0 = tmp0 .* indZ;
            beta = beta -  gamma * ( R' \ ( Knm' * tmp0 ) );
            output.time.crossValidationTrain = output.time.crossValidationTrain + toc;

            % Evaluate validation error
            tic
            alpha = R\beta; % Compute alpha

            YtrainValPred = Knm * alpha;
            if ~isempty(config.crossValidation.codingFunction)
                YvalPred = config.crossValidation.codingFunction(YtrainValPred(valIdx,:));
            else
                YvalPred = YtrainValPred(valIdx,:);
            end
            output.errorPath.validation(iter) = config.crossValidation.errorFunction(Y(valIdx,:) , YvalPred);
            output.time.crossValidationEval = output.time.crossValidationEval + toc;

            if output.errorPath.validation(iter) < output.best.validationError
                output.best.validationError = output.errorPath.validation(iter);
                output.best.iteration = iter;
                output.best.alpha = alpha;
            end

            if config.crossValidation.storeTrainingError == 1
                % Evaluate training error
                if ~isempty(config.crossValidation.codingFunction)
                    YtrainPred = config.crossValidation.codingFunction(YtrainValPred(trainIdx,:));
                else
                    YtrainPred = YtrainValPred(trainIdx,:);
                end
                output.errorPath.training(iter) = config.crossValidation.errorFunction(Y(trainIdx,:) , YtrainPred);    
            end

            % Apply Stopping Rule
            if ~isempty(config.crossValidation.stoppingRule)

                stop  = config.crossValidation.stoppingRule(...
                            output.errorPath.validation(1:iter) , ...
                            config.crossValidation.windowSize , ...
                            config.crossValidation.thres);

                if stop == 1
                    break
                end
            end

            output.time.crossValidationTotal = output.time.crossValidationEval + output.time.crossValidationTrain;
        end    

        if config.crossValidation.retraining == 1

            %%% Retrain on whole dataset

            tic
            beta = zeros(config.kernel.m,t);
            if isempty(config.filter.gamma)
                gamma = 1/(norm(Knm/R))^2;
            else
                gamma = config.filter.gamma;
            end

            % Compute solution
            for iter = 1:output.best.iteration
                % Update filter
                beta = beta -  gamma * (R' \ ( Knm' * ( Knm * (R \ beta) - Y ) ) );
            end

            output.best.alpha = R\beta; % Get alpha from beta

            output.time.fullTraining = toc;
        end


    elseif ~isempty(config.filter.fixedIterations) && isempty(config.filter.maxIterations) 

        %%% Just train

        
        % Initialize Train kernel

        % Subsample training examples for Nystrom approximation
        nysIdx = randperm(ntr , config.kernel.m);

        % Compute kernels
        tic
        Knm = kernelFunction(X, X(nysIdx,:), config.kernel.kernelParameters);
        Kmm = Knm(nysIdx,:);
        R = chol( ( Kmm + Kmm') / 2 + 1e-10 * eye(config.kernel.m));  % Compute upper Cholesky factor of Kmm    
        output.time.kernelComputation = toc;

        tic
        beta = zeros(config.kernel.m,t);
        if isempty(config.filter.gamma)
            gamma = 1/(norm(Knm/R))^2;
        else
            gamma = config.filter.gamma;
        end

        % Compute solution
        for iter = 1:output.best.iteration
            % Update filter
            beta = beta -  gamma * (R' \ ( Knm' * ( Knm * (R \ beta) - Y ) ) );
        end

        output.best.alpha = R\beta; % Get alpha from beta

        output.time.fullTraining = toc;
    end
end
