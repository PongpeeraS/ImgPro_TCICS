ITCS476 Digital Image Processing
Thai Coins Image Classification System

Pongpeera Sukasem	5988040	Section 1
Boonrak Kaewnopparat	5988124	Section 1

Running the main file: tcics.m/tcics.fig
	1. Open tcics.m/tcics.fig in MATLAB & run the application.
	2. Press the 'Get Input Image' button. A file dialog will appear.
	3. Select the input image from the file dialog. The input image is then shown on the left axis.
	4. Press the 'Recognize Image' button. The input image will be put into the neural network.
	5. The result from the neural network and the type of coin is displayed on the right axis and right edit text box respectively.
	6. Press the 'Clear Entry' button to clear all axes and edit text boxes, or press the 'Get Input Image' button to get a new input image.

Other files on the disk:
	- cnn_creator.m
		- MATLAB script to create and train the convolutional neural network.
		- No need to run this script, as the neural network has already been prepared (cnnet file).
	- coin folder
		- Contains a portion of images for training & testing the convolutional neural network. 
		- Image results from the program are taken from this folder.
		- 12 folders for 12 classes
	- cnnet file
		- Contains the trained convolutional neural network.
		- Used in tcics.m/tcics.fig during the recognition process.

***Note that the image dataset included with this package only represents a portion of the actual dataset (240 images). The full dataset can be viewed and downloaded from this link: 
https://drive.google.com/drive/folders/1wxh7Crmc51YNn5AVucT-LUOlBvusochv?usp=sharing