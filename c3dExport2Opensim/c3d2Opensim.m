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

%% Set some manual values 
    % set of ordered rotations to be completed to take your lab frame into
    % that of OpenSim. Reminder that the 'x' axis should be the long axis.
    % If its not, you will have to complete a rotation around 'z' before
    % you rotate about 'x'
    % rotation.axis = {'z' 'x'};
    % rotation.value= [90 90];
         
    rotation.axis = {'x'};
    rotation.value= [90];
    
    % set a threshold to zero under
    zeroThres = 4;

    % Either the number of markers on 1 foot or the names of the markers
    % footMks = {'RCAL' 'RMT1' 'RMT2' 'LCAL' 'LMT1' 'LMT2'};
    footMks = 3;

%% Keep marker list 
 % Pass a list of markers that you would like to keep. 
 % ie keepMkrs = {'RPSI' 'LPSI' 'LASI' 'RASI' ....
% 
% keepMkrs = {'LKNE' 'RKNE' 'RASI' 'RANK'...
%             'RTIB' 'RTOE' 'LTIB' 'LANK'...
%             'LASI' 'RTHI' 'RHEE' 'LTHI'...
%             'LTOE' 'LHEE' 'SACR'};
%  
% structData = keepMarkersFromList(structData,keepMkrs);    
%     
%% Replace zeros with NaNs
    % replaces marker values == 0, with NaN's
structData = replaceZerosWNaNs(structData);
    
    
%% Rotate the structData into the coodinate system of OpenSim
% set of ordered rotations to be completed

[structData.marker_data.Markers] = rotateCoordinateSys(structData.marker_data.Markers,...
                                                        rotation);
 
%% Print the structData into a OpenSim trc format 
printTRC(structData.marker_data.Markers,...         % Markers
         structData.marker_data.Info.frequency,...  % video freq
         structData.marker_data.Filename);          % filename

%% Read the Forces, moments and Force plate dimensions from trial
%    Check first to see if the trial is not a static and/or if it has force
%    data in it at all.
if isempty(findstr(lower(structData.marker_data.Filename),'static'))   
if check4forces( structData )

    
%% Number of forceplates
    nFP = length(structData.fp_data.Info);
    
%%  
    structData = forces2Global(structData);    
    
%% Rotate into OpenSim Frame

for i = 1 : nFP
    % Forces
    [structData.fp_data.GRF_data(i)] = ...
                    rotateCoordinateSys(structData.fp_data.GRF_data(i),...
                                        rotation);
                                    
    [structData.fp_data.FP_data(i).corners] = ...
                    rotateCoordinateSys(structData.fp_data.FP_data(i).corners,...
                                        rotation);
end

%% Processing of the GRF structData will include taking bias out of the 
%   forceplate, zeroing below a threshold, and perhaps filtering. 
   [structData] = grfProcessing(structData,zeroThres);
 

%% Calculate COP 
    structData = copCalc_openSim(structData);

    
%% Change the forces from a forceplate allocation to a body allocation
% structData.fp_data.GRF_data = connectForces2Bodies(structData, footMks);

%% Convert COP into meters rather than mm
for i = 1 : length(structData.fp_data.GRF_data)
    structData.fp_data.GRF_data(i).P = structData.fp_data.GRF_data(i).P/1000;
end    
   
%% Print MOT 
printMOT(structData)       
        
end
end
end

















