function [structData] = grfProcessing(structData, filterProp, zeroOffsets, thresholdChannels)
%grfProcessing() Processes raw force and moment data
% structData            Structure with forceplate data located in the 
%                           form structData.fp_data.GRF_data(i).F
%
% filterProp            Structure holding cut off frquency, order and filtertype      
%
% zeroOffsets          Bool (0 or 1) indicating if the channels need to be    
%                           zeroed due to an offset in the values
%
% thresholdChannels     Bool (0 or 1) zeros all forces and moments below a 
%                         a threshold value of Fz 

% Author: James Dunne, Thor Besier, C.J. Donnelly, S. Hamner.  
% Created: March 2009  Last Update: May 2014


for i = 1 : length(structData.fp_data.GRF_data)

    % capture rate of the forceplate
    rate = structData.fp_data.Info(i).frequency;
    
    % Dump out forces and moments for conveniance 
    forces = structData.fp_data.GRF_data(i).F;
    moments = structData.fp_data.GRF_data(i).M;

    % get the force and moment channel offset
%     forceOffSet  = mean(forces(1:100,:));
%     momentOffset = mean(moments(1:100,:));
%     
%     if zeroOffsets
%         % apply the offsets to the force and moment channels
%         forces = bsxfun(@minus, forces, forceOffSet);
%         moments= bsxfun(@minus, moments, momentOffset);
%     end
%     
%     
%     if thresholdChannels
%         %Get the rand of noise for the first hundred frames
%         zforceNoiseRange = range(forces(1:100,3));
%         % Find when the fz forces are below this range
%         zeroFrames = find( forces(:,3) < 2*zforceNoiseRange);
%         % zero the forces and momentswhen below that range
%         forces(zeroFrames,:) = 0;
%         moments(zeroFrames,:) = 0;
%     end
    
    % Filter the force and moment data
    forces  = filterDataSet(forces , filterProp, rate, 'grf');
    moments = filterDataSet(moments, filterProp, rate, 'grf');         
   
    
%     if thresholdChannels
%         % Clean-up the grf end point bleeding caused by the filter
%         forces(zeroFrames,:) = 0;
%         moments(zeroFrames,:) = 0;
%     end    
    
    % Save the processed data back to the structure
    structData.fp_data.GRF_data(i).F = forces;
    structData.fp_data.GRF_data(i).M = moments;
    
end

end
