function [bodyForce_data] = connectForces2Bodies(structData, body);                                      
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


    if ~body.useBodies
        bodyForce_data = structData.fp_data.GRF_data;
        return
    end
    % get body names
    bodyNames = fieldnames(body.bodies);

    % number of bodies
    nBodies   = length(bodyNames);
    
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
    for u = 1 : nBodies
        bodyForce_data(u,1).F   = zeros(size(structData.fp_data.GRF_data(u).F));
        bodyForce_data(u,1).M   = zeros(size(structData.fp_data.GRF_data(u).F));
        bodyForce_data(u,1).P   = zeros(size(structData.fp_data.GRF_data(u).F));
    end

%% check to see if valid input marker list. If not, exit from function
mkrList = [];
for i = 1 : nBodies
    mkrList = [mkrList body.bodies.(bodyNames{i})]; 
end

for i = 1 : length(mkrList)
    % check that the input input body markers are in the trial. If not,
    % exit the function.
    if isempty(find(ismember(mkrNames,char(mkrList(i)))));
       bodyForce_data = structData.fp_data.GRF_data;
       display(['WARNING: Input body based marker ' char(mkrList(i)) ' not in trial, exiting function']) 
       return
    end
end

%% get the centroid of the body mkrs
for i = 1 : nBodies
     % Calculate the centroid of the three mkrs and save to struct
     for u = 1 : 3
         body.bodyPoint.(bodyNames{i}) = ...
                 (structData.marker_data.Markers.(char(body.bodies.(bodyNames{i})(1))) + ...
                 structData.marker_data.Markers.(char(body.bodies.(bodyNames{i})(2))) + ...
                 structData.marker_data.Markers.(char(body.bodies.(bodyNames{i})(3))) )  ...
                 /3 ;
     end
end

%% Upsample the mkr data to match the forceplate data
for i = 1 : nBodies
    % upsample the body data
    body.bodyPoint.(bodyNames{i}) =...
                          interp1(sampleArray',...                      % Old sample freq
                          body.bodyPoint.(bodyNames{i}),...             % body point
                          upSampleArray');                              % new sample freq 
end     

  
%% Loop through each frame of each forces and sort the forces into body 
%   system based arrays. Sorting is done by comparing each body location
%   with tne force location (COP) and determining which body is cloest. 


for i = 1 : nFP

    % Find the frames when the vertical GRF is non-zero
    forceFrames = find(structData.fp_data.GRF_data(i).F(:,2) > 0);
    % The global location of the force (in mm)
    COP = structData.fp_data.GRF_data(i).P*1000;

    % Get the distance of the force to each body
    for u = 1 : nBodies
          dist(:,u) = MarkerDistance(COP(forceFrames,:),...
                                  body.bodyPoint.(bodyNames{u})(forceFrames,:));
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


   
  
     
     
     
     
          
     