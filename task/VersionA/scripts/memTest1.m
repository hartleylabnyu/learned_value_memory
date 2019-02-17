%% MEMORY TEST %%
% In this task, participants now need to put stamps on the cards that they saw in
% the previous two tasks. Each card will be presented the same number of
% times as in the frequency task.

%% Get subject info
% Input subject information
%subjectNumber = input('Enter subject number ');

%% Create 2 data files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mem_filename = [int2str(subjectNumber), '_mem1.txt'];
fileID = fopen(mem_filename, 'w');

%specify file format. For this task, the data will be saved in an array with
%7 columns:
% Column 1: card stimulus
% Column 2: mouse click X
% Column 3: mouse click Y
% Column 4: RT
% Column 5: grid where they clicked
% Column 6: trial start
% Column 7: trial end

formatSpec = '%s\t %d\t %d\t %d\t %f\t %d\t %d\n'; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mem2_filename = [int2str(subjectNumber), '_mem1_freqReports.txt'];
fileID = fopen(mem2_filename, 'w');

%specify file format. For this task, the data will be saved in an array with
%7 columns:
% Column 1: card stimulus
% Column 2: mouse click X
% Column 3: mouse click Y
% Column 4: RT
% Column 5: grid where they clicked
% Column 6: trial start
% Column 7: trial end

formatSpec = '%s\t %d\t %d\t %d\t %f\t %d\t %d\n'; 


%% Create a stimulus array for the memory test
numTrials = 48;
memStimArrayOrdered = freqStimOrdered; %from the frequency task. Has all the animals in order.
memStimFirstCards = memStimArrayOrdered(1:numCards);
memStimFirstCards = memStimFirstCards(randperm(size(memStimFirstCards,2)));
memStimSecondCards = memStimArrayOrdered(17:numTrials);
memStimSecondCards = memStimSecondCards(randperm(size(memStimSecondCards,2)));

memStimArray = [memStimFirstCards memStimSecondCards]';

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create image of food responses
% Draw the possible food responses on the screen
% locations of foods should be randomized for each participant, but kept
% constant across trials. First, make a grid with 60 locations. Then
% for each participant, randomly assign each food to a location.

%values that can be changed / response grid specifications
stampSize = 75; 
spacing = 10; 
gridStartX = 215;
gridStartY = 510;
numColumns = 10;
numRows = 2;
numGridLocations = 20;
gridLocations = ones(numGridLocations, 2); %create matrix of ones, with one row for each food location

% create loop to assign all grid locations a number
for i = 1:numGridLocations
    gridLocations(i, 2) = i;
end


%create for loop to fill in x coordinate of lower left corner
for i = [1 1+numColumns 1+(2*numColumns)]
    gridLocations(i, 1) = gridStartX;
    gridLocations(i+1,1) = gridStartX + stampSize + spacing;
    gridLocations(i+2,1)= gridStartX + 2* (stampSize + spacing);
    gridLocations(i+3,1)= gridStartX + 3* (stampSize + spacing);
    gridLocations(i+4,1)= gridStartX + 4* (stampSize + spacing);
    gridLocations(i+5,1)= gridStartX + 5* (stampSize + spacing);
    gridLocations(i+6,1)= gridStartX + 6* (stampSize + spacing);
    gridLocations(i+7,1)= gridStartX + 7* (stampSize + spacing);
    gridLocations(i+8,1)= gridStartX + 8* (stampSize + spacing);
    gridLocations(i+9,1)= gridStartX + 9* (stampSize + spacing);
end

%create for loop to fill in y coordinate of lower left corner
for i = 1:numColumns
    gridLocations(i, 2) = gridStartY;
    gridLocations(i+numColumns, 2) = gridStartY + (stampSize+spacing);
end

%Randomly assign foods to grid locations
addpath 'stamps';
stampStim=dir('stamps/*.jpeg');
stampArray = {stampStim.name}'; 
stampArray = stampArray(randperm(size(stampArray,1)),:); %randomize order of foods
stampArray = stampArray((1:numGridLocations), 1);
for i = 1:length(stampArray)
    stampArray{i, 2} = i;
end

