classdef randomFeaturesGaussian < randomFeatures
    %RANDOMFEATURES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        
        prevPar
        
        verbose
        
        Y

        ntr
        
        numMapParRangeSamples   % Number of samples of X considered for estimating the maximum and minimum sigmas
        maxRank                % Maximum number of random features to be used
        
        kernelType      % Type of approximated kernel

        filterParGuesses        % Filter parameter guesses
        numFilterParGuesses     % Number of filter parameter guesses
                
        mapParGuesses
        
    end
    
    methods
        % Constructor
        function obj = randomFeaturesGaussian( X , Y , ntr , varargin )
            obj.init( X , Y , ntr , varargin);
%             obj.init( X , numMapParGuesses , numKerParRangeSamples , maxNumRF);
        end
        
        % Initialization function
        function obj = init( obj , X , Y , ntr , varargin)
            

            p = inputParser;
            
            %%%% Required parameters
            % X , Y , ntr

            checkX = @(x) size(x,1) > 0 && size(x,2) > 0;
            checkY = @(x) size(x,1) > 0 && size(x,2) > 0;
            checkNtr = @(x) x > 0;
            
            addRequired(p,'X',checkX);
            addRequired(p,'Y',checkY);
            addRequired(p,'ntr',checkNtr);
            
 
            %%%% Optional parameters
            % Optional parameter names:
            % numRFParGuesses , maxRank , numMapParGuesses , mapParGuesses , filterParGuesses , numMapParRangeSamples  , verbose
            
%             % numRFParGuesses       % Cardinality of number of samples for Nystrom approximation parameter guesses
%             defaultNumRFParGuesses = [];
%             checkNumRFParGuesses = @(x) x > 0 ;            
%             addParameter(p,'numRFParGuesses',defaultNumRFParGuesses,checkNumRFParGuesses);                    
            
            % maxRank        % Maximum rank of the Nystrom approximation
            defaultMaxRank = [];
            checkMaxRank = @(x) x > 0 ;            
            addParameter(p,'maxRank',defaultMaxRank,checkMaxRank);        
            
            % numMapParGuesses        % Number of map parameter guesses
            defaultNumMapParGuesses = [];
            checkNumMapParGuesses = @(x) x > 0 ;            
            addParameter(p,'numMapParGuesses',defaultNumMapParGuesses,checkNumMapParGuesses);        
            
            % mapParGuesses        % Map parameter guesses
            defaultMapParGuesses = [];
            checkMapParGuesses = @(x) size(x,1) > 0 && size(x,2) > 0 ;      
            addParameter(p,'mapParGuesses',defaultMapParGuesses,checkMapParGuesses);        
            
            % filterParGuesses       % Filter parameter guesses
            defaultFilterParGuesses = [];
            checkFilterParGuesses = @(x) size(x,1) > 0 && size(x,2) > 0 ;            
            addParameter(p,'filterParGuesses',defaultFilterParGuesses,checkFilterParGuesses);                    
            
            % numMapParRangeSamples        % Number of map parameter guesses
            defaultNumMapParRangeSamples = [];
            checkNumMapParRangeSamples = @(x) x > 0 ;            
            addParameter(p,'numMapParRangeSamples',defaultNumMapParRangeSamples,checkNumMapParRangeSamples);            

            % verbose             % 1: verbose; 0: silent      
            defaultVerbose = 0;
            checkVerbose = @(x) (x == 0) || (x == 1) ;            
            addParameter(p,'verbose',defaultVerbose,checkVerbose);
            
            % Parse function inputs
            if isempty(varargin{:})
                parse(p, X , Y , ntr)
            else
                parse(p, X , Y , ntr , varargin{:}{:})
            end
            
            % Assign parsed parameters to object properties
            fields = fieldnames(p.Results);
