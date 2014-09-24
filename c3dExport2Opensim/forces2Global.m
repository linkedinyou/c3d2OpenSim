function structData = forces2Global(structData)
%% forces2Global()
% btk functions exports (a) forces and moments in the forceplate frame and 
% (b) the forces in the global. 
%
% This function applies a series of rotations to (a) until the forces  
% match (b). In this way both forces and moments will be expressed in the 
% gloabal  and can be used for calculating COP
%
% Written by James Dunne, September (2014). 



    
for i = 1 : length(structData.fp_data.GRF_data)
    
    % get the raw forces and moments in the forceplate frame
    forceNames = fieldnames(structData.fp_data.FP_data(i).channels);
    for u = 1:3
        fpForces(:,u)  = structData.fp_data.FP_data(i).channels.(forceNames{u});
        fpMoments(:,u) = structData.fp_data.FP_data(i).channels.(forceNames{u+3});
    end

    % define the forces that are expressed in the global frame
    globalForces = structData.fp_data.GRF_data(i).F;
    
    
    % Rotate about one of the two axes that are in the plane of the floor.
    % In this case we rotate about the x axis, 90 degrees at a time, until
    % the Z axes are the same. 
    rotation.axis = {'x'};
    rotation.value= [90];
    LoopCounterX = 0;
    while sum(globalForces(:,3)) ~= sum(fpForces(:,3))
        % Rotate the forces and moments by 
        [fpForces] = rotateCoordinateSys(fpForces, rotation);
        [fpMoments] = rotateCoordinateSys(fpMoments, rotation);
        
        
        LoopCounterX = LoopCounterX + 1;

            if LoopCounterX > 6
                error('Z axes of the forceplate and global are not in the same plane. Check function for details')
            end

    end
    
    
    % now rotate about z until the x and Y components are both equal. 
    
    rotation.axis = {'z'};
    rotation.value= [90];
    LoopCounterZ = 0;
    while round(sum(globalForces(:,1))) ~= round(sum(fpForces(:,1))) || round(sum(globalForces(:,2))) ~= round(sum(fpForces(:,2)))
        % Rotate the forces and moments by 
        [fpForces] = rotateCoordinateSys(fpForces, rotation);
        [fpMoments] = rotateCoordinateSys(fpMoments, rotation);
        
        
        LoopCounterZ = LoopCounterZ + 1;

            if LoopCounterZ > 8
                error('Z axes of the forceplate and global are not in the same plane. Check function for details')
            end

    end
    
 
end
    
     
    structData.fp_data.GRF_data(i).F_original = structData.fp_data.GRF_data(i).F;
    structData.fp_data.GRF_data(i).M_original = structData.fp_data.GRF_data(i).M;

    
    % Save the rotated values back to the structure to be used in copCalc()
    structData.fp_data.GRF_data(i).F = fpForces;
    structData.fp_data.GRF_data(i).M = fpMoments;

end    