%save this as a separate file
stampGridFilename = [int2str(subjectNumber), '_memTestGrid1.txt'];
stampGridFormatSpec = '%s\t %d\n';
stampGridID = fopen(stampGridFilename, 'w');
for i = 1:length(stampArray)
    fprintf(stampGridID,stampGridFormatSpec,stampArray{i,1:2});
end


%create black rectangle
  backgroundImage = zeros(465, 1280,3, 'uint8');
  result = backgroundImage;

%Make one giant grid using all the names and locations
for i = 1:numGridLocations
    %read in image
    stampImage = imread(stampArray{i,1});
    %resize image
    stampImage = imresize(stampImage, [75 75]);
    obj = stampImage;
    colshift = gridLocations(i,1);
    rowshift = gridLocations(i,2) - gridStartY;
%   Perform the actual indexing to replace the scene's pixels with the object
    result((1:size(obj,1))+rowshift, (1:size(obj,2))+colshift, :) = obj;      
end

%save the result as the grid image
gridImage = result;

%get the size of the grid image and use it to define its location on the
%test screen
sizeGrid = size(gridImage);
gridLocation = [0 gridStartY sizeGrid(2) sizeGrid(1)+gridStartY];


%% Make the image for the frequence responses

%create black rectangle
  backgroundImage = zeros(465, 1280,3, 'uint8');
  result = backgroundImage;

addpath 'memTestFreqResp';
respStim=dir('memTestFreqResp/*.jpg');
respArray = {respStim.name}'; 
respArray = respArray((1:10), 1);

for i = 1:length(respArray)
    respArray{i, 2} = i;
end
  
%Make one giant grid using all the names and locations
for i = 1:10
    %read in image
    respImage = imread(respArray{i,1});
    %resize image
    respImage = imresize(respImage, [75 75]);
    obj = respImage;
    colshift = gridLocations(i,1);
    rowshift = gridLocations(i,2) - (gridStartY - (75+spacing));
%   Perform the actual indexing to replace the scene's pixels with the object
    result((1:size(obj,1))+rowshift, (1:size(obj,2))+colshift, :) = obj;      
end
  
%save the result as the resp image
respImage = result;
sizeResp= size(respImage);
respLocation = [0 gridStartY sizeResp(2) sizeResp(1)+gridStartY];


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



%% Present instruction screens

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath 'instructionsA'
for i = 32:36
instructionPicName = ['Slide', int2str(i), '.jpeg'];
I1 = imread(instructionPicName);
Screen('PutImage', window, I1); % put image on screen

% Flip to the screen
HideCursor();
Screen('Flip', window);
KbStrokeWait;
end

%% Run trial for each row of the array

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------   
    for i = 1:numCards %loop through the first 16 postcards so that each is presented once

% Load the image
addpath 'allCards';
cardImage = memStimArray{i, 1};
cardImage = imread(cardImage);

%resize images
cardImage = imresize(cardImage, [300 300]); 

% Get the size of the image
[s1, s2, s3] = size(cardImage);

% Make the image into a texture
cardTexture = Screen('MakeTexture', window, cardImage);
gridTexture = Screen('MakeTexture', window, gridImage);

%define the animal location
cardLocation = [((screenXpixels/2)-(s1/2)), 100, ((screenXpixels/2)+(s1/2)), 100+s2];
 
% Draw the animal on the screen
Screen('DrawTexture', window, cardTexture, [], cardLocation, 0);
Screen('DrawTexture', window, gridTexture, [], gridLocation, 0);

% Flip to the screen
Screen('Flip', window);
screenshot = Screen('GetImage', window);

% Cue to determine whether a response has been made
respToBeMade = true;  

%Start trial timer
mouseX =[]; %initialize x coordinate
mouseY = []; %initialize y coordinate
rt = []; %initialize rt
tStart = GetSecs;