%             fieldsToIgnore = {'X1','X2'};
%             fields = setdiff(fields, fieldsToIgnore);
            for idx = 1:numel(fields)
                obj.(fields{idx}) = p.Results.(fields{idx});
            end
            
            % Joint parameters parsing
            if isempty(obj.mapParGuesses) && isempty(obj.numMapParGuesses)
                error('either mapParGuesses or numMapParGuesses must be specified');
            end    
            
            if (~isempty(obj.mapParGuesses)) && (~isempty(obj.numMapParGuesses)) && (size(obj.mapParGuesses,2) ~= obj.numMapParGuesses)
                error('The size of mapParGuesses and numMapParGuesses are different');
            end
            
            if ~isempty(obj.mapParGuesses) && isempty(obj.numMapParGuesses)
                obj.numMapParGuesses = size(obj.mapParGuesses,2);
            end
            
            if size(X,1) ~= size(Y,1)
                error('X and Y have incompatible sizes');
            end
            
            obj.d = size(X , 2);
            
            warning('Kernel used by randomFeaturesGaussianIncremental is set to @gaussianKernel');
            obj.kernelType = @gaussianKernel;

            % Conditional range computation
%             if isempty(obj.mapParGuesses)
                display('Computing range');
                obj.range();    % Compute range
%             end
            obj.currentParIdx = 0;
            obj.currentPar = [];
            
        end
        
        function mappedSample = map(obj , inputSample)
            
            % [cos sin] mapping
%             V = inputSample * obj.omega;
%             mappedSample = sqrt( 2 / obj.currentPar(1) ) * [cos(V) , sin(V)];
            
            % cos(wx+b) mapping
            V =  inputSample * obj.omega + repmat(obj.b , size(inputSample,1) , 1);            
            mappedSample = sqrt( 2 / obj.currentPar(1) ) * cos(V);
        end
        
        function obj = range(obj)
                        
            % Fixed number of Random Fourier Features
            tmpNumRF = obj.maxRank;   
           
            if isempty(obj.mapParGuesses)
                % Compute max and min sigma guesses

                % Extract an even number of samples without replacement                

                % WARNING: not compatible with versions older than 2014
                %samp = datasample( obj.X(:,:) , obj.numKerParRangeSamples - mod(obj.numKerParRangeSamples,2) , 'Replace', false);

                % WARNING: Alternative to datasample below
%                 nRows = size(obj.X,1); % number of rows
%                 nSample = obj.numMapParRangeSamples - mod(obj.numMapParRangeSamples,2); % number of samples
%                 rndIDX = randperm(nRows); 
%                 samp = obj.X(rndIDX(1:nSample), :);   
                
                nRows = size(obj.X,1); % number of rows
                nSample = obj.numMapParRangeSamples - mod(obj.numMapParRangeSamples,2); % number of samples
%                 rndIDX = randperm(nRows); 
%                 rndIDX = randperm(nSample);
%                 rndIDX = mod( randperm(nSample) , nRows ) + 1;
%                 rndIDX = randperm(nRows , nSample);
%                 rndIDX = randi(nRows,1,nSample);
                
                rndIDX = [];
                while length(rndIDX) < nSample
                    rndIDX = [rndIDX , randperm(nRows , min( [ nSample , nRows , nSample - length(rndIDX) ] ) ) ];
                end
                
                samp = obj.X(rndIDX, :);   

                % Compute squared distances  vector (D)
                numDistMeas = floor(obj.numMapParRangeSamples/2); % Number of distance measurements
                D = zeros(1 , numDistMeas);
                for i = 1:numDistMeas
                    D(i) = sum((samp(2*i-1,:) - samp(2*i,:)).^2);
                end
                D = sort(D);

%                 firstPercentile = round(0.01 * numel(D) + 0.5);
%                 minGuess = sqrt( D(firstPercentile));
%                 maxGuess = sqrt( max(D) );

                fifthPercentile = round(0.05 * numel(D) + 0.5);
                ninetyfifthPercentile = round(0.95 * numel(D) - 0.5);
                minGuess = sqrt( D(fifthPercentile));
                maxGuess = sqrt( D(ninetyfifthPercentile) );
                
                if minGuess <= 0
                    minGuess = eps;
                end
                if maxGuess <= 0
                    maxGuess = eps;
                end	

                tmpMapPar = linspace(minGuess, maxGuess , obj.numMapParGuesses);
            else
                tmpMapPar = obj.mapParGuesses;
            end

            % Generate all possible parameters combinations
            [p,q] = meshgrid(tmpNumRF, tmpMapPar);
            tmp = [p(:) q(:)]';
