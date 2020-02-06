function varargout = tcics(varargin)
% TCICS MATLAB code for tcics.fig
%      TCICS, by itself, creates a new TCICS or raises the existing
%      singleton*.
%
%      H = TCICS returns the handle to a new TCICS or the handle to
%      the existing singleton*.
%
%      TCICS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TCICS.M with the given input arguments.
%
%      TCICS('Property','Value',...) creates a new TCICS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tcics_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tcics_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tcics

% Last Modified by GUIDE v2.5 04-Oct-2019 20:31:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @tcics_OpeningFcn, ...
    'gui_OutputFcn',  @tcics_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tcics is made visible.
function tcics_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tcics (see VARARGIN)

% Choose default command line output for tcics
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tcics wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tcics_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_getImage.
function btn_getImage_Callback(hObject, eventdata, handles)
% hObject    handle to btn_getImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pic;
global filename;
% select image via file dialog
[filename pathname] = uigetfile({'*.jpg'; '*.bmp'; '*.png'},'file select');
% read & set images on axis 1, clear axis 2
pic = imread(strcat(pathname, filename));
axes(handles.axes1); imshow(pic);
axes(handles.axes2); cla;
% set edit text box 1 to show file name
set(handles.edit1,'String',filename);


% --- Executes on button press in btn_clear.
% Clears the images, text boxes,and removes input image references
% from memory, including the image matrix and file name.
function btn_clear_Callback(hObject, eventdata, handles)
% hObject    handle to btn_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pic;
global filename;

axes(handles.axes1); cla;
axes(handles.axes2); cla;
set(handles.edit1,'String','');
set(handles.edit2,'String','');
pic = zeros(1,1);
filename = '';


% --- Executes on button press in btn_recognize.
function btn_recognize_Callback(hObject, eventdata, handles)
% hObject    handle to btn_recognize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pic;
% Start the timer, load the neural network and min/max values for standardization calculation
tic();
load cnnet
% resize to 256*256
img = imresize(pic, [256 256]); 
gray = rgb2gray(img);
% Denoise & Segmentation/Morphology
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

class = classify(net,croppedImage); % put preprocessed input into CNN
label = char(class(1));
datasetPath = fullfile(pwd,'.\coins');
imds = imageDatastore(datasetPath, ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.jpg', ...
    'LabelSource','foldernames');
index = find(contains(imds.Files,label)); % find example output image
examImg = char(imds.Files(index(1)));
result = imread(examImg);
axes(handles.axes2); imshow(result); % display output image
cleanLabel = replace(label,"_"," "); % display output class
set(handles.edit2,'string',cleanLabel);
toc();



