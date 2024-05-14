%1: Preparing HP and LP.

LP = rgb2gray(im2double(imread('lp.jpg')));
HP = rgb2gray(im2double(imread('hf chair seat.jpg')));
LP = imresize(LP, 0.6);
HP = imresize(HP, 0.2);
LP = imcrop(LP, [0 0 500 500]);
HP = imcrop(HP, [0 0 500 500]);
imwrite(LP, 'LP.png');
imwrite(HP, 'HP.png');

%2: Frequency representations

LP_fou = fft2(LP);
HP_fou = fft2(HP);
mult = 200; %multiplier for visualizing well
LP_freq = fftshift(LP_fou)/mult; 
HP_freq = fftshift(HP_fou)/mult;
imwrite(abs(LP_freq), 'LP-freq.png'); 
imwrite(abs(HP_freq), 'HP-freq.png');

%3: Visualizing kernels

sobelKern = [-1 0 1; -2 0 2; -1 0 1];
%Chose a kernel size of 17 through testing
gausKern = fspecial('gaussian', 17, 2.5);
dogKern = imfilter(gausKern, sobelKern);
saveas(surf(gausKern), 'gaus-surf.png');
saveas(surf(dogKern), 'dog-surf.png');


%Applying the filter
LP_filt = imfilter(LP, gausKern);
HP_filt = imfilter(HP, gausKern);
imwrite(LP_filt, 'LP-filt.png');
imwrite(HP_filt, 'HP-filt.png');
%Seeing in frequency domain
LP_filt_freq = fftshift(fft2(LP_filt));
HP_filt_freq = fftshift(fft2(HP_filt));
mult2 = 100;%multiplier for visualizing well
imwrite(abs(LP_filt_freq)/mult2, 'LP-filt-freq.png');
imwrite(abs(HP_filt_freq)/mult2, 'HP-filt-freq.png');

%Fourier transform of DoG kernel
dogKern_fou = fftshift(abs(fft2(dogKern, 500, 500)));
%Applying kernel
LP_dogfilt_freq = dogKern_fou.*LP_fou;
HP_dogfilt_freq = dogKern_fou.*HP_fou;
%Converting to spatial domain
LP_dogfilt = ifft2(LP_dogfilt_freq); 
HP_dogfilt = ifft2(HP_dogfilt_freq);

%Saving images
imwrite(LP_dogfilt*mult,'LP-dogfilt.png');
imwrite(HP_dogfilt*mult,'HP-dogfilt.png');
imwrite(abs(LP_dogfilt_freq)*mult,'LP-dogfilt-freq.png');
imwrite(abs(HP_dogfilt_freq)*mult,'HP-dogfilt-freq.png');

%4: Anti-aliasing

%Subsample (by 2)
LP_samp2 = LP(1:2:end, 1:2:end);
HP_samp2 = HP(1:2:end, 1:2:end);
imwrite(LP_samp2,'LP-sub2.png');
imwrite(HP_samp2,'HP-sub2.png');
%Frequency domain
LP_samp_fou2 = fft2(LP_samp2);
HP_samp_fou2 = fft2(HP_samp2);
LP_samp_freq2 = fftshift(abs(LP_samp_fou2));
HP_samp_freq2 = fftshift(abs(HP_samp_fou2));
%Using multiplier for visualization
imwrite(LP_samp_freq2/mult,'LP-sub2-freq.png');
imwrite(HP_samp_freq2/mult,'HP-sub2-freq.png');

%Subsample (by 4)
LP_samp4 = LP(1:4:end, 1:4:end);
HP_samp4 = HP(1:4:end, 1:4:end);
imwrite(LP_samp4,'LP-sub4.png');
imwrite(HP_samp4,'HP-sub4.png');
%Frequency domain
LP_samp_fou4 = fft2(LP_samp4);
HP_samp_fou4 = fft2(HP_samp4);
LP_samp_freq4 = fftshift(abs(LP_samp_fou4));
HP_samp_freq4 = fftshift(abs(HP_samp_fou4));
mult3 = 150; %for visualization
imwrite(LP_samp_freq4/mult3,'LP-sub4-freq.png');
imwrite(HP_samp_freq4/mult3,'HP-sub4-freq.png');

%Chose a Gaussian kernel of size 5 and SD of 2 through testing to see what
%minimal settings can anti-alias
gausKern_samp2 = fspecial('gaussian', 5, 2);
%Apply to HP before sampling
HP_filt_gaus2 = imfilter(HP, gausKern_samp2);
%Sample by 2
HP_sub2_aa = HP_filt_gaus2(1:2:end, 1:2:end);
HP_sub2_aa_freq = abs(fftshift(fft2(HP_sub2_aa)))/mult;
%Gaussian kernel of size 3 and SD 2
gausKern_samp4 = fspecial('gaussian', 3, 2);
%Apply to HP before sampling
HP_filt_gaus4 = imfilter(HP, gausKern_samp4);
%Sample by 4
HP_sub4_aa = HP_filt_gaus4(1:4:end, 1:4:end);
HP_sub4_aa_freq = abs(fftshift(fft2(HP_sub4_aa)))/mult;

imwrite(HP_sub2_aa, 'HP-sub2-aa.png');
imwrite(HP_sub2_aa_freq, 'HP-sub2-aa-freq.png');
imwrite(HP_sub4_aa, 'HP-sub4-aa.png');
imwrite(HP_sub4_aa_freq, 'HP-sub4-aa-freq.png');

%5: Canny edge detection

%I first used the threshold given by the edge() function by default, then
%started playing around and comparing threshold values to find ones that
%were optimal.

%LP
LP_cannyedge_opt = edge(LP, 'canny', [0.07 0.1]); 
imwrite(LP_cannyedge_opt,'LP-canny-optimal.png');
%lower low
LP_cannyedge_LL = edge(LP, 'canny', [0.005 0.1]); 
imwrite(LP_cannyedge_LL,'LP-canny-lowlow.png');
%higher low
LP_cannyedge_HL = edge(LP, 'canny', [0.095 0.1]); 
imwrite(LP_cannyedge_HL,'LP-canny-highlow.png');
%lower high
LP_cannyedge_LH = edge(LP, 'canny', [0.07 0.8]); 
imwrite(LP_cannyedge_LH,'LP-canny-lowhigh.png');
%higher high
LP_cannyedge_HH = edge(LP, 'canny', [0.07 0.3]); 
imwrite(LP_cannyedge_HH,'LP-canny-highhigh.png');

%HP
HP_cannyedge_opt = edge(HP, 'canny', [0.2 0.3]); 
imwrite(HP_cannyedge_opt,'HP-canny-optimal.png');
%lower low
HP_cannyedge_LL = edge(HP, 'canny', [0.05 0.3]); 
imwrite(HP_cannyedge_LL,'HP-canny-lowlow.png');
%higher low
HP_cannyedge_HL = edge(HP, 'canny', [0.29 0.3]); 
imwrite(HP_cannyedge_HL,'HP-canny-highlow.png');
%lower high
HP_cannyedge_LH = edge(HP, 'canny', [0.2 0.205]); 
imwrite(HP_cannyedge_LH,'HP-canny-lowhigh.png');
%higher high
HP_cannyedge_HH = edge(HP, 'canny', [0.2 0.7]); 
imwrite(HP_cannyedge_HH,'HP-canny-highhigh.png');

