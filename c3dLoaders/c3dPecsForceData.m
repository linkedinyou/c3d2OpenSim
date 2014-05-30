function [forceStruct] = c3dPecsForceData(nFP,hTrial)
% UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
                for i = 0:nFP-1
                        cont = 1;
                        hFP = invoke(hTrial, 'ForcePlate', i);
                        %Obtain a ForcePlate interface for the i-th
                        % Force Plate
                        first = invoke(hFP, 'FirstSampleNum'); %First valid sample number for the FP
                        last = invoke(hFP, 'LastSampleNum'); %Last valid sample number for the FP
                        MU = invoke(hFP, 'MomentUnits');
                        %FP moment units
                        SR = invoke(hFP, 'SampleRate');
                        %FP sample rate
                        Forces = invoke(hFP, 'GetForces', first, last);
                        %X, Y, Z FP Force
                        %coordinates from
                        %first to last FP sample
                        Moments = invoke(hFP, 'GetMoments', first, last);
                        COP=invoke(hFP, 'GetCenterOfPressures', first,last);

                        % Vicon starts their numbering index from zero.
                        % This just sets each forceplate in the structure
                        % from 1 onwards
                        p=i+1;
                        
                        
                        dimensionArray =[];
                        for s=1:4 %Number of corners of the forceplate	
                            hCorners = invoke(hFP,'Corner',s);
                            cornerX = get(hCorners,'X');
                            cornerY = get(hCorners,'Y');
                            cornerZ = get(hCorners,'Z');			
                            cornerCordinates=[cornerX cornerY cornerZ];
                            dimensionArray =[dimensionArray;cornerCordinates] ;
                        end
                        
                        
                        forceStruct(p)=struct(                  ...
                            'name',{['Forces' num2str(i+1)]},   ...
                            'force',{Forces'},                  ...
                            'moment',{Moments'},               ...
                            'cop',{COP'},                       ...
                            'corners',{dimensionArray});
     
                        release(hFP);
                end
                
               
                               
                
end

