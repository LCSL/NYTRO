function tStar = windowLinearFitting(err , winSize , thres)
%WINDOW Stop if error decreases less than a threshold 'thres' in a window
% of size winSize
%   Detailed explanation goes here
    
    t = winSize;
    tStar = numel(err);
    
    while t < numel(err)
        
        currErr = err(t-winSize+1 : t);
        X = [ones(winSize,1), (1:winSize)'];
        b = X\currErr';
        if b(2) >= -(thres/winSize)
            tStar = t;
            break
        end
        
        t = t + 1;
    end
end

