classdef linearKernel < kernel
    %GAUSSIAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        numMapParGuesses        % Number of guesses for the parameters
        mapParGuesses           % Parameter ranges container
        currentParIdx           % Current parameter combination indexes map container
        currentPar              % Current parameter combination map container
        
        X1
        X2
        
        n               % Number of X1 samples
        m               % Number of X2 samples
        SqDistMat       % n-by-m squared distances matrix 

    end
    
    methods
        % Construct a size(X1,1) * size(X2,1) Gaussian kernel object 
        function obj = linearKernel( X1 , X2 , varargin)
            obj.init( X1 , X2 , varargin);
        end
        
        function init( obj , X1 , X2 , varargin)
            
            p = inputParser;
            
            %%%% Required parameters
            
            checkX1 = @(x) size(x,1) > 0 && size(x,2) > 0;
            checkX2 = @(x) size(x,1) > 0 && size(x,2) > 0;
            
            addRequired(p,'X1',checkX1);
            addRequired(p,'X2',checkX2);
            
            %%%% Optional parameters
            % Optional parameter names:
            % numMapParGuesses , mapParGuesses, verbose
            
            % mapParGuesses       % Map parameter guesses cell array
            defaultMapParGuesses = [];
            checkMapParGuesses = @(x) ismatrix(x) && size(x,2) > 0 ;            
            addParameter(p,'mapParGuesses',defaultMapParGuesses,checkMapParGuesses);                    
            
            % numMapParGuesses        % Number of map parameter guesses
            defaultNumMapParGuesses = [];
            checkNumMapParGuesses = @(x) x > 0 ;            
            addParameter(p,'numMapParGuesses',defaultNumMapParGuesses,checkNumMapParGuesses);        
            
            % verbose             % 1: verbose; 0: silent      
            defaultVerbose = 0;
            checkVerbose = @(x) (x == 0) || (x == 1) ;            
            addParameter(p,'verbose',defaultVerbose,checkVerbose);
            
            % Parse function inputs
            if isempty(varargin{:})
                parse(p, X1 , X2)
            else
                parse(p, X1 , X2 , varargin{:}{:})
            end
            
            % Assign parsed parameters to object properties
            fields = fieldnames(p.Results);
            fieldsToIgnore = {'X1','X2'};
            fields = setdiff(fields, fieldsToIgnore);
            for idx = 1:numel(fields)
                obj.(fields{idx}) = p.Results.(fields{idx});
            end
            
            %%% Joint parameters validation
            if size(X1,2) ~= size(X2,2)
                error('size(X1,2) ~= size(X2,1)');
            end
            
            if size(X2,2) ~= size(X1,2)
                error('X1 and X2 have incompatible sizes');
            end
            
            obj.X1 = X1;
            obj.X2 = X2;
            
            % Set dimensions and compute square distances matrix
            obj.n = size(X1 , 1);
            obj.m = size(X2 , 1);
            
            obj.currentParIdx = 0;
            obj.currentPar = [];
        end
                
        % Computes the range for the hyperparameter guesses
        function obj = range(obj)      

            obj.mapParGuesses = 0;
        end
%         
        % Computes the kernel matrix K based on SqDistMat and
        % kernel parameters
        function compute(obj , kerPar)
                obj.K = obj.X1*obj.X2';
        end
        
        % returns true if the next parameter combination is available and
        % updates the current parameter combination 'currentPar'
        function available = next(obj)

            % If any range for any of the parameters is not available, recompute all ranges.
%             if cellfun(@isempty,obj.mapParGuesses)
%                 obj.range();
%             end
            if isempty(obj.mapParGuesses)
                obj.range();
            end
            
            available = false;
%             if length(obj.mapParGuesses) > obj.currentParIdx
%                 obj.currentParIdx = obj.currentParIdx + 1;
%                 obj.currentPar = obj.mapParGuesses{obj.currentParIdx};
%                 available = true;
%             end
            if length(obj.mapParGuesses) > obj.currentParIdx
                obj.currentParIdx = obj.currentParIdx + 1;
                obj.currentPar = obj.mapParGuesses(:,obj.currentParIdx);
                available = true;
            end
        end
    end
end
