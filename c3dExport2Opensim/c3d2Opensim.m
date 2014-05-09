function c3d2Opensim(structData)
% c3d2OpenSim()
% 
% Function to export struture structData created from btk_btkloadc3d()
% to .trc (marker structData) and .mot (force structData).  
%
% Input - structData - structured data which may contain fields for;
%           marker_data - any calculated data from the reconstructed C3D
%               file including marker trajectories and any calculated  
%               angles, moments, powers or GRF data
%           analog_data - analog data (often sampled at a higher rate)often
%               force plate data and EMG data that might be collected.
%           grw_data - structure with the position magnitude of ground 
%               reaction force vector and moments relative to the global
%               cooridinate system
%           fp_info - structure with the force outputs from the force 
%               plates including the ground reaction wrench (force vector 
%               calculated in the global axis frame) and relevant 
%               sampling and forceplate position information             
%           sub_info - extra data from the C3D file if it exists, inlcuding
%               height and weight etc.
%
% Output - trialName.trc - a trc file containing marker positions using an 
%                          "Y is up" right handed frame global system
%          trialName.mot - a mot file containing forces, COP and moment
%          data
%
% Author: James Dunne, Thor Besier, C.J. Donnelly, S. Hamner.  
% Created: March 2009  Last Update: Dec 2013 

%% 

if nargin < 1
    [filein, pathname] = uigetfile({'*.c3d','C3D file'}, 'C3D data file...');
    structData = btk_loadc3d(fullfile(pathname,filein), 10);
end

%% Filter the structData
structData.marker_data.Markers = filterData(structData.marker_data.Markers,...
                                        8,...
                                        structData.marker_data.Info.frequency,...
                                        'butt',...
                                        8);

%% Rotate the structData into the coodinate system of OpenSim
rotAxis  ='x';
Rot1     = 90;
[structData.marker_data.Markers] = rotateCoordinateSys(structData.marker_data.Markers,...
                                                    rotAxis,...
                                                    Rot1);

                                                
%% Print the structData into a OpenSim trc format 
printTRC(structData.marker_data.Markers,...         % Markers
         structData.marker_data.Info.frequency,...  % video freq
         structData.marker_data.Filename);          % filename

     
     
%% Read the Forces, moments and Force plate dimensions from trial%%%
if isempty(findstr(lower(structData.marker_data.Filename),'static'))   

%% Number of forceplates
    nFP = length(structData.fp_data.Info);
    
%% Processing of the GRF structData includes taking bias out of the 
%   forceplate, zeroing below a threshold, and filtering. 
    Fcut       = 16;  % Cut off frequency for the forceplate
    order      = 4;   % filter order, must be an even number
    zeroThres  = 5;   % Threshold for the Fz channel to zero under
    filterType = 'butt'; % crit = critically damped, 'butt' = butterworth

    [structData] = grfProcessing(structData,'butt', 16,2,zeroThres);

%% Calculate COP 
    [structData] = copCalc(structData);

%% Rotate into OpenSim Frame

for i = 1 : nFP
    % Forces
    [structData.fp_data.GRF_data(i)] = ...
                    rotateCoordinateSys(structData.fp_data.GRF_data(i),...
                                        rotAxis,...
                                        Rot1);
end

%% Convert COP into meters rather than mm
for i = 1 : nFP
    structData.fp_data.GRF_data(i).P = structData.fp_data.GRF_data(i).P/1000;
end    
    
%% Change the forces from a forceplate allocation to a body allocation
structData.bodyForce_data = connectBody2Forces(structData);


%% Print MOT 
        printMOT(osimBodyForces,analogRate,trialName,structDataPath);


end


%%
release( hEvStore );
release( hParamStore );
release( hProcessor );
release( hTrial );
release( hServer );



end

















