function stop = windowLinearFitting(err , winSize , thres)
%WINDOWLINEARFITTING Stop if error decreases less than a threshold 'thres' in a window
% of size winSize
%   Detailed explanation goes here
    
    stop = 0;
    
    if numel(err) >= winSize
        
        currErr = err(end-winSize + 1 : end);
        X = [ones(winSize,1), (1:winSize)'];
        b = X\currErr';
        if b(2) >= -(thres/winSize)
            stop = 1;
        end
    end
end