%Get response information
    while respToBeMade == true %if a valid response has not been made
        ShowCursor(['hand']);
        [mouseX, mouseY, buttons] = GetMouse(window); %record the x and y position of the mouse
        if sum(buttons) > 0 
            memStimArray{i,2} = mouseX;
            memStimArray{i,3} = mouseY;
            %find the location in the grid that corresponds to the mouse
            %click
            gridNumber = find(gridLocations(:,1) < mouseX & gridLocations(:,1) > mouseX - 85 & gridLocations(:,2) < mouseY & gridLocations(:,2) > mouseY - 85);
            if isempty(gridNumber)
                continue
            end   
            rectX = gridLocations(gridNumber,1); %define the lower left corner (X coordinate) of the rectangle they clicked
            rectY = gridLocations(gridNumber,2); %define the lower left corner (Y coordinate) of the rectangle they clicked
            rectLoc = [rectX-5 rectY-5 rectX+stampSize+5 rectY+stampSize+5]; %define the location of the box where they clicked
            rt = GetSecs - tStart; %record RT
            respToBeMade = false; %update response to be made
            Screen('DrawTexture', window, cardTexture, [], cardLocation, 0); %draw the animal again so it stays on the screen
            Screen('DrawTexture', window, gridTexture, [], gridLocation, 0); %draw the food grid again so it stays on the screen
            Screen('FrameRect', window, grey, rectLoc, 5) %draw a grey rectangle around where they clicked
            Screen('Flip', window) %flip to the new screen with the grey rectangle
            WaitSecs(.5); %wait half a second
        end   
    end
    
  
%% Close texture
tEnd = GetSecs;

%% Add the trial data to the array
memStimArray{i,4} = rt; 
memStimArray{i,5} = gridNumber;
memStimArray{i,6} = tStart;
memStimArray{i,7} = tEnd;

%% Save data
fileID = fopen(mem_filename, 'a');
fprintf(fileID,formatSpec,memStimArray{i, :});

%fprintf writes a space-delimited file.
%Close the file.
fclose(fileID);


%% ITI
itiInterval = .5;
%create a black square to go where the animal image goes
blackSquare = zeros(300, 300,3, 'uint8');
% Make the blackSquare into a texture
blackTexture = Screen('MakeTexture', window, blackSquare);
% Replace the animal with a black square, but keep the test grid on the screen
Screen('DrawTexture', window, blackTexture, [], cardLocation, 0);
Screen('DrawTexture', window, gridTexture, [], gridLocation, 0);
Screen('Flip', window)
HideCursor();
WaitSecs(itiInterval);
%Close texture
Screen('Close', blackTexture);

    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PART 2: Test Explicit representations of the frequencies %  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
%% Present instructions for second phase of memory test

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath 'instructionsA'
for i = [37:39, 36]
instructionPicName = ['Slide', int2str(i), '.jpeg'];
I1 = imread(instructionPicName);
Screen('PutImage', window, I1); % put image on screen

% Flip to the screen
HideCursor();
Screen('Flip', window);
KbStrokeWait;
end

%% Shuffle animal order for second phase of memory test
memStimFirstCards = memStimArrayOrdered(1:numCards);
memStimFirstCards = memStimFirstCards(randperm(size(memStimFirstCards,2)));

memStimArray2 = [memStimFirstCards]';

%% PART 2: Test of explicit frequencies

for j = 1:numCards
    % Load the image
    addpath 'allCards';
    cardImage = memStimArray2{j, 1};
    cardImage = imread(cardImage);

    %resize images
    cardImage = imresize(cardImage, [300 300]); 

    % Get the size of the image
    [s1, s2, s3] = size(cardImage);

    % Make the image into a texture
    cardTexture = Screen('MakeTexture', window, cardImage);
    respTexture = Screen('MakeTexture', window, respImage);
    
    %define the animal location
    cardLocation = [((screenXpixels/2)-(s1/2)), 100, ((screenXpixels/2)+(s1/2)), 100+s2];
 
    % Draw the animal on the screen
    Screen('DrawTexture', window, cardTexture, [], cardLocation, 0);
    Screen('DrawTexture', window, respTexture, [], respLocation, 0);

    % Flip to the screen
    Screen('Flip', window);
    screenshot2 = Screen('GetImage', window);
    
    % Cue to determine whether a response has been made
    respToBeMade = true;  

    %Start trial timer
    mouseX =[]; %initialize x coordinate
    mouseY = []; %initialize y coordinate
    rt = []; %initialize rt
    tStart = GetSecs;

