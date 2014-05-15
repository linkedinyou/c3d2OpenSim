function [markerSideNames] = findFeetMarkers(structData, nFootMkr)
%findFeetMarkers() finds the feet marker label strings
%   Function takes a markers (from a data structure) and searches
%   through the marker data to find the markers with the lowest vertical
%   height, destinguishing them as the foot markers. It is assumed that;
%   Colm 1 is the walking progression (X)
%   Colm 2 is the vertical direction (Y)
%   Colm 3 is the medial/lateral direction (Z)
%
% Input - structData - structure format containing matrix data 
%                      eg structData.marker_data.Markers.LASI = [nx3]
% Output - markerSideNames - array of strings for the feet
%                      eg ['RMT1' 'RMT2' 'RCAL' 'LMT1' 'LMT2' 'LCAL']


% How many total foot markers to look for
nFMkrs = 2* nFootMkr;

% Get the marker struct from the overall data struct
markers = structData.marker_data.Markers;

% MarkerFrames to average out for 
vldFrames = structData.marker_data.Info.VldFrames;
vldFrames = [vldFrames(1) : vldFrames(2)];

% get te fieldnames and number of mkrs
mkrNames = fieldnames(markers);
nMkrs = length(mkrNames);


%% figure out markers closest to the ground

[maxValue vgrfCol] = max(max(abs(structData.fp_data.GRF_data(1).F)))


% Loop through the markers and get each markers minimum height over the
% gait cycle. 
for i = 1 : nMkrs
    
    g = find(markers.(mkrNames{i})(vldFrames', vgrfCol) > 1)
    % Get the minimim height of the markers over the gait cycle
    
    minData = min(markers.(mkrNames{i})(g,vgrfCol));
    
    if ~isempty(minData)
        minH(i) = min(markers.(mkrNames{i})(g,vgrfCol));    
    else
        minH(i) = min(markers.(mkrNames{i})(:,vgrfCol)); 
    end
end

% Define the mean height for all the makers
meanMkrHeight = mean(minH);

% Loop through all te minimum values to get the lowest n number of mkrs.
% These should correspond to the foot markers. Output an array of marker
% names for the foot
for i = 1 : nFMkrs
    % Find the lowest height mkr in the set
    [x, index(i)] = min(minH);
    % Replace the height of that mkr with the mean height so that on the
    % next loop the next lowest height mkr is found
    minH(index(i)) = meanMkrHeight; 
    % Append the mkr names that correspond with the low mkr heights into 
    % an array.
    markerNames(i) = mkrNames(index(i)); 
end

%% Destinguish which mkrs are left and right foot

% First, we will need to find which direction of progression the subject is
% walking in. 
for i = 1 : nMkrs
    % Get the minimim height of the markers over the gait cycle
    mkrProg(i) = markers.(mkrNames{i})(vldFrames(1),1) - markers.(mkrNames{i})(vldFrames(end),1);
end

% Now loop through the foot markers and get the medial/lateral (Z) location
% of each marker
for i = 1 : nFMkrs
    zMkr(i) = mean(markers.(markerNames{i})(vldFrames,3));
end

% Define a value that is lower that minimum Z value
minZ = min(zMkr)-1;
maxZ = min(zMkr)-1;


% If the mean of all the mkr progression values is negative then the positive
% x direction. 
if mean(mkrProg) < 0 

    % Subject is walking in the positive x direction, then right foot
    % markers Z value will be greater than the left foot. 

    for i = 1 : nFMkrs
        [x, index(i)] = max(zMkr);
        % Replace the Z of that mkr with the mean Z so that on the
        % next loop the next lowest Z mkr is found
        zMkr(index(i)) = minZ; 
        % Append the mkr names that correspond with the low mkr heights into 
        % an array.
        markerSideNames(i) = markerNames(index(i)); 
    end
    
else

    % Subject is walking in the negative x direction, then left foot
    % markers Z value will be greater than the right foot. 
    
    for i = 1 : nFMkrs
        [x, index(i)] = min(zMkr);
        % Replace the Z of that mkr with the mean Z so that on the
        % next loop the next lowest Z mkr is found
        zMkr(index(i)) = maxZ; 
        % Append the mkr names that correspond with the low mkr heights into 
        % an array.
        markerSideNames(i) = markerNames(index(i)); 
    end
end
