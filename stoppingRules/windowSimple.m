function tStar = windowSimple(err , winSize , thres)
%WINDOW Stop if error decreases less than a threshold 'thres' in a window
% of size winSize
%   Detailed explanation goes here
    
    t = winSize;
    tStar = numel(err);
    
    while t < numel(err)
        
        e0 = err(t-winSize+1);
        e1 = err(t);
        
        if e1/e0 >= (1 - thres)
            tStar = t;
            break
        end
        
        t = t + 1;
    end
end

