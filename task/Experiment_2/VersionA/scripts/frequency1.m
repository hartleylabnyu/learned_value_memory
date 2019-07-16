%% FREQUENCY TASK %%
% In this task, participants see postcards that vary in the frequency with
% which they are presented. They need to press a button when they see a
% repeated postcard.

clear all
close all

%% Skip sync tests %%
Screen('Preference', 'SkipSyncTests', 1);

%% Shuffle random seed %%
rng('shuffle');
KbName('UnifyKeyNames');

%% Get subject information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input subject information
subjectNumber = input('Enter subject number ');
cbNumber = input('Enter counter-balance condition (1 or 2) ');

%% Create data file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
freq_filename = [int2str(subjectNumber), '_freqTask1.txt'];
fileID = fopen(freq_filename, 'w');

%specify file format. For this task, the data will be saved in a table with
%6 columns:
% Column 1: postcard
% Column 2: frequency condition
% Column 3: response
% Column 4: RT
% Column 5: Trial Start
% Column 6: Trial End
% Column 7: Trial Number

formatSpec = '%s\t %f\t %f\t %d\t %d\t %d\t %f\n'; 

%% Decide how many different postcards
% In this version, there will be 16 cards across 2 levels of
% frequency: 1 and 5.
numCards = 16;
freq1 = 1;
freq2 = 5;
numTrials = ((numCards/2) * (freq1 + freq2));


%% Create array with random card/ frequency pairings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create list of card stimuli
% Assign folder to each of the two frequency conditions
if cbNumber == 1
    cardStim1 = dir('cards_set1/*.jpg');
    card1Array = {cardStim1.name};
    cardStim2 = dir('cards_set2/*.jpg');
    card2Array = {cardStim2.name};
else
    cardStim1 = dir('cards_set2/*.jpg');
    card1Array = {cardStim1.name};
    cardStim2 = dir('cards_set1/*.jpg');
    card2Array = {cardStim2.name};
end

cardArray = horzcat(card1Array, card2Array); %stack arrays 

%% Add frequency info to arrays
freq1 = 1*ones((numCards/2), 1);
freq2 = 5*ones((numCards/2), 1);
frequencies = [freq1; freq2];

%create empty frequency array
freqArray = cell.empty(numCards, 0);

%assign cardss to frequencies
for i = 1:numCards
    card = cardArray{i};
    freqArray{i,1} = card;
    freqArray{i,2} = frequencies(i);
end

%create new array of cards based on the frequencies they have been
%assigned

%create empty stim array
freq = cell.empty(numCards, 0);

for i = 1:numCards
    freqStimArray{i,1} = freqArray{i,1}; %first 16 rows of stimulus array have each stamp
    freqStimArray{i,2} = freqArray{i,2};
end

%then make the next 4 rows of the array, which should have all the cards
%that are repeated 5 times
for i = 1:(numCards/2)
    freqStimArray{i+numCards,1} = freqArray{i+(numCards/2),1};
    freqStimArray{i+numCards,2} = freqArray{i+(numCards/2),2};
end

%then make the next 8 rows of the array, which should have all the cards
%that are repeated 5 times (3rd appearance)
for i = 1:(numCards/2)
    freqStimArray{i+(numCards+8),1} = freqArray{i+(numCards/2),1};
    freqStimArray{i+(numCards+8),2} = freqArray{i+(numCards/2),2};
end

%then make the next 8 rows of the array, which should have all the cards
%that are repeated 5 times (4th appearance)
for i = 1:(numCards/2)
    freqStimArray{i+(numCards+16),1} = freqArray{i+(numCards/2),1};
    freqStimArray{i+(numCards+16),2} = freqArray{i+(numCards/2),2};
end

%then make the next 8 rows of the array, which should have all the cards
%that are repeated 5 times (5th appearance)
for i = 1:(numCards/2)
    freqStimArray{i+(numCards+24),1} = freqArray{i+(numCards/2),1};
    freqStimArray{i+(numCards+24),2} = freqArray{i+(numCards/2),2};
end



%randomize order of stimulus array
freqStimOrdered = freqStimArray; %use this later
freqStimArray = freqStimArray(randperm(size(freqStimArray,1)),:);


%%
%----------------------------------------------------------------------
%                       Screen Information
%----------------------------------------------------------------------
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

%%
%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------
% Define the keyboard keys that are listened for. We will be using the up arrow 
% key as the response key for the task and the escape key as
% an exit/reset key
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');


%% Present instruction screens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 addpath 'instructionsA'
% 
for i = 1:12
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
%                       Experimental loop
%----------------------------------------------------------------------
for i = 1:numTrials

% Load the image
addpath 'allCards';
cardImage = freqStimArray{i, 1};
cardImage = imread(cardImage);

%resize images
cardImage = imresize(cardImage, [300 300]); 

% Get the size of the image
[s1, s2, s3] = size(cardImage);

% Make the image into a texture
cardTexture = Screen('MakeTexture', window, cardImage);
  
% Draw the card on the screen
Screen('DrawTexture', window, cardTexture, [], [], 0);

% Flip to the screen
Screen('Flip', window);
HideCursor();

% Cue to determine whether a response has been made
respToBeMade = true;  

%Start trial timer
response = 0; %initialize response 
rt = []; %initialize rt
tStart = GetSecs;

%Get response information
    while ((GetSecs - tStart)) < 2 && (respToBeMade == true) %if it has been fewer than 2 seconds and a response has not been made
    [keyIsDown,secs, keyCode] = KbCheck; %log response info
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(upKey)
            response = 1;
            rt = GetSecs - tStart;
            WaitSecs(2- (GetSecs-tStart));
        end
    end
    
tEnd = GetSecs;
disp('Stimulus display completed');
  
%% Close texture
Screen('Close', cardTexture);
disp('Texture closed');

%% ITI
itiInterval = .5;
Screen('FillRect', window, black);
Screen('Flip', window);
WaitSecs(itiInterval);
disp('ITI completed');

%% Add trial data to stimArray
freqStimArray{i, 3} = response;
freqStimArray{i, 4} = rt;
freqStimArray{i, 5} = tStart;
freqStimArray{i, 6} = tEnd;
freqStimArray{i, 7} = i; 
disp('data added to array');

%% Save data
fileID = fopen(freq_filename, 'a');
fprintf(fileID,formatSpec,freqStimArray{i, :});

%fprintf writes a space-delimited file.
%Close the file.
fclose(fileID);

disp('data saved');
end

%% Present End screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END SCREEN
line1 = 'Great job!';
disp('end line created');

% Draw all the text in one go
Screen('DrawText', window, line1, (xCenter-50), yCenter, white, black);

% Flip to the screen
HideCursor();
Screen('Flip', window);
KbStrokeWait;

%%
% Clear the screen
sca;

