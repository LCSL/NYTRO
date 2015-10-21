function stop = windowLinearFitting(err , winSize , thres)
%WINDOWLINEARFITTING Stop if error decreases less than a threshold 'thres' in a window
% of size winSize
%   Detailed explanation goes here
    
    stop = 0;
    
    if numel(err) >= winSize
        
        l = winSize - 1;
        
        currErr = err( ( end-winSize + 1 ) : end );
        x = (0:winSize-1)';
        X = [ones(winSize,1), x];
        b = X\currErr';
        
        figure(1)
        plot(x,currErr);
        hold on;
        plot(x,b(2)*x + b(1));
        legend('Error curve' , 'Linear fitting')
        hold off
        drawnow
        
%         if b(2) >= -(thres/winSize)
%             stop = 1;
%         end
%         if b(2) >= atan(thres)
%             stop = 1;
%         end
        if (l*b(2)/b(1)) >= thres
            stop = 1;
        end
    end
end