%Get response information
    while respToBeMade == true %if a valid response has not been made
        ShowCursor(['hand']);
        [mouseX, mouseY, buttons] = GetMouse(window); %record the x and y position of the mouse
        if sum(buttons) > 0
            memStimArray2{j,2} = mouseX;
            memStimArray2{j,3} = mouseY;
            %find the location in the grid that corresponds to the mouse
            %click
            gridNumber = find(gridLocations(:,1) < mouseX & gridLocations(:,1) > mouseX - 85 & gridLocations(:,2) < mouseY & gridLocations(:,2) > mouseY - 85);
            if isempty(gridNumber)
                continue
            end
            respNumber = gridNumber - 10;
            if respNumber > 10
                continue
            end
            rectX = gridLocations(gridNumber,1); %define the lower left corner (X coordinate) of the rectangle they clicked
            rectY = gridLocations(gridNumber,2); %define the lower left corner (Y coordinate) of the rectangle they clicked
            rectLoc = [rectX-5 rectY-5 rectX+stampSize+5 rectY+stampSize+5]; %define the location of the box where they clicked
            rt = GetSecs - tStart; %record RT
            respToBeMade = false; %update response to be made
            Screen('DrawTexture', window, cardTexture, [], cardLocation, 0); %draw the animal again so it stays on the screen
            Screen('DrawTexture', window, respTexture, [], respLocation, 0); %draw the food grid again so it stays on the screen
            Screen('FrameRect', window, grey, rectLoc, 5) %draw a grey rectangle around where they clicked
            Screen('Flip', window) %flip to the new screen with the grey rectangle
            WaitSecs(.5); %wait half a second
        end  
    end
   

%% Close texture
tEnd = GetSecs;

%% Add the trial data to the array
memStimArray2{j,4} = rt; 
memStimArray2{j,5} = respNumber;
memStimArray2{j,6} = tStart;
memStimArray2{j,7} = tEnd;

%% Save data
fileID = fopen(mem2_filename, 'a');
fprintf(fileID,formatSpec,memStimArray2{j, :});

%fprintf writes a space-delimited file.
%Close the file.
fclose(fileID);

%% ITI
itiInterval = .5;
%create a black square to go where the animal image goes
blackSquare = zeros(300, 300,3, 'uint8');
% Make the blackSquare into a texture
blackTexture = Screen('MakeTexture', window, blackSquare);
% Replace the animal with a black square, but keep the test grid on the screen
Screen('DrawTexture', window, blackTexture, [], cardLocation, 0);
Screen('DrawTexture', window, respTexture, [], respLocation, 0);
Screen('Flip', window)
HideCursor();
WaitSecs(.5);
%Close texture
Screen('Close', blackTexture);
    
     
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BACK TO THE NORMAL MEMORY TEST %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Present instructions for third phase of memory test

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath 'instructionsA'
for i = [41:43]
instructionPicName = ['Slide', int2str(i), '.jpeg'];
I1 = imread(instructionPicName);
Screen('PutImage', window, I1); % put image on screen

% Flip to the screen
HideCursor();
Screen('Flip', window);
KbStrokeWait;
end

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------   
    for i = numCards+1:numTrials %loop through all the rest of the cards

% Load the image
addpath 'allCards';
cardImage = memStimArray{i, 1};
cardImage = imread(cardImage);

%resize images
cardImage = imresize(cardImage, [300 300]); 

% Get the size of the image
[s1, s2, s3] = size(cardImage);

% Make the image into a texture
cardTexture = Screen('MakeTexture', window, cardImage);
gridTexture = Screen('MakeTexture', window, gridImage);

%define the animal location
cardLocation = [((screenXpixels/2)-(s1/2)), 100, ((screenXpixels/2)+(s1/2)), 100+s2];
 
% Draw the animal on the screen
Screen('DrawTexture', window, cardTexture, [], cardLocation, 0);
Screen('DrawTexture', window, gridTexture, [], gridLocation, 0);

% Flip to the screen
Screen('Flip', window);


% Cue to determine whether a response has been made
respToBeMade = true;  

%Start trial timer
mouseX =[]; %initialize x coordinate
mouseY = []; %initialize y coordinate
rt = []; %initialize rt
tStart = GetSecs;

