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
% Column 1: stamp stimulus
% Column 2: card stimulus
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
stampStim=dir('stamps/*.jpeg');
stampArray = {stampStim.name}; 
cardStim = cardArray; %from the frequency task

%Randomize order of food and animal arrays
stampOrder = randperm(numCards); %generate random food order
cardOrder = randperm(numCards); %generate random animal order
leftRight = [1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 ]; %create vector of 1s and 2s
leftRight = leftRight(randperm(length(leftRight))); %randomize the order

%create empty PA_stim array
PA_stimArray = cell.empty(numCards, 0);

for i = 1:numCards
    stamp = stampArray{stampOrder(i)};
    card = cardArray{cardOrder(i)};
    PA_stimArray{i,1} = stamp;
    PA_stimArray{i,2} = card;
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
numTrials = numCards; %numAnimals is the number of animals that were presented in the frequency task


%% Present instruction screens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath 'instructionsB'

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
addpath 'stamps';
stampImage = PA_stimArray{i, 1};
stampImage = imread(stampImage);

addpath 'allCards';
cardImage = PA_stimArray{i, 2};
cardImage = imread(cardImage);

%resize images
stampImage = imresize(stampImage, [300 300]); 
cardImage = imresize(cardImage, [300 300]); 

% Get the size of the image
[s1, s2, s3] = size(stampImage);

% Make the image into a texture
stampTexture = Screen('MakeTexture', window, stampImage);
cardTexture = Screen('MakeTexture', window, cardImage);

%Define image locations
loc1 = [(screenXpixels/4 - (s1)/2 + 50) (screenYpixels/2 - (s2)/2) ((screenXpixels/4 - (s1)/2)+350) ((screenYpixels/2 - (s2)/2)+300)];
loc2 = [(screenXpixels/2 + (s1)/2 - 50) (screenYpixels/2 - (s2)/2) ((screenXpixels/2 + (s1)/2)+250) ((screenYpixels/2 - (s2)/2)+300)];
rect1 = [(screenXpixels/4 - (s1)/2) (screenYpixels/2 - (s2)/2 - 50) ((screenXpixels/4 - (s1)/2)+400) ((screenYpixels/2 - (s2)/2)+350)];
rect2 = [(screenXpixels/2 + (s1)/2 - 100) (screenYpixels/2 - (s2)/2 - 50) ((screenXpixels/2 + (s1)/2)+300) ((screenYpixels/2 - (s2)/2)+350)];

%assign image locations to food and animal image
stampLoc = loc1;
cardLoc = loc2;

if PA_stimArray{i,3} == 2
    stampLoc = loc2;
    cardLoc = loc1;
end

% Cue to determine whether a response has been made
respToBeMade = true;    

% Draw the images on the screen, side by side
Screen('DrawTexture', window, stampTexture,[],stampLoc, 0);
Screen('DrawTexture', window, cardTexture, [], cardLoc, 0);

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
            Screen('DrawTexture', window, stampTexture,[],stampLoc, 0);
            Screen('DrawTexture', window, cardTexture, [], cardLoc, 0);
            Screen('FrameRect', window, grey, rect1, 5)
            Screen('Flip', window)
            WaitSecs(5- (GetSecs-tStart));
        elseif keyCode(rightKey)
            response = 2;
            rt = GetSecs - tStart;
            respToBeMade = false;
            Screen('DrawTexture', window, stampTexture,[],stampLoc, 0);
            Screen('DrawTexture', window, cardTexture, [], cardLoc, 0);
            Screen('FrameRect', window, grey, rect2, 5)
            Screen('Flip', window)
            WaitSecs(5- (GetSecs-tStart));
        end
    end


%% Close textures
Screen('Close',stampTexture);
Screen('Close', cardTexture);
  
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
line1 = 'Great job!';

% Draw all the text in one go
Screen('TextSize', window, 30);
DrawFormattedText(window, [line1],...
    'center', screenYpixels * 0.33, white);

% Flip to the screen
HideCursor();
Screen('Flip', window);
KbStrokeWait;

% Clear the screen
sca;














