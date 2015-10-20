%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This script applies the chosen stopping rule to saved experimental results %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setenv('LC_ALL','C');
clearAllButBP;
close all

saveResultsVarsFlag = 1;

% Get existing subfolders names
pathFolder = '/home/kammo/Dropbox/Large Scale Learning Project/Nystrom/AISTATS2016/workspace/experimental_report_Raf/final_table/';

% Load experimental results
% experimentName = 'Adult';
% experimentName = 'CovertypeBinary';
% experimentName = 'ijcnn1Binary';
% experimentName = 'InsuranceCompanyBenchmark';
experimentName = 'YearPredictionMSD';

if exist([pathFolder , experimentName , '/results.mat'], 'file')
    load([pathFolder , experimentName , '/results.mat']);
end

if exist([pathFolder , experimentName , '/DS_metadata.mat'], 'file')
    load([pathFolder , experimentName , '/DS_metadata.mat']);
end

%% Config

% Select stopping rule
% stoppingRule = @windowSimple;
% stoppingRule = @windowAveraged;
stoppingRule = @windowLinearFitting;

winSize = 10;
thres = 0.000113;


%% Stopping rule (NYTRO)

valErr = nyslanvalErr_buf;

% Get t according to 
tStarES = stoppingRule(valErr , winSize , thres);

valErrES = nyslanvalErr_buf(tStarES);
if exist('nyslantestErr_buf','var') == 1
    testErrES = nyslantestErr_buf(tStarES);
end

%% Set folderName

resdir = [ pathFolder, experimentName ];

%% Save relevant variables to .MAT

if saveResultsVarsFlag == 1
    save([resdir , '/stoppingRuleResults.mat'], ...
    'winSize', ...
    'thres', ...
    'testErrES',...
    'valErrES',...
    'stoppingRule',...
    'tStarES')
end


%% Play sound

load gong.mat;
sound(y);