%Images
S1_im1 = imread('S1-im1.png');
S1_im1g = rgb2gray(S1_im1);
S1_im2 = imread('S1-im2.png');
S1_im2g = rgb2gray(S1_im2);
S1_im3 = imread('S1-im3.png');
S1_im3g = rgb2gray(S1_im3);
S1_im4 = imread('S1-im4.png');
S1_im4g = rgb2gray(S1_im4);

S2_im1 = imread('S2-im1.png');
S2_im1g = rgb2gray(S2_im1);
S2_im2 = imread('S2-im2.png');
S2_im2g = rgb2gray(S2_im2);
S2_im3 = imread('S2-im3.png');
S2_im3g = rgb2gray(S2_im3);
S2_im4 = imread('S2-im4.png');
S2_im4g = rgb2gray(S2_im4);

S3_im1 = imread('S3-im1.png');
S3_im1g = rgb2gray(S3_im1);
S3_im2 = imread('S3-im2.png');
S3_im2g = rgb2gray(S3_im2);

S4_im1 = imread('S4-im1.png');
S4_im1g = rgb2gray(S4_im1);
S4_im2 = imread('S4-im2.png');
S4_im2g = rgb2gray(S4_im2);

%2: FAST Feature Detection
fastTime = zeros(8,1);

tic;
[fast1_1, points1_1] = my_fast_detector(S1_im1g);
fastTime(1) = toc;

tic;
[fast1_2, points1_2] = my_fast_detector(S1_im2g);
fastTime(2) = toc;

tic;
[fast2_1, points2_1] = my_fast_detector(S2_im1g);
fastTime(3) = toc;

tic;
[fast2_2, points2_2] = my_fast_detector(S2_im2g);
fastTime(4) = toc;

tic;
[fast3_1, points3_1] = my_fast_detector(S3_im1g);
fastTime(5) = toc;

tic;
[fast3_2, points3_2] = my_fast_detector(S3_im2g);
fastTime(6) = toc;

tic;
[fast4_1, points4_1] = my_fast_detector(S4_im1g);
fastTime(7) = toc;

tic;
[fast4_2, points4_2] = my_fast_detector(S4_im2g);
fastTime(8) = toc;

avgFastTime = mean(fastTime(:));

imwrite(fast1_1, 'S1-fast.png');
imwrite(fast2_1, 'S2-fast.png');


%Harris Cornerness Metric: FASTR
fastRTime = zeros(8,1);
%The computational time for FASTR is calculated in the function itself
%because there was an extra for loop in there to create the SURFPoints
%container at the end, which I didn't want to include in the time.
[fastR1_1, pointsR1_1, fastRTime(1)] = harrisMetric(S1_im1g, fast1_1);

[fastR1_2, pointsR1_2, fastRTime(2)] = harrisMetric(S1_im2g, fast1_2);

[fastR2_1, pointsR2_1, fastRTime(3)] = harrisMetric(S2_im1g, fast2_1);

[fastR2_2, pointsR2_2, fastRTime(4)] = harrisMetric(S2_im2g, fast2_2);

[fastR3_1, pointsR3_1, fastRTime(5)] = harrisMetric(S3_im1g, fast3_1);

[fastR3_2, pointsR3_2, fastRTime(6)] = harrisMetric(S3_im2g, fast3_2);

[fastR4_1, pointsR4_1, fastRTime(7)] = harrisMetric(S4_im1g, fast4_1);

[fastR4_2, pointsR4_2, fastRTime(8)] = harrisMetric(S4_im2g, fast4_2);

avgFastRTime = mean(fastRTime(:));

imwrite(fastR1_1, 'S1-fastR.png');
imwrite(fastR2_1, 'S2-fastR.png');