%Get response information
    while respToBeMade == true %if a valid response has not been made
        ShowCursor(['hand']);
        [mouseX, mouseY, buttons] = GetMouse(window); %record the x and y position of the mouse
        if sum(buttons) > 0
            memStimArray{i,2} = mouseX;
            memStimArray{i,3} = mouseY;
            %find the location in the grid that corresponds to the mouse
            %click
            gridNumber = find(gridLocations(:,1) < mouseX & gridLocations(:,1) > mouseX - 85 & gridLocations(:,2) < mouseY & gridLocations(:,2) > mouseY - 85);
            if isempty(gridNumber)
                continue
            end
            rectX = gridLocations(gridNumber,1); %define the lower left corner (X coordinate) of the rectangle they clicked
            rectY = gridLocations(gridNumber,2); %define the lower left corner (Y coordinate) of the rectangle they clicked
            rectLoc = [rectX-5 rectY-5 rectX+stampSize+5 rectY+stampSize+5]; %define the location of the box where they clicked
            rt = GetSecs - tStart; %record RT
            respToBeMade = false; %update response to be made
            Screen('DrawTexture', window, cardTexture, [], cardLocation, 0); %draw the animal again so it stays on the screen
            Screen('DrawTexture', window, gridTexture, [], gridLocation, 0); %draw the food grid again so it stays on the screen
            Screen('FrameRect', window, grey, rectLoc, 5) %draw a grey rectangle around where they clicked
            Screen('Flip', window) %flip to the new screen with the grey rectangle
            WaitSecs(.5); %wait half a second
        end   
    end
    
  
%% Close texture
tEnd = GetSecs;

%% Add the trial data to the array
memStimArray{i,4} = rt; 
memStimArray{i,5} = gridNumber;
memStimArray{i,6} = tStart;
memStimArray{i,7} = tEnd;

%% Save data
fileID = fopen(mem_filename, 'a');
fprintf(fileID,formatSpec,memStimArray{i, :});

%fprintf writes a space-delimited file.
%Close the file.
fclose(fileID);


%% ITI
itiInterval = .5;
%create a black square to go where the animal image goes
blackSquare = zeros(300, 300,3, 'uint8');
% Make the blackSquare into a texture
blackTexture = Screen('MakeTexture', window, blackSquare);
% Replace the animal with a black square, but keep the test grid on the screen
Screen('DrawTexture', window, blackTexture, [], cardLocation, 0);
Screen('DrawTexture', window, gridTexture, [], gridLocation, 0);
Screen('Flip', window)
HideCursor();
WaitSecs(itiInterval);
%Close texture
Screen('Close', blackTexture);

    end
    


   
%% Compute how well they did 

%foodArray has the grid locations of the foods
%PA_stimArray has the food / animal pairings
%memStimArray has the location of where the subject clicked

%Create a new column (column 9) in PA_stimArray and label it with the
%correct location in the food grid
for i = 1:numCards
    stamp = PA_stimArray{i,1}; %select the first food
    allStamps = stampArray(:, 1); %create a list of all the foods
    indexF = strcmp(allStamps, stamp) == 1; %figure out what location in the grid it corresponds to
    index = find(indexF == 1);
    PA_stimArray{i,9} = index; %label the trial with the correct location in the food grid    
end

%Add the correct answers to the memStimArray
for i = 1:length(memStimArray)
    card = memStimArray{i,1}; %select the animal in the row
    PA_cards = PA_stimArray(:,2); %create a column of all the animals in the PA task
    index = strcmp(PA_cards, card) ==1; %find the trial where the animal was presented
    correctResp = PA_stimArray{index, 9}; %extract the correct grid response
    memStimArray{i,8} = correctResp; %add the correct response to the memory array
end

%Compute accuracy for each trial
for i = 1:length(memStimArray)
    if memStimArray{i,5} == memStimArray{i,8}
        memStimArray{i,9} = 1;
    else
        memStimArray{i,9} = 0;
    end
end

%Compute overall accuracy
cardsStamped = sum(cellfun(@double,memStimArray(:,9)));
    
    

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End screen
line1 = 'Great job!';
line2 = '\n\n You stamped ';
line3 = int2str(cardsStamped);
line4 = ' postcards correctly!';

% Draw all the text in one go
Screen('TextSize', window, 30);
DrawFormattedText(window, [line1 line2 line3 line4],...
    'center', screenYpixels * 0.33, white);

% Flip to the screen
HideCursor();
Screen('Flip', window);
KbStrokeWait;
% Clear the screen
sca;
















