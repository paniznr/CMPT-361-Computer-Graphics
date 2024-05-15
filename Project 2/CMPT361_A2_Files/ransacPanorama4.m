function  res = ransacPanorama4(n, isFastR, setId, conf, numTrials, dist)
    %I edited the code from the tutorial linked in the assignment, and used
    %some methods based on the same tutorial, provided on Stephen Buckmaster's Github
    %(https://gist.github.com/stephan-buckmaster/eaae82eaf36d05da270db3b34f150c0d)
    %The code is based on his video: https://www.youtube.com/watch?v=DPkmphP53j4&ab_channel=buckmasterinstitute
    %{
    Step 1 - Load Images
    The image set used in this example contains pictures of a building. 
    These were taken with an uncalibrated smart phone camera by sweeping the 
    camera from left to right along the horizon, capturing all parts of the building.
    
    As seen below, the images are relatively unaffected by any lens distortion
     so camera calibration was not required. However, if lens distortion 
    is present, the camera should be calibrated and the images undistorted 
    prior to creating the panorama. You can use the Camera Calibrator App 
    to calibrate a camera if needed.
    %}
    % Load images
    if setId == 1
        buildingDir = fullfile({'S1-im1.png','S1-im2.png','S1-im3.png','S1-im4.png'});
    elseif setId == 2
        buildingDir = fullfile({'S2-im1.png','S2-im2.png','S2-im3.png','S2-im4.png'});
    end
       
    buildingScene = imageDatastore(buildingDir);
    
    
    %{
    Step 2 - Register Image Pairs
    To create the panorama, start by registering successive image pairs using 
    the following procedure:
    
        Detect and match features between I(n) and I(n−1).
    
        Estimate the geometric transformation, T(n), that maps I(n) to I(n−1).
    
        Compute the transformation that maps I(n) into the panorama image 
        as T(1)∗T(2)∗...∗T(n−1)∗T(n).
    %}
    % Read the first image from the image set.
    I = readimage(buildingScene,1);
    
    % Initialize features for I(1)
    grayImage = im2gray(I);
    [fast, points] = my_fast_detector(grayImage);
    if isFastR
        [fastR, points, garbTime] = harrisMetric(grayImage, fast);
    end
    [features, points] = extractFeatures(grayImage,points);
    
    % Initialize all the transformations to the identity matrix. Note that the
    % projective transformation is used here because the building images are fairly
    % close to the camera. For scenes captured from a further distance, you can use
    % affine transformations.
    numImages = n;
    tforms(numImages) = projective2d(eye(3));
    
    % Initialize variable to hold image sizes.
    imageSize = zeros(numImages,2);
    
    % Iterate over remaining image pairs
    for n = 2:numImages
        % Store points and features for I(n-1).
        pointsPrevious = points;
        featuresPrevious = features;
            
        % Read I(n).
        I = readimage(buildingScene, n);
        
        % Convert image to grayscale.
        grayImage = im2gray(I);    
        
        % Save image size.
        imageSize(n,:) = size(grayImage);
        
        % Detect and extract SURF features for I(n).
        [fast, points] = my_fast_detector(grayImage);
        [features, points] = extractFeatures(grayImage, points);
      
        % Find correspondences between I(n) and I(n-1).
        indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
           
        matchedPoints = points(indexPairs(:,1), :);
        matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);        
        
        % Estimate the transformation between I(n) and I(n-1).
        tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
            'projective', 'Confidence', conf, 'MaxNumTrials', numTrials, 'MaxDistance', dist);
        
        % Compute T(1) * T(2) * ... * T(n-1) * T(n).
        tforms(n).T = tforms(n-1).T * tforms(n).T; 
    end
    %{ 
    At this point, all the transformations in tforms are relative to the 
    first image. This was a convenient way to code the image registration 
    procedure because it allowed sequential processing of all the images. 
    However, using the first image as the start of the panorama does not 
    produce the most aesthetically pleasing panorama because it tends to 
    distort most of the images that form the panorama. A nicer panorama 
    can be created by modifying the transformations such that the center of 
    the scene is the least distorted. This is accomplished by inverting the 
    transformation for the center image and applying that transformation 
    to all the others.
    
    Start by using the projtform2d outputLimits method to find the output 
    limits for each transformation. The output limits are then used to 
    automatically find the image that is roughly in the center of the scene.
    %}
    % Compute the output limits for each transformation.
    for i = 1:numel(tforms)           
        [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);    
    end
    
    %Next, compute the average X limits for each transformation and find 
    % the image that is in the center. Only the X limits are used here 
    % because the scene is known to be horizontal. If another set of images 
    % are used, both the X and Y limits may need to be used to find the center image.
    
    avgXLim = mean(xlim, 2);
    [~,idx] = sort(avgXLim);
    centerIdx = floor((numel(tforms)+1)/2);
    centerImageIdx = idx(centerIdx);
    %Finally, apply the center image's inverse transformation to all the others.
    
    Tinv = invert(tforms(centerImageIdx));
    for i = 1:numel(tforms)    
        tforms(i).T = Tinv.T * tforms(i).T;
    end
    %{
    Step 3 - Initialize the Panorama
    Now, create an initial, empty, panorama into which all the images are mapped.
    
    Use the outputLimits method to compute the minimum and maximum output 
    limits over all transformations. These values are used to automatically
     compute the size of the panorama.
    %}
    for i = 1:numel(tforms)           
        [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
    end
    
    maxImageSize = max(imageSize);
    
    % Find the minimum and maximum output limits. 
    xMin = min([1; xlim(:)]);
    xMax = max([maxImageSize(2); xlim(:)]);
    
    yMin = min([1; ylim(:)]);
    yMax = max([maxImageSize(1); ylim(:)]);
    
    % Width and height of panorama.
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
    
    % Initialize the "empty" panorama.
    panorama = zeros([height width 3], 'like', I);
    %{
    Step 4 - Create the Panorama
    Use imwarp to map images into the panorama and use vision.AlphaBlender 
    to overlay the images together.
    %}
    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
        'MaskSource', 'Input port');  
    
    % Create a 2-D spatial reference object defining the size of the panorama.
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);
    
    % Create the panorama.
    for i = 1:numImages
        
        I = readimage(buildingScene, i);   
       
        % Transform I into the panorama.
        warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
                      
        % Generate a binary mask.    
        mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);
        
        % Overlay the warpedImage onto the panorama.
        panorama = step(blender, panorama, warpedImage, mask);
    end
    
    res = panorama;
end