%3: Point description and matching
%FAST
%Set 1
fastMatchingTime = zeros(4,1);
tic;
[surfFeatures1_1,surfCorners1_1] = extractFeatures(S1_im1g, points1_1, Method="SURF");
[surfFeatures1_2,surfCorners1_2] = extractFeatures(S1_im2g, points1_2, Method="SURF");
indexPairs1 = matchFeatures(surfFeatures1_1,surfFeatures1_2);
matchedPoints1_1 = surfCorners1_1(indexPairs1(:,1),:);
matchedPoints1_2 = surfCorners1_2(indexPairs1(:,2),:);
fig1 = showMatchedFeatures(S1_im1g,S1_im2g,matchedPoints1_1,matchedPoints1_2);
fastMatchingTime(1) = toc;
saveas(fig1, "S1-fastMatch.png");

%Set 2
tic;
[surfFeatures2_1,surfCorners2_1] = extractFeatures(S2_im1g, points2_1, Method="SURF");
[surfFeatures2_2,surfCorners2_2] = extractFeatures(S2_im2g, points2_2, Method="SURF");
indexPairs2 = matchFeatures(surfFeatures2_1,surfFeatures2_2);
matchedPoints2_1 = surfCorners2_1(indexPairs2(:,1),:);
matchedPoints2_2 = surfCorners2_2(indexPairs2(:,2),:);
fig2 = showMatchedFeatures(S2_im1g,S2_im2g,matchedPoints2_1,matchedPoints2_2);
fastMatchingTime(2) = toc;
saveas(fig2, "S2-fastMatch.png");

%Set 3
tic;
[surfFeatures3_1,surfCorners3_1] = extractFeatures(S3_im1g, points3_1, Method="SURF");
[surfFeatures3_2,surfCorners3_2] = extractFeatures(S3_im2g, points3_2, Method="SURF");
indexPairs3 = matchFeatures(surfFeatures3_1,surfFeatures3_2);
matchedPoints3_1 = surfCorners3_1(indexPairs3(:,1),:);
matchedPoints3_2 = surfCorners3_2(indexPairs3(:,2),:);
fig3 = showMatchedFeatures(S3_im1g,S3_im2g,matchedPoints3_1,matchedPoints3_2);
fastMatchingTime(3) = toc;

%Set 4
tic;
[surfFeatures4_1,surfCorners4_1] = extractFeatures(S4_im1g, points4_1, Method="SURF");
[surfFeatures4_2,surfCorners4_2] = extractFeatures(S4_im2g, points4_2, Method="SURF");
indexPairs4 = matchFeatures(surfFeatures4_1,surfFeatures4_2);
matchedPoints4_1 = surfCorners4_1(indexPairs4(:,1),:);
matchedPoints4_2 = surfCorners4_2(indexPairs4(:,2),:);
fig4 = showMatchedFeatures(S4_im1g,S4_im2g,matchedPoints4_1,matchedPoints4_2);
fastMatchingTime(4) = toc;

avgFastMatchingTime = mean(fastMatchingTime(:));

%FASTR
fastRMatchingTime = zeros(4,1);
%Set 1
tic;
[surfFeaturesR1_1,surfCornersR1_1] = extractFeatures(S1_im1g, pointsR1_1, Method="SURF");
[surfFeaturesR1_2,surfCornersR1_2] = extractFeatures(S1_im2g, pointsR1_2, Method="SURF");
indexPairsR1 = matchFeatures(surfFeaturesR1_1,surfFeaturesR1_2);
matchedPointsR1_1 = surfCornersR1_1(indexPairsR1(:,1),:);
matchedPointsR1_2 = surfCornersR1_2(indexPairsR1(:,2),:);
figR1 = showMatchedFeatures(S1_im1g,S1_im2g,matchedPointsR1_1,matchedPointsR1_2);
fastRMatchingTime(1) = toc;
saveas(figR1, "S1-fastRMatch.png");

%Set 2
tic;
[surfFeaturesR2_1,surfCornersR2_1] = extractFeatures(S2_im1g, pointsR2_1, Method="SURF");
[surfFeaturesR2_2,surfCornersR2_2] = extractFeatures(S2_im2g, pointsR2_2, Method="SURF");
indexPairsR2 = matchFeatures(surfFeaturesR2_1,surfFeaturesR2_2);
matchedPointsR2_1 = surfCornersR2_1(indexPairsR2(:,1),:);
matchedPointsR2_2 = surfCornersR2_2(indexPairsR2(:,2),:);
figR2 = showMatchedFeatures(S2_im1g,S2_im2g,matchedPointsR2_1,matchedPointsR2_2);
fastRMatchingTime(2) = toc;
saveas(figR2, "S2-fastRMatch.png");

