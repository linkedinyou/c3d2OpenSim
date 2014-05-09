function [bodyForces] = connectBody2Forces(structData, footMrks);                                        );
%connectbody2Forces() assigns forces to body rather than forceplates.
%   OpenSim connects bodies to forces using an external loads file. However
%   it can be easier if we allocate the external forces to bodies,
%   rather than force(plate) instruments. 
%   This code abstracts the number of inputs so you can have as many bodies
%   and force's as collected.
%   At each time point, forces are allocating to each body based on the 
%   closest body to each force location (COP). 

%   forceStruct = structure of forces, moments and locations (COP)   

%   bodyNames   = the names of each body ie {'r.Foot' 'l.Foot'};

% designate how many mkrs on each foot
nFootMkr = 3;

if nargin == 1

    feetMkrs = findFeetMarkers(structData, nFootMkr);    
    
elseif nargin == 2
    
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


%% Get a centroid mkr for each foot 
nFeet = length(feetMkrs)/nFootMkr;

for i = 1 : nFeet
     % establish the index based on i 
     u = (3*i)-2:(3*i);
     % Calculate the centroid of the three mkrs and save to struct
     structData.marker_data.FootMkr(i).data =...
                   (structData.marker_data.Markers.(mkrNames{u(1)}) + ...
                   structData.marker_data.Markers.(mkrNames{u(2)}) + ...
                   structData.marker_data.Markers.(mkrNames{u(3)}))  ...
                   / 3;
   


end


%% Upsample the mkr data to match the forceplate data
for i = 1:nFeet
    % upsample the body data
    structData.marker_data.FootMkr(i).data =...
                          interp1(sampleArray',...                      % Old sample freq
                          structData.marker_data.FootMkr(i).data,...    % Foot center mkr
                          upSampleArray');                              % new sample freq 
end     

  
%% Loop through the each frame of force data and comapare the distance 
%    between the feet centers and the COP. The closest distance will cause
%    an allocation of that force to that foot. 


for i = 1 : nFP

    % Find the frames when the vertical GRF is non-zero
    forceFrames = find(structData.fp_data.GRF_data(i).F(:,2) > 0);
    % The global location of the force
    COP = structData.fp_data.GRF_data(i).P;

    % Get the distance of the force to each body
    for u = 1 : nFeet
          dist(:,u) = MarkerDistance(COP(forceFrames,:),...
                                  structData.marker_data.FootMkr(u).data(forceFrames,:));
    end
    
    % Get the index for the closests body
    [minDistance closestBody] =  min(mean(dist));
    
    
    
    % save the data to the correct body
    bodyForce(closestBody).force(t,:)   = forceStruct(i).force(t,:);
    bodyForce(closestBody).moment(t,:)  = forceStruct(i).moment(t,:);
    bodyForce(closestBody).cop(t,:)     = forceStruct(i).cop(t,:);
end

        
        
end

   
end  
   
   
   
   
     
     
     
     
     
     
     
     
     