%             obj.rng = num2cell(tmp , 1);
            obj.rng = tmp;

        end
        
        function compute(obj , mapPar)
            
            if( nargin > 1 )
                
                if(obj.verbose == 1)
                    disp('Mapping will be computed according to the provided hyperparameter(s)');
                    mapPar
                end
                chosenPar = mapPar;
            elseif (nargin == 1) && (isempty(obj.currentPar))
                
                % If any current value for any of the parameters is not available, abort.
                error('Mapping parameter(s) not explicitly specified, and some internal current parameters are not available available. Exiting...');
            else
                if(obj.verbose == 1)
                    disp('Mapping will be computed according to the current internal hyperparameter(s)');
                    obj.currentPar
                end
                chosenPar = obj.currentPar;
            end
            
            obj.generateProj(chosenPar);
           
            % cos sin mapping
%             V =  obj.X * obj.omega;
%             obj.Xrf = sqrt( 2 / chosenPar(1) ) * [cos(V) , sin(V)];
            
            % cos(wx+b) mapping
            V =  obj.X * obj.omega + repmat(obj.b , size(obj.X,1) , 1);
            obj.Xrf = sqrt( 2 / chosenPar(1) ) * cos(V);
        end
        
        function obj = generateProj(obj , mapPar)
            
            % [ sin(wx) , cos(wx) ] mapping
            %             It is common that M is a diagonal matrix with diag (M ) =
            % 2 , . . . , 2 , such that it suffices to draw ω from a standard normal distribution N (0, 1) and sub-
            % n
            % 1
            % sequently scale these by l
%             obj.omega =  mapPar(2) * randn(obj.d, mapPar(1));

            % cos(wx + b) mapping
            %obj.omega =  2 * mapPar(2) .* randn(obj.d, mapPar(1));
            obj.omega =  randn(obj.d, mapPar(1)) / mapPar(2) ;
            obj.b =  rand(1,mapPar(1))* 2 * pi;

            %obj.omega = sqrt(2) * randn(obj.d, mapPar(1));
            %obj.omega = mapPar(2) * randn(obj.d, mapPar(1));
            %obj.omega = mapPar(2) * (2 * pi)^(-mapPar(1)/2) * randn(obj.d, mapPar(1));
        end
        
        % returns true if the next parameter combination is available and
        % updates the current parameter combination 'currentPar'
        function available = next(obj)

%             % If any range for any of the parameters is not available, recompute all ranges.
%             if cellfun(@isempty , obj.rng)
%                 obj.range();
%             end
% 
%             available = false;
%             if size(obj.rng,2) > obj.currentParIdx
%                 obj.currentParIdx = obj.currentParIdx + 1;
%                 obj.currentPar = obj.rng{obj.currentParIdx};
%                 available = true;
%             end        

            % If any range for any of the parameters is not available, recompute all ranges.
%             if cellfun(@isempty,obj.mapParGuesses)
%                 obj.range();
%             end
            if isempty(obj.rng)
                obj.range();
            end
            
            available = false;
%             if length(obj.mapParGuesses) > obj.currentParIdx
%                 obj.currentParIdx = obj.currentParIdx + 1;
%                 obj.currentPar = obj.mapParGuesses{obj.currentParIdx};
%                 available = true;
%             end
            if size(obj.rng,2) > obj.currentParIdx
                obj.prevPar = obj.currentPar;
                obj.currentParIdx = obj.currentParIdx + 1;
                obj.currentPar = obj.rng(:,obj.currentParIdx);
                available = true;
            end
        end        
    end
end