%Set 3
tic;
[surfFeaturesR3_1,surfCornersR3_1] = extractFeatures(S3_im1g, pointsR3_1, Method="SURF");
[surfFeaturesR3_2,surfCornersR3_2] = extractFeatures(S3_im2g, pointsR3_2, Method="SURF");
indexPairsR3 = matchFeatures(surfFeaturesR3_1,surfFeaturesR3_2);
matchedPointsR3_1 = surfCornersR3_1(indexPairsR3(:,1),:);
matchedPointsR3_2 = surfCornersR3_2(indexPairsR3(:,2),:);
figR3 = showMatchedFeatures(S3_im1g,S3_im2g,matchedPointsR3_1,matchedPointsR3_2);
fastRMatchingTime(3) = toc;

%Set 4
tic;
[surfFeaturesR4_1,surfCornersR4_1] = extractFeatures(S4_im1g, pointsR4_1, Method="SURF");
[surfFeaturesR4_2,surfCornersR4_2] = extractFeatures(S4_im2g, pointsR4_2, Method="SURF");
indexPairsR4 = matchFeatures(surfFeaturesR4_1,surfFeaturesR4_2);
matchedPointsR4_1 = surfCornersR4_1(indexPairsR4(:,1),:);
matchedPointsR4_2 = surfCornersR4_2(indexPairsR4(:,2),:);
figR4 = showMatchedFeatures(S4_im1g,S4_im2g,matchedPointsR4_1,matchedPointsR4_2);
fastRMatchingTime(4) = toc;

avgFastRMatchingTime = mean(fastRMatchingTime(:));

%4: RANSAC and Panoramas
%FAST
fastConfidence = 99;
fastNumTrials = 3000;
fastDist = 5;
panorama1 = ransacPanorama(S1_im1, S1_im2, matchedPoints1_1, matchedPoints1_2, fastConfidence, fastNumTrials, fastDist);
panorama2 = ransacPanorama(S2_im1, S2_im2, matchedPoints2_1, matchedPoints2_2, fastConfidence, fastNumTrials, fastDist);
panorama3 = ransacPanorama(S3_im1, S3_im2, matchedPoints3_1, matchedPoints3_2, fastConfidence, fastNumTrials, fastDist);
panorama4 = ransacPanorama(S4_im1, S4_im2, matchedPoints4_1, matchedPoints4_2, fastConfidence, fastNumTrials, fastDist);

%FASTR
fastRConfidence = 99;
fastRNumTrials = 2000;
fastRDist = 5;
panoramaR1 = ransacPanorama(S1_im1, S1_im2, matchedPointsR1_1, matchedPointsR1_2, fastRConfidence, fastRNumTrials, fastRDist);
panoramaR2 = ransacPanorama(S2_im1, S2_im2, matchedPointsR2_1, matchedPointsR2_2, fastRConfidence, fastRNumTrials, fastRDist);
panoramaR3 = ransacPanorama(S3_im1, S3_im2, matchedPointsR3_1, matchedPointsR3_2, fastRConfidence, fastRNumTrials, fastRDist);
panoramaR4 = ransacPanorama(S4_im1, S4_im2, matchedPointsR4_1, matchedPointsR4_2, fastRConfidence, fastRNumTrials, fastRDist);
imwrite(panoramaR1, "S1-panorama.png");
imwrite(panoramaR2, "S2-panorama.png");
imwrite(panoramaR3, "S3-panorama.png");
imwrite(panoramaR4, "S4-panorama.png");

%5 Bonus
% panoramaBigR1 = ransacPanorama4(4, true, 1, fastRConfidence, fastRNumTrials, fastRDist);
% panoramaBigR2 = ransacPanorama4(4, true, 2, fastRConfidence, fastRNumTrials, fastRDist);
% 
% imwrite(panoramaBigR1, "S1-panoramaBig.png");
% imwrite(panoramaBigR2, "S2-panoramaBig.png");