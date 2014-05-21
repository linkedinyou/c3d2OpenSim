function structData = forces2Global(structData)
%% forces2Global()
% Rotate the forces and moments from the channels to match that of the 
% forceplate forces. 

% Since the channels are based in the forceplate coordinate system,
% we have to rotate these into the system of the global. The problem
% with this is that btk doesnt supply (at the time of writting) the
% forceplate frames in the global. What is supplied is the
% transformed forces located in structData.fp_data.GRF_data.F
% Using this data, we can do a series of comparisons and then rotate
% the processed channel data so that it is in the coorect coordinate
% system for calculating COP. 

for i = 1 : length(structData.fp_data.GRF_data)

    forceNames = fieldnames(structData.fp_data.FP_data(i).channels);
    
    for u = 1:3
        forces(:,u)  = structData.fp_data.FP_data(i).channels.(forceNames{u});
        moments(:,u) = structData.fp_data.FP_data(i).channels.(forceNames{u+3});
    end
   
    % get the vertical grf coloum the forceplate analog channel
    [maxValue vgrfCol] = max(max(abs(forces)));
    
    % get the vertical grf coloum in the global
    [maxValue globalVgrfCol] = max(max(abs(structData.fp_data.GRF_data(i).F)));
    % get the difference between the two vertical ground reaction forces
    zDiff = structData.fp_data.GRF_data(i).F(:,globalVgrfCol) - forces(:,vgrfCol);
    
    % if they are in the same coordinate system then they would negate
    % one another and be less than the max. If greater than the max, then
    % the force needs to be flipped. 
    if max(zDiff) > max(forces(:,vgrfCol))
        forces(:,vgrfCol) = -forces(:,vgrfCol);
        moments(:,vgrfCol) = -moments(:,vgrfCol);
    end

    % before we do the same to fx and fy, we need to check if they are 
    % both in the correct frame. If the forceplates have been rotated in
    % the global the forceplate x will be in the global y and vice versa.

    % get abs max of the x force from the channels
    xMaxFP = max(abs(forces(:,1)));

    % get abs max of the global forces
    xMaxGlobal =   max(abs(structData.fp_data.GRF_data(i).F(:,1)));
    yMaxGlobal =   max(abs(structData.fp_data.GRF_data(i).F(:,2)));

    if xMaxFP == yMaxGlobal
       % reoder colomns so that the forceplate X is now in the Y col.
       forces = [forces(:,2) forces(:,1) forces(:,3)];
       moments = [moments(:,2) moments(:,1) moments(:,3)]; 
    end
    

    % get the differences between the x and y component forces
    xDiff = structData.fp_data.GRF_data(i).F(:,1) - forces(:,1);
    yDiff = structData.fp_data.GRF_data(i).F(:,2) - forces(:,2);

    % if the columns are the same their diff will = 0. Otherwise, flip 
    if  sum(structData.fp_data.GRF_data(i).F(:,1) - forces(:,1)) ~= 0 
        forces(:,1) = -forces(:,1);
        moments(:,1) = -moments(:,1);
    end
    
    % if the columns are the same their diff will = 0. Otherwise, flip 
    if sum(structData.fp_data.GRF_data(i).F(:,2) - forces(:,2)) ~= 0 
        forces(:,2)  = -forces(:,2);
        moments(:,2) = -moments(:,2);
    end

       
%     
%     hold on
%     plot(forces, 'r')
%     plot(structData.fp_data.GRF_data(i).F, 'k')
%     
    structData.fp_data.GRF_data(i).F_original = structData.fp_data.GRF_data(i).F;
    structData.fp_data.GRF_data(i).M_original = structData.fp_data.GRF_data(i).M;

    
    % Save the rotated values back to the structure to be used in copCalc()
    structData.fp_data.GRF_data(i).F = forces;
    structData.fp_data.GRF_data(i).M = moments;

end    



end