function [res, points] = my_fast_detector(image)
    [numRows, numCols] = size(image);
    res = zeros(numRows,numCols);

    %making the Bresenham circle of radius 3
    colCoord = zeros(16,1);
    rowCoord = zeros(16,1);
    colCoord(1) = 0;
    colCoord(9) = 0;
    colCoord(2) = 1;
    colCoord(8) = 1;
    colCoord(3) = 2;
    colCoord(7) = 2;
    colCoord(4) = 3;
    colCoord(5) = 3;
    colCoord(6) = 3;
    colCoord(10) = -1;
    colCoord(16) = -1;
    colCoord(15) = -2;
    colCoord(11) = -2;
    colCoord(12) = -3;
    colCoord(13) = -3;
    colCoord(14) = -3;
    
    rowCoord(5) = 0;
    rowCoord(13) = 0;
    rowCoord(4) = 1;
    rowCoord(14) = 1;
    rowCoord(3) = 2;
    rowCoord(15) = 2;
    rowCoord(1) = 3;
    rowCoord(2) = 3;
    rowCoord(16) = 3;
    rowCoord(6) = -1;
    rowCoord(12) = -1;
    rowCoord(7) = -2;
    rowCoord(11) = -2;
    rowCoord(8) = -3;
    rowCoord(9) = -3;
    rowCoord(10) = -3;

    t = 0.01; %threshold
    N = 12;
    firstFound = false;
    hsTestRes = ones(size(image));

    %looping through all pixels
    for i = 4:numRows-4
        for j = 4:numCols-4
            countGT = 0; %count of contiguous pixels greater than Ip
            maxGT = 0; %max count of contiguous pixels greater than Ip
            countLT = 0; %count of contiguous pixels less than Ip
            maxLT = 0; %max count of contiguous pixels less than Ip
            Ip = image(i,j);
            %Only proceeding if a pixel passed the High Speed test
            if hsTest(image, i, j, Ip, t, rowCoord, colCoord) == 0
                hsTestRes(i,j) = 0;
                continue;
            end
            for m = 1:32 %dealing with circular array logic by going through the circle twice
                if m == 16 || m == 32
                    m_ = 16;
                else
                    m_ = mod(m,16);
                end
                
                if image(i - rowCoord(m_,1), j + colCoord(m_,1)) > Ip + t
                    countGT = countGT+1;
                else
                    if maxGT < countGT
                        maxGT = countGT;
                    end
                    countGT = 0;
                end

                if image(i - rowCoord(m_,1), j + colCoord(m_,1)) < Ip - t
                    countLT = countLT+1;
                else
                    if maxLT < countLT
                        maxLT = countLT;
                    end
                    countLT = 0;
                end

                
            end
            if (maxGT >= N) || (maxLT >= N)
                res(i,j) = 1;
                new = [i j];
                %defining the location area only if something was found
                if ~firstFound
                    location = new;
                    firstFound = true;
                else
                    location = [location; new];
                end
            end
        end
    end
    %Putting the points into a SURFPoints container to use later
    if firstFound
        points = SURFPoints(location);
    else
        return;
    end
end