function [structData] = grfProcessing(structData, Fcut, N, filterType, threshold)
%grfProcessing() Processes raw force and moment data
%   Detailed explanation goes here



for i = 1 : length(structData.fp_data.GRF_data)

    eval([' forces(:,1) = structData.fp_data.FP_data(i).channels.Fx' num2str(i) ';']);
    eval([' forces(:,2) = structData.fp_data.FP_data(i).channels.Fy' num2str(i) ';']);
    eval([' forces(:,3) = structData.fp_data.FP_data(i).channels.Fz' num2str(i) ';']);
    eval([' moments(:,1) = structData.fp_data.FP_data(i).channels.Mx' num2str(i) ';']);
    eval([' moments(:,2) = structData.fp_data.FP_data(i).channels.My' num2str(i) ';']);
    eval([' moments(:,3) = structData.fp_data.FP_data(i).channels.Mz' num2str(i) ';']);

    % get the analoge data rate 
    analogRate = structData.fp_data.Info(i).frequency;
    % get the force and moment channel offset
    forceOffSet = mean(forces(1:100,:));
    momentOffset = mean(moments(1:100,:));
    % apply the offsets to the force and moment channels
    forces = bsxfun(@minus, forces, forceOffSet);
    moments= bsxfun(@minus, moments, momentOffset);
        
    % determine which channel is the vertical grf 
    [maxValue vgrfCol] = max(max(abs(forces)));
    % find when the vertical grf is below a threshold 
    zeroRows = find(abs(forces(:,vgrfCol))<threshold);
%     % Zero the forces and moments
%     forces(zeroRows,:) = 0;
%     moments(zeroRows,:) = 0;
    
    %% filter the Forces and moments
    forces = filterData(forces,Fcut,N,filterType,analogRate);
    moments = filterData(moments,Fcut,N,filterType,analogRate);

    % Zero the forces and moments
    forces(zeroRows,:) = 0;
    moments(zeroRows,:) = 0;
    
    
    %% Rotate the forces and moments from the channels to match that of the 
      % forceplate forces. 
      
      % Since the channels are based in the forceplate coordinate system,
      % we have to rotate these into the system of the global. The problem
      % with this is that btk doesnt supply (at the time of writting) the
      % forceplate frames in the global. What is supplied is the
      % transformed forces located in structData.fp_data.GRF_data.F
      % Using this data, we can do a series of comparisons and then rotate
      % the processed channel data so that it is in the coorect coordinate
      % system for calculating COP. 
      
      % get the vertical grf coloum in the global
      [maxValue globalVgrfCol] = max(max(structData.fp_data.GRF_data(i).F));
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
      xFpMax = max(abs(forces(:,1)));
      
      % get abs max of the global forces
      xGlobMax =   max(abs(structData.fp_data.GRF_data(i).F(:,1)));
      yGlobMax =   max(abs(structData.fp_data.GRF_data(i).F(:,2)));
      
      if abs(xFpMax - xGlobMax) > abs(xFpMax - yGlobMax)
             forces = [forces(:,2) forces(:,1) forces(:,3)];
             moments = [moments(:,2) moments(:,1) moments(:,3)];
      end
    
      % get the differences between the x and y component forces
      xDiff = structData.fp_data.GRF_data(i).F(:,1) - forces(:,1);
      yDiff = structData.fp_data.GRF_data(i).F(:,2) - forces(:,2);
      
      % if the difference is greater than the channel then flip      
      if max(xDiff) > max(forces(:,1))
            forces(:,1) = -forces(:,1);
            moments(:,1) = -moments(:,1);
      end
      % if the difference is greater than the channel then flip
      if max(yDiff) > max(forces(:,2))
            forces(:,2) = -forces(:,2);
            moments(:,2) = -moments(:,2);
      end
      
      % Save the rotated values back to the structure to be used for later
      % COP Calculation. 
      structData.fp_data.GRF_data(i).F = forces;
      structData.fp_data.GRF_data(i).M = moments;
    
    
end

end

