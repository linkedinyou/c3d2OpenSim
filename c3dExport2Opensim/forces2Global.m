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
    % In the first case we rotate about the x axis, 90 degrees at a time, until
    % the Z axes aline. 
    [fpForces fpMoments] = flipAxisAround(globalForces,fpForces, fpMoments, 'x', 3 );
    
    % Now that the Z axes aline, rotate about z until the x and Y components are both equal. 
    [fpForces fpMoments] = flipAxisAround(globalForces,fpForces, fpMoments, 'z', 1 );
    
    structData.fp_data.GRF_data(i).F_original = structData.fp_data.GRF_data(i).F;
    structData.fp_data.GRF_data(i).M_original = structData.fp_data.GRF_data(i).M;

    % Save the rotated values back to the structure to be used in copCalc()
    structData.fp_data.GRF_data(i).F = fpForces;
    structData.fp_data.GRF_data(i).M = fpMoments;
end

end    



function [fpForces fpMoments] = flipAxisAround(globalForces, fpForces, fpMoments, rotateAround, axisCheck )

    rotation.axis = {rotateAround};
    rotation.value= [90];
    LoopCounter = 0;
    while round(sum(globalForces(:,axisCheck))) ~= round(sum(fpForces(:,axisCheck)))
        
        % Rotate the forces and moments by 
        [fpForces] = rotateCoordinateSys(fpForces, rotation);
        [fpMoments] = rotateCoordinateSys(fpMoments, rotation);
        
        LoopCounter = LoopCounter + 1;

            if LoopCounter > 8
                error('Axes of the forceplate and global are not in the same plane. Check function for details')
            end

    end
end