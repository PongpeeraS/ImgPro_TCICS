datasetPath = fullfile(pwd,'.\coins');
imds = imageDatastore(datasetPath, ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.jpg', ...
    'LabelSource','foldernames', ...
    'ReadFcn',@customReader);

%% DEBUG/TEST SEGMENT, NOT RELATED TO ACTUAL PROGRAM
% perm = randperm(240,20);
% for i = 1:20
%     subplot(4,5,i);
%     img = readimage(imds,perm(i));
%     gray = rgb2gray(img);
%     %% DENOISE & SEGMENTATION/MORPHOLOGY
%     pic_salt = imnoise(gray, 'salt & pepper');
%     denoise = medfilt2(pic_salt);           % denoise pic using medfilt2 function
%     [~,threshold] = edge(denoise,'sobel');  % using edge and sobel to find threshold  of the pic
%     fudgeFactor = 0.4;                      % Fudge Factor is used to adjust thresehold
%     BinMask_pic = edge(denoise,'sobel',threshold * fudgeFactor); % Binary gradient mask image by tuning threshold with edge operation
%     SE_ver = strel('line',2,90);            % create linear structuring element with length 2 and 90 degree
%     SE_ho = strel('line',2,0);              % create linear structuring element with length 2 and 0 degree
%     Dilate_pic = imdilate(BinMask_pic,[SE_ver SE_ho]); % using imdilate function to dilate pic with the structuring line
%     Fill_pic = imfill(Dilate_pic,'holes');  % fill the holes between edge with imfill function
%     BWnobord = imclearborder(Fill_pic,4);   % remove non-related obj
%     SE_dia = strel('diamond',5);            % create diamond structuring element with distant 5 from original point
%     segment_pic = imerode(BWnobord,SE_dia); % Smoothen pic with diamond structuring element and imerode function
%     BWoutline = bwperim(segment_pic);
%
%     % Cropping after segmentation
%     measurements = regionprops(BWoutline, 'BoundingBox', 'FilledImage'); % Get bounding box around the coin
%     box = measurements.BoundingBox;
%     box(1) = box(1)-5; box(2) = box(2)-5;
%     maxW = max([box(3),box(4)])+10;
%     box(3) = maxW; box(4) = maxW;
%     crop = imcrop(img,box); % crop image according to box
%     width = 128; radius = width/2;
%     crop = imresize(crop, [width width]);
%
%     [xx,yy] = ndgrid((1:width)-radius,(1:width)-radius);
%     mask = uint8((xx.^2 + yy.^2)<(radius^2));
%     croppedImage = uint8(zeros(size(crop)));
%     croppedImage(:,:,1) = crop(:,:,1).*mask;
%     croppedImage(:,:,2) = crop(:,:,2).*mask;
%     croppedImage(:,:,3) = crop(:,:,3).*mask;
%     croppedImage(:,:,1) = histeq(croppedImage(:,:,1));
%     croppedImage(:,:,2) = histeq(croppedImage(:,:,2));
%     croppedImage(:,:,3) = histeq(croppedImage(:,:,3));
%     imshow(croppedImage); title(imds.Labels(perm(i)));
% end

labelCount = countEachLabel(imds);
numTrain = labelCount.Count(1)*0.75; % #training imgs/label (#img*training%)
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrain,'randomize'); %split dataset into training & validation sets
% set CNN layers
layers = [
    imageInputLayer([128 128 3])
    
    convolution2dLayer(4,128,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(4,128,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(4,128,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(12)
    softmaxLayer
    classificationLayer
    ];
% set training options
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',60, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'MiniBatchSize',50);
net = trainNetwork(imdsTrain,layers,options); % create CNN model
% accuracy calculation
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;
accuracy = sum(YPred == YValidation)/numel(YValidation);

% for creating confusion matrix
cm = confusionchart(YValidation,YPred);

save cnnet

function data = customReader(filename)
% code from default read function:
onState = warning('off', 'backtrace');
c = onCleanup(@() warning(onState));
data = imread(filename);
img = imresize(data, [256 256]);
gray = rgb2gray(img);
%% DENOISE & SEGMENTATION/MORPHOLOGY
pic_salt = imnoise(gray, 'salt & pepper');
denoise = medfilt2(pic_salt);           % denoise pic using medfilt2 function
[~,threshold] = edge(denoise,'sobel');  % using edge and sobel to find threshold  of the pic
fudgeFactor = 0.4;                      % Fudge Factor is used to adjust thresehold
BinMask_pic = edge(denoise,'sobel',threshold * fudgeFactor); % Binary gradient mask image by tuning threshold with edge operation
SE_ver = strel('line',2,90);            % create linear structuring element with length 2 and 90 degree
SE_ho = strel('line',2,0);              % create linear structuring element with length 2 and 0 degree
Dilate_pic = imdilate(BinMask_pic,[SE_ver SE_ho]); % using imdilate function to dilate pic with the structuring line
Fill_pic = imfill(Dilate_pic,'holes');  % fill the holes between edge with imfill function
BWnobord = imclearborder(Fill_pic,4);   % remove non-related obj
SE_dia = strel('diamond',5);            % create diamond structuring element with distant 5 from original point
segment_pic = imerode(BWnobord,SE_dia); % Smoothen pic with diamond structuring element and imerode function
BWoutline = bwperim(segment_pic);

% Cropping after segmentation
measurements = regionprops(BWoutline, 'BoundingBox', 'FilledImage'); 
box = measurements.BoundingBox; % Get bounding box around the coin
box(1) = box(1)-5; box(2) = box(2)-5; % Move starting point 5px up % left
maxW = max([box(3),box(4)])+10; % Get max length between x & y, then increase by 10px
box(3) = maxW; box(4) = maxW; % set box width according to the longer axis
crop = imcrop(img,box); % crop image according to box

% Removing background to contain only the circle (coin)
width = 128; radius = width/2;
crop = imresize(crop, [width width]); % resize cropped image to same dimensions
[xx,yy] = ndgrid((1:width)-radius,(1:width)-radius);
mask = uint8((xx.^2 + yy.^2)<(radius^2)); % create circle mask
croppedImage = uint8(zeros(size(crop))); % create dummy image
% crop image from the mask
croppedImage(:,:,1) = crop(:,:,1).*mask;
croppedImage(:,:,2) = crop(:,:,2).*mask;
croppedImage(:,:,3) = crop(:,:,3).*mask;
% perform histogram equalization on RGB matrices
croppedImage(:,:,1) = histeq(croppedImage(:,:,1));
croppedImage(:,:,2) = histeq(croppedImage(:,:,2));
croppedImage(:,:,3) = histeq(croppedImage(:,:,3));
data = croppedImage;
end