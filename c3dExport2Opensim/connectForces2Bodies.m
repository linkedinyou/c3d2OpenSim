function [bodyForce_data] = connectForces2Bodies(structData, footMks, nFeet);                                      
%connectbody2Forces() assigns forces to body rather than forceplates.
%   OpenSim connects bodies to forces using an external loads file. However
%   it can be easier if we allocate the external forces to bodies,
%   rather than force(plate) instruments. 
%   This code abstracts the number of inputs so you can have as many bodies
%   and force's as collected.
%   At each time point, forces are allocating to each body based on the 
%   closest body to each force location (COP). 
%
%   structData = structure of forces, moments and COP 
%
%   footMrks    = {'RCAL' 'RMT1' 'RMT2' 'LCAL' 'LMT1' 'LMT2'}
%                 designate how many mkrs on each foot

%   Written by Thor Besier, James Dunne and Cyril (Jon) Donnelly (2008)
%   Modifed; James Dunne 2014

if  isnumeric(footMks)
    feetMkrs = findFeetMarkers(structData, footMks);    
else
    feetMkrs = footMks;
end


%% Define some variables and matrices 
% Number of forceplate
nFP       = length(structData.fp_data.GRF_data);
% Number of force samples
nForceSamples = length(structData.fp_data.GRF_data(1).F);
% Empty matrix to be filled later
emptyMatrix   = zeros(nForceSamples,3);

% Analog sampling rate 
aRate = structData.fp_data.Info(1).frequency;
% mkr sampling rate 
vRate = structData.marker_data.Info.frequency;
% Sampling ratio between forces and mkr data
samplingRatio =  vRate/aRate;

% Get a list of the marker Names
mkrNames = fieldnames(structData.marker_data.Markers);
% Array for number of video samples
sampleArray      = 1 : length(structData.marker_data.Markers.(mkrNames{1}));
% New Array for 'upsampling' mkr datan
upSampleArray   = 1 : samplingRatio : length(sampleArray);    

% Create some empty array's for the force, moment and COp data to live
for u = 1 : nFeet
    bodyForce_data(u,1).F   = zeros(size(structData.fp_data.GRF_data(u).F));
    bodyForce_data(u,1).M   = zeros(size(structData.fp_data.GRF_data(u).F));
    bodyForce_data(u,1).P   = zeros(size(structData.fp_data.GRF_data(u).F));
end


%% get the centroid of the body mkrs

for i = 1 : nFeet
     % establish the index based on i 
     u = (3*i)-2:(3*i);
     % Calculate the centroid of the three mkrs and save to struct
     structData.marker_data.bodyCenter(i).data =...
                   (structData.marker_data.Markers.(feetMkrs{u(1)}) + ...
                   structData.marker_data.Markers.(feetMkrs{u(2)}) + ...
                   structData.marker_data.Markers.(feetMkrs{u(3)}))  ...
                   / 3;
   
               
    
end
    
%% Upsample the mkr data to match the forceplate data
for i = 1 : nFeet
    % upsample the body data
    structData.marker_data.bodyCenter(i).data =...
                          interp1(sampleArray',...                      % Old sample freq
                          structData.marker_data.bodyCenter(i).data,...    % Foot center mkr
                          upSampleArray');                              % new sample freq 
end     

  
%% Loop through the each frame of force data and comapare the distance 
%    between the feet centers and the COP. The closest distance will cause
%    an allocation of that force to that body. 


for i = 1 : nFP

    % Find the frames when the vertical GRF is non-zero
    forceFrames = find(structData.fp_data.GRF_data(i).F(:,2) > 0);
    % The global location of the force
    COP = structData.fp_data.GRF_data(i).P;

    % Get the distance of the force to each body
    for u = 1 : nFeet
          dist(:,u) = MarkerDistance(COP(forceFrames,:),...
                                  structData.marker_data.bodyCenter(u).data(forceFrames,:));
    end
    
    % Get the index for the closest body
    [minDistance closestBody] =  min(mean(dist));
    
    % save the data to the correct body
    bodyForce_data(closestBody).F(forceFrames,:)   = structData.fp_data.GRF_data(i).F(forceFrames,:);
    bodyForce_data(closestBody).M(forceFrames,:)   = structData.fp_data.GRF_data(i).M(forceFrames,:);
    bodyForce_data(closestBody).P(forceFrames,:)   = structData.fp_data.GRF_data(i).P(forceFrames,:);
    clear dist
end

        
        
end

   
  
     
     
     
     
     
     
     