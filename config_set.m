function [ config ] = config_set( varargin )
%CONFIG_SET Constructs the default  configuration stucture to be used by
%nytro_train

    % Set default configuration fields
    config = struct();

    % data
    config.data.shuffle = 1;

    % crossValidation
    config.crossValidation.storeTrainingError = 0;
    config.crossValidation.validationPart = 0.2;
    config.crossValidation.recompute = 0;
    config.crossValidation.errorFunction = @rmse;
    config.crossValidation.codingFunction = [];
    config.crossValidation.stoppingRule = @windowLinearFitting;
    config.crossValidation.windowSize = 10;
    config.crossValidation.threshold = 0;

    % filter
    config.filter.fixedIterations  = [];
    config.filter.maxIterations  = 500;
    config.filter.gamma  = [];

    % kernel
    config.kernel.kernelFunction  = @gaussianKernel;
    config.kernel.kernelParameters = 1;
    config.kernel.m = 100;

    % Parse function inputs
    if ~isempty(varargin)

        % Assign parsed parameters to object properties
        fields = varargin(1:2:end);
        for idx = 1:numel(fields)
            
            currField = fields{idx};
            % Parse current field
            k = strfind(currField , '.');
            k = [0 ; k ; (numel(currField)+1)];
            tokens = cell(1,(numel(k) - 1));
            for i = 1 : (numel(k) - 1);
                tokens{i} = currField( (k(i)+1) : (k(i+1)-1) );
            end

            cmdStr = 'config';
            for i = 1 : (numel(tokens) - 1)
                cmdStr = strcat(cmdStr , '.(''' , tokens{i} , ''')');
            end
            cmdStr = strcat(cmdStr , '.(''' , tokens{end} , ''') = varargin{2*(idx-1) + 2};');
            eval(cmdStr);
        end
    end
end

