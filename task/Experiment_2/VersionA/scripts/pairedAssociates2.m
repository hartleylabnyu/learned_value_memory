%% PAIRED ASSOCIATES TASK %%
% In this task, participants see a card and a stamp presented on the
% screen simultaneously. Participants see instructions that tell them that
% they should try to remember which card goes with which stamp.

%Participants must press one button if the stamp is
% on the right side of the card and a different button if the stamp is on
% the left side of the card.

%% Get subject information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input subject information
%subjectNumber = input('Enter subject number ');

%% Create data file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PA_filename = [int2str(subjectNumber), '_PA2.txt'];
fileID = fopen(PA_filename, 'w');

%specify file format. For this task, the data will be saved in a table with
%8 columns:
% Column 1: frame stimulus
% Column 2: pic stimulus
% Column 3: side of the screen the stamp was on - 1 for right, 2 for left
% Column 4: response
% Column 5: RT
% Column 6: trial start
% Column 7: trial end
% Column 8: trial number

formatSpec = '%s\t%s\t%f\t%d\t%d\t%d\t%d\t%f\n'; 

%% Create array with random animal / food pairings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create lists of food stimuli and animal stimuli
frameStim=dir('frames/*.jpg');
frameArray = {frameStim.name}; 
picStim = picArray; %from the frequency task

%Randomize order of food and animal arrays
frameOrder = randperm(numPics); %generate random food order
picOrder = randperm(numPics); %generate random animal order
leftRight = [1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 ]; %create vector of 1s and 2s
leftRight = leftRight(randperm(length(leftRight))); %randomize the order

%create empty PA_stim array
PA_stimArray = cell.empty(numPics, 0);

for i = 1:numPics
    frame = frameArray{frameOrder(i)};
    pic = picArray{picOrder(i)};
    PA_stimArray{i,1} = frame;
    PA_stimArray{i,2} = pic;
    PA_stimArray{i,3} = leftRight(i);
end

%% SCREEN INFORMATION
% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);


%% Set the number of trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numTrials = numPics; %numPics is the number of pictures that were presented in the frequency task


%% Present instruction screens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath 'instructionsA'

for i = 50:60
instructionPicName = ['Slide', int2str(i), '.jpeg'];
I1 = imread(instructionPicName);
Screen('PutImage', window, I1); % put image on screen

% Flip to the screen
HideCursor();
Screen('Flip', window);
KbStrokeWait;
end



%% Run trial for each row of the array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Present paired images for 3 seconds. Within this time, allow keyboard
% input and log responses (button pressed + RT) Add this info to the array.

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
for i = 1:numTrials

% Load the two images
addpath 'frames';
frameImage = PA_stimArray{i, 1};
frameImage = imread(frameImage);

addpath 'allPics';
picImage = PA_stimArray{i, 2};
picImage = imread(picImage);

%resize images
frameImage = imresize(frameImage, [400 300]); 
picImage = imresize(picImage, [400 300]); 

% Get the size of the image
[s1, s2, s3] = size(frameImage);

% Make the image into a texture
frameTexture = Screen('MakeTexture', window, frameImage);
picTexture = Screen('MakeTexture', window, picImage);

%Define image locations
loc1 = [(screenXpixels/4 - (s1)/2 + 50) (screenYpixels/2 - (s2)/2) ((screenXpixels/4 - (s1)/2)+450) ((screenYpixels/2 - (s2)/2)+300)];
loc2 = [(screenXpixels/2 + (s1)/2 - 50) (screenYpixels/2 - (s2)/2) ((screenXpixels/2 + (s1)/2)+350) ((screenYpixels/2 - (s2)/2)+300)];
rect1 = [(screenXpixels/4 - (s1)/2) (screenYpixels/2 - (s2)/2 - 50) ((screenXpixels/4 - (s1)/2)+500) ((screenYpixels/2 - (s2)/2)+350)];
rect2 = [(screenXpixels/2 + (s1)/2 - 100) (screenYpixels/2 - (s2)/2 - 50) ((screenXpixels/2 + (s1)/2)+400) ((screenYpixels/2 - (s2)/2)+350)];

%assign image locations to food and animal image
frameLoc = loc1;
picLoc = loc2;

if PA_stimArray{i,3} == 2
    frameLoc = loc2;
    picLoc = loc1;
end

% Cue to determine whether a response has been made
respToBeMade = true;    

% Draw the images on the screen, side by side
Screen('DrawTexture', window, frameTexture,[],frameLoc, 0);
Screen('DrawTexture', window, picTexture, [], picLoc, 0);

% Flip to the screen
Screen('Flip', window);
HideCursor();

%Start trial timer
response = 0; %initialize response 
rt = nan; %initialize rt
tStart = GetSecs;

%Get response information
    while ((GetSecs - tStart)) < 5 && (respToBeMade == true) %if it has been fewer than 3 seconds and a response has not been made
    [keyIsDown,secs, keyCode] = KbCheck; %log response info
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(leftKey)
            response = 1;
            rt = GetSecs - tStart;
            respToBeMade = false;
            Screen('DrawTexture', window, frameTexture,[],frameLoc, 0);
            Screen('DrawTexture', window, picTexture, [], picLoc, 0);
            Screen('FrameRect', window, grey, rect1, 5)
            Screen('Flip', window)
            WaitSecs(5- (GetSecs-tStart));
        elseif keyCode(rightKey)
            response = 2;
            rt = GetSecs - tStart;
            respToBeMade = false;
            Screen('DrawTexture', window, frameTexture,[],frameLoc, 0);
            Screen('DrawTexture', window, picTexture, [], picLoc, 0);
            Screen('FrameRect', window, grey, rect2, 5)
            Screen('Flip', window)
            WaitSecs(5- (GetSecs-tStart));
        end
    end


%% Close textures
Screen('Close',frameTexture);
Screen('Close', picTexture);
  
%%
%log trial end time
tEnd = GetSecs;
  

%% Add trial data to stimArray
PA_stimArray{i, 4} = response;
PA_stimArray{i, 5} = rt;
PA_stimArray{i, 6} = tStart;
PA_stimArray{i, 7} = tEnd;
PA_stimArray{i, 8} = i;

%% ITI

itiInterval = .5;
Screen('FillRect', window, black)
Screen('Flip', window)
WaitSecs(itiInterval)

%% Save data
fileID = fopen(PA_filename, 'a');
fprintf(fileID,formatSpec,PA_stimArray{i, :});

%fprintf writes a space-delimited file.
%Close the file.
fclose(fileID);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END SCREEN
line1 = 'Great!';
disp('end line created');

% Draw all the text in one go
Screen('DrawText', window, line1, (xCenter-50), yCenter, white, black);

% Flip to the screen
HideCursor();
Screen('Flip', window);
KbStrokeWait;
% Clear the screen
sca;














