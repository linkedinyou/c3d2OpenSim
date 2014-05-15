function [structData] = grfProcessing(structData, Fcut, N, filterType, threshold)
%grfProcessing() Processes raw force and moment data
%   Detailed explanation goes here



for i = 1 : length(structData.fp_data.GRF_data)

    forceNames = fieldnames(structData.fp_data.FP_data(i).channels);
    
    forces(:,1) = structData.fp_data.FP_data(i).channels.(forceNames{1});
    forces(:,2) = structData.fp_data.FP_data(i).channels.(forceNames{2});
    forces(:,3) = structData.fp_data.FP_data(i).channels.(forceNames{3});
    moments(:,1) = structData.fp_data.FP_data(i).channels.(forceNames{1});
    moments(:,2) = structData.fp_data.FP_data(i).channels.(forceNames{2});
    moments(:,3) = structData.fp_data.FP_data(i).channels.(forceNames{3});

    % get the force and moment channel offset
    forceOffSet  = mean(forces(1:100,:));
    momentOffset = mean(moments(1:100,:));
    % apply the offsets to the force and moment channels
    forces = bsxfun(@minus, forces, forceOffSet);
    moments= bsxfun(@minus, moments, momentOffset);
        
    % determine which channel is the vertical grf 
    [maxValue vgrfCol] = max(max(abs(forces)));
    % find when the vertical grf is below a threshold 
    zeroRows = find(abs(forces(:,vgrfCol))<threshold);
    
    % Zero the forces and moments when forces are below threshold
    forces(zeroRows,:) = 0;
    moments(zeroRows,:) = 0;
    
    % Save the processed data back to the structure
    structData.fp_data.GRF_data(i).F = forces;
    structData.fp_data.GRF_data(i).M = moments;
    
end

end

