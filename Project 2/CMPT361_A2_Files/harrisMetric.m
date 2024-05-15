%Harris corner detection
%I used code similar to what Professor Yagiz used in the Harris Cornerness
%lecture
function [res, points, time] = harrisMetric(image, FAST)
    tic;
    [numRows, numCols] = size(image);
    %compute image derivative
    
    sobel = [-1 0 1; -2 0 2; -1 0 1];
    gaus = fspecial('gaussian', 5, 1);
    dog = conv2(gaus, sobel);
    ix = imfilter(image, dog); 
    iy = imfilter(image, dog'); 
    ix2g = imfilter(ix .* ix, gaus); 
    iy2g = imfilter(iy .* iy, gaus);
    ixiyg = imfilter(ix .* iy, gaus);
    k = 0.05;
    harcor = zeros(numRows, numCols);
    for i = 1:numRows
        for j = 1:numCols
            if FAST(i, j) == 1
                harcor(i,j) = ix2g(i, j) .* iy2g(i, j) - ixiyg(i, j) .* ixiyg(i, j) - k * (ix2g(i, j) + iy2g(i, j)).^2;
            end
        end
    end
    
    %non-maxima separation
    firstFound = false;
    localmax = imdilate(harcor, ones(3));
    res = ((harcor == localmax) .* (harcor > 0.0000001));
    time = toc;
    for i = 1:numRows
        for j = 1:numCols
            if res(i, j) == 1
                %defining the location area only if something was found
                if ~firstFound
                    location = [i j];
                    firstFound = true;
                else
                    location = [location; i j];
                end
            end
        end
    end
    
         
    if firstFound
        points = SURFPoints(location);
    else
        return;
    end
end