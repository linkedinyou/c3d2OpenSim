function [bodyForce] = connectBody2Forces(forceStruct,bodyMkrStruct,analogRate,sampleRate,bodyNames);
%connectbody2Forces() assigns forces to body rather than forceplates.
%   OpenSim connects bodies to forces using an external loads file. However
%   it can be easier if we allocate the external forces to bodies,
%   rather than force(plate) instruments. 
%   This code abstracts the number of inputs so you can have as many bodies
%   and force's as collected.
%   At each time point, forces are allocating to each body based on the 
%   closest body to each force location (COP). 
%   forceStruct = structure of forces, moments and locations (COP)   
%                 forceStruct(1).force  = nx3 matrix
%                 forceStruct(1).moment = nx3 matrix
%                 forceStruct(1).cop    = nx3 matrix
%   bodyMkrStruct = mkrStruct with mkrs in order for each body. It is
%                 assumed that each body has 3 markers.
%   analogRate  = analog data capture rate
%   sampleRate  = mkr capture rate
%   bodyNames   = the names of each body ie {'r.Foot' 'l.Foot'};

%% Preallocate some variables
   vertForce     = 3; % coloumn with main force (vertical grf in walking)
   nForces       = length(forceStruct);
   nForceSamples = length(forceStruct(1).force);
   emptyMatrix   = zeros(nForceSamples,3);
   nBodies       = length(bodyNames);
%% Get the centroid of each body and upsample to match force data rate

  % Number of samples taken
  sampleArray      = 1:length(bodyMkrStruct(1).data);
  % Sampling ratio between forces and mkr data
  samplingRatio =  sampleRate/analogRate;
  % new number of samples
  newSampleArray   = 1:samplingRatio:length(bodyMkrStruct(1).data);    
  

    for i = 1:nBodies
        % establish the index based on i 
        u = (3*i)-2:(3*i);
        % Calculate the centroid of the three mkrs and save to struct
        bodyCenter = (bodyMkrStruct(u(1)).data + bodyMkrStruct(u(2)).data + bodyMkrStruct(u(3)).data)/3;
        % upsample the body data
        upSampledBodyOrigin = interp1(sampleArray',bodyCenter,newSampleArray'); % new data 
           %hold; plot(yi);plot(bodyOrigin)
           
        % Save the upsampled data into a structure   
        bodyOrigin(i).data = upSampledBodyOrigin;
        % Create an empty struture for the body
        bodyForce(i)= struct('force',{emptyMatrix},'moment',{emptyMatrix},'cop',{emptyMatrix});
    end     

  
%% Compare the distance between the forces and bodies and allocate

for i = 1:nForces
    for t = 1:nForceSamples
       if forceStruct(i).force(t,vertForce) > 0 % a force is being applied
            % The global location of the force
            forceLocation = forceStruct(i).cop(t,:);
            % Get the distance of the force to each body
            for u = 1:nBodies
                dist(u) = markerDistance(forceLocation,bodyOrigin(u).data(t,:));
            end    
            % Establish what is the minimum distance and which body is the
            % closest to the force location
            [minDistance closestBody] =  min(dist);
            % save the data to the correct body
            bodyForce(closestBody).force(t,:)   = forceStruct(i).force(t,:);
            bodyForce(closestBody).moment(t,:)  = forceStruct(i).moment(t,:);
            bodyForce(closestBody).cop(t,:)     = forceStruct(i).cop(t,:);
       end
    end
end

   
end  
   
   
   
   
     
     
     
     
     
     
     
     
     