function [structData] = grfProcessing(structData,filterType, Fcut, N, threshold)
%grfProcessing() Processes raw force and moment data
%   Detailed explanation goes here



for i = 1 : length(structData.fp_data.GRF_data)

    analogRate = structData.fp_data.Info(i).frequency;
    
    % get the force channel offset
    offSet = mean(structData.fp_data.GRF_data(i).F(1:100,:));
    % apply the offset to the force channel 
    structData.fp_data.GRF_data(i).F = ...
        bsxfun(@minus, structData.fp_data.GRF_data(i).F, offSet);
    % get the moment channel offset
    offSet = mean(structData.fp_data.GRF_data(i).M(1:100,:));
    % apply the moment channel offset 
    structData.fp_data.GRF_data(i).M = ...
        bsxfun(@minus, structData.fp_data.GRF_data(i).M, offSet);
        
    % determine which channel is the vertical grf 
    [maxValue vgrfCol] = max(max(structData.fp_data.GRF_data(i).F));
    % find when the vertical grf is below a threshold 
    zeroRows = find(structData.fp_data.GRF_data(i).F(:,vgrfCol)<threshold);
    % Zero the forces and moments
    structData.fp_data.GRF_data(i).F(zeroRows,:) = 0;
    structData.fp_data.GRF_data(i).M(zeroRows,:) = 0;
    
    %% filter the Forces and moments
    structData.fp_data.GRF_data(i).F = ...
            filterData(structData.fp_data.GRF_data(i).F,Fcut,analogRate,filterType,N);

    structData.fp_data.GRF_data(i).M = ...
            filterData(structData.fp_data.GRF_data(i).M,Fcut,analogRate,filterType,N);

    % Zero the forces and moments
    structData.fp_data.GRF_data(i).F(zeroRows,:) = 0;
    structData.fp_data.GRF_data(i).M(zeroRows,:) = 0;
    
    
    
end

end

