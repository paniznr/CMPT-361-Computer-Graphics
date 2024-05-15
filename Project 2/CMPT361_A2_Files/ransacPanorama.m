function res = ransacPanorama(im1, im2, matchedPt1, matchedPt2, confidence, numIter, dist)
    %I used this code based on the MATLAB tutorial in the assignment, provided on Stephen Buckmaster's Github
    %(https://gist.github.com/stephan-buckmaster/eaae82eaf36d05da270db3b34f150c0d)
    %The code is based on his video: https://www.youtube.com/watch?v=DPkmphP53j4&ab_channel=buckmasterinstitute
    %%
    n=2;
    tforms(2) = projective2d(eye(3));
    ImageSize = zeros(n, 2);
    %%
    % T(n)*T(n-1)*...*T(1)
    %T(2)*T(1)
    tforms(n) = estimateGeometricTransform(matchedPt2, matchedPt1,...
                'projective', 'Confidence', confidence, 'MaxNumTrials', numIter, 'MaxDistance', dist);
            
            % Compute T(n) * T(n-1) * ... * T(1)
    tforms(n).T = tforms(n).T * tforms(n-1).T;
    %%
    im2_gray = rgb2gray(im2);
    ImageSize(2,:) = size(im2_gray);
    %%
    for i = 1:numel(tforms)
            [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 ImageSize(i,2)], [1 ImageSize(i,1)]);
    end
    avgXLim = mean(xlim, 2);
    
    [~, idx] = sort(avgXLim);
    
    centerIdx = floor((numel(tforms)+1)/2);
    
    centerImageIdx = idx(centerIdx);
    Tinv = invert(tforms(centerImageIdx));
    
    for i = 1:numel(tforms)
        tforms(i).T = tforms(i).T * Tinv.T;
    end
    for i = 1:numel(tforms)           
        [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 ImageSize(i,2)], [1 ImageSize(i,1)]);
    end
    
    maxImageSize = max(ImageSize);
    %%
    % Find the minimum and maximum output limits
    xMin = min([1; xlim(:)]);
    xMax = max([maxImageSize(2); xlim(:)]);
    
    yMin = min([1; ylim(:)]);
    yMax = max([maxImageSize(1); ylim(:)]);
    %%
    % Width and height of panorama.
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
    
    % Initialize the "empty" panorama.
    panorama = zeros([height width 3], 'like', im2);
    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  
    
    % Create a 2-D spatial reference object defining the size of the panorama.
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);
    %%
    % Create the panorama.
    I = im1;
    
    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(1), 'OutputView', panoramaView);
    
    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), tforms(1), 'OutputView', panoramaView);
    panorama = step(blender, panorama, warpedImage, mask);
    %%
    I = im2;
    
    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(2), 'OutputView', panoramaView);
    
    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), tforms(2), 'OutputView', panoramaView);
    panorama = step(blender, panorama, warpedImage, mask);
    res = panorama;
    %%
end