function tStar = windowAveraged(err , winSize , thres)
%WINDOW Stop if error decreases less than a threshold 'thres' in a window
% of size winSize, averaging the initial and final error values over a
% fraction of the window size
%   Detailed explanation goes here
    
    t = winSize;
    tStar = numel(err);
    numAvg = ceil(0.1 * winSize);% Number of points to take for error averaging
    
    while t < numel(err)
        
        e0 = mean(err(t - winSize + 1 : t - winSize + numAvg));
        e1 = mean(err(t - numAvg + 1 : t));
        
        if e1/e0 >= (1 - thres)
            tStar = t;
            break
        end
        
        t = t + 1;
    end
end

