function [structData] = grfProcessing(structData, threshold,Fcut,N,filtType)
%grfProcessing() Processes raw force and moment data
%   Detailed explanation goes here

% Author: James Dunne, Thor Besier, C.J. Donnelly, S. Hamner.  
% Created: March 2009  Last Update: May 2014


if nargin == 2
    filtData = 0;
else
    filtData = 1;
end

for i = 1 : length(structData.fp_data.GRF_data)

    forceNames = fieldnames(structData.fp_data.FP_data(i).channels);
    
    rate = structData.fp_data.Info(i).frequency;
    
    forces = structData.fp_data.GRF_data(i).F;
    moments = structData.fp_data.GRF_data(i).M;
    
    % get the force and moment channel offset
    forceOffSet  = mean(forces(1:100,:));
    momentOffset = mean(moments(1:100,:));
    % apply the offsets to the force and moment channels
    forces = bsxfun(@minus, forces, forceOffSet);
    moments= bsxfun(@minus, moments, momentOffset);
        
    %% Filter Mkrs
    if filtData
        forces  = filterDataSet(forces...
                     ,Fcut,N,filtType,rate);
        moments = filterDataSet(moments...
                     ,Fcut,N,filtType,rate);         
    end 
    
    
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

