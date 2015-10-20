function [ output ] = nytro_train( X , Y , config )
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
%   config.
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
%          errorPath.
%                    training
%                    validation

ntr = size(config.data.Y,1);
t = size(config.data.Y,2);  % number of output signals

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
    
    Xtr1 = config.data.X(trainIdx,:);
%     Ytr1 = config.data.Y(trainIdx,:);
%     Xval = config.data.X(valIdx,:);
%     Yval = config.data.Y(valIdx,:);
    
    % Initialize Train kernel

    % Subsample training examples for Nystrom approximation
    nysIdx = randperm(ntr1 , config.kernel.m);

    Knm = kernelFunction(Xtr, Xtr1(nysIdx,:), kernelParameters);
    Kmm = Knm(trainIdx(nysIdx),:);
    
    R = chol( ( Kmm + Kmm') / 2 + 1e-10 * eye(config.kernel.m));  % Compute upper Cholesky factor of Kmm
    alpha = zeros(config.kernel.m,t);
    beta = zeros(config.kernel.m,t);
    if isempty(config.filter.gamma)
        config.filter.gamma = 1/(norm(Knm/R)^2);
    end
    
    indZ = zeros(ntr, t);
    indZ(trainIdx,:) = ones(ntr1,t);
    
    for iter = 1:config.filter.maxIterations
        
        % Update filter
        tmp0 = Knm * alpha - config.data.Y;
        tmp0 = tmp0 .* indZ;
        beta = beta -  gamma * ( R' \ ( Knm' * tmp0 ) );

        % Evaluate validation error
        alpha = R\beta; % Compute alpha

        YtrainValPred = Knm * alpha;
        if ~isempty(config.crossValidation.codingFunction)
            YvalPred = config.crossValidation.codingFunction(YtrainValPred(valIdx,:));
        else
            YvalPred = YtrainValPred(valIdx,:);
        end
        output.errorPath.validation(iter) = config.crossValidation.errorFunction(config.data.Y(valIdx,:) , YvalPred);
        
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
            output.errorPath.training(iter) = config.crossValidation.errorFunction(config.data.Y(trainIdx,:) , YtrainPred);    
        end
        
        % Apply Stopping Rule
        if ~isempty(config.crossValidation.stoppingRule)
            
            
            
            
        end
    end    
    
    
    
    
    
    
    
    
    if config.crossValidation.retraining == 1
        
        %%% Retrain on whole dataset
    end
    
elseif ~isempty(config.filter.fixedIterations) && isempty(config.filter.maxIterations) 
    
    %%% Just train
    
    
end





%     [~,ia] = setdiff(trainIdx,sampledColsIdx);
%     if numel(ia) ~= (numel(trainIdx) - numel(sampledColsIdx))
%         error('The m sampled indexes must belong to the training set.');
%     end
%     
%     m = size(Knm,2);
%     t = size(Y,2);
%     
%     % Time benchmarking buffers
%     time = struct();
%     time.train_buf = zeros(1,tMax);
%     time.eval_buf = zeros(1,tMax);
%     time.total_buf = zeros(1,tMax);
%     time.cumulative_train_buf = zeros(1,tMax);
%     time.cumulative_eval_buf = zeros(1,tMax);
%     time.cumulative_total_buf = zeros(1,tMax);
%     
%     % Error buffers
%     valErr_buf = zeros(1,tMax);
%     if computeTrainingErr == 1
%         trainErr_buf = zeros(1,tMax);
%     else
%         trainErr_buf = [];
%     end
%     if computeTestErr == 1
%         testErr_buf = zeros(1,tMax);
%     else
%         testErr_buf = [];
%     end
%     
% 
%     % Solutions buffer
%     if computeTestErr == 1
%         alpha_buf = zeros(m,tMax);
%     else
%         alpha_buf = [];
%     end
%     
%     
%     % Best parameters variables init
%     best = struct();
%     best.valErr = Inf;
%     best.t = Inf;
%     best.alpha = zeros(m,t);
%     
%     % Initialize
%     R = chol( ( Kmm + Kmm') / 2 + 1e-10 * eye(size(Kmm)));  % Compute upper Cholesky factor of Kmm
%     alpha = zeros(m,t);
%     beta = zeros(m,t);
%     if isempty(gamma)
%         gamma = 1/(norm(Knm/R)^2);
%     end
%     
%     indZ = zeros(size(Y,1), size(Y,2));
%     indZ(trainIdx,:) = ones(numel(trainIdx),size(Y,2));
%     
%     for t = 1:tMax
%         
%         % Update filter
%         tic
%         tmp0 = Knm * alpha - Y;
%         tmp0 = tmp0.*indZ;
%         beta = beta -  gamma * (R' \ ( Knm' * tmp0 ) );
%         time.train_buf(t) = toc;
%         time.cumulative_train_buf(t) = sum(time.train_buf);
%         % Evaluate validation error
%         tic
%         alpha = R\beta; % Get alpha from beta
%         tmp = toc;
%         if storeAlphas == 1
%             alpha_buf(:,t) = alpha;
%         end
%         tic
%         YtrainValPred = Knm * alpha;
%         if ~isempty(codingFunction)
%             YvalPred = codingFunction(YtrainValPred(valIdx,:));
%         else
%             YvalPred = YtrainValPred(valIdx,:);
%         end
%         valErr_buf(t) = errorFunction(Y(valIdx,:) , YvalPred);
%         time.eval_buf(t) = toc + tmp;
%         time.cumulative_eval_buf(t) = sum(time.eval_buf);
%         
%         if valErr_buf(t) < best.valErr
%             best.valErr = valErr_buf(t);
%             best.t = t;
%             best.alpha = alpha;
%             best.trainTime = sum(time.train_buf);
%             best.totalTime = sum(time.train_buf + time.eval_buf);
%         end
% 
%         if computeTrainingErr == 1
%             % Evaluate training error
%             if ~isempty(codingFunction)
%                 YtrainPred = codingFunction(YtrainValPred(trainIdx,:));
%             else
%                 YtrainPred = YtrainValPred(trainIdx,:);
%             end
%             trainErr_buf(t) = errorFunction(Y(trainIdx,:) , YtrainPred);    
%         end
%         
%         if computeTestErr == 1
%             % Evaluate test error
%             
%             YtestPred = KnmTe *alpha;
%             if ~isempty(codingFunction)
%                 YtestPred = codingFunction(YtestPred);
%             end            
%             testErr_buf(t) = errorFunction(Yte , YtestPred);    
%         end        
%     end
%     best.testError = testErr_buf(best.t);
%     time.total_buf = time.train_buf + time.eval_buf;
%     time.cumulative_total_buf = time.cumulative_train_buf + time.cumulative_eval_buf;    
end
