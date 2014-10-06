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

%% Set Manual Values 
    
% ordered rotations
    % set of ordered rotations to be completed to take your lab frame into
    % that of OpenSim. Reminder that the 'x' axis should be the long axis.
    % If its not, you will have to complete a rotation around 'z' before
    % you rotate about 'x'
    % rotation.axis = {'z' 'x'};
    % rotation.value= [90 90];
    rotation.axis = {'x'};
    rotation.value= [90];

% Keep marker list 
    % Pass a list of markers that you would like to keep. 
    useMkrList = false;
    % keepMkrs = {'LKNE' 'RKNE' 'RASI' 'RANK'...
    %             'RTIB' 'RTOE' 'LTIB' 'LANK'...
    %             'LASI' 'RTHI' 'RHEE' 'LTHI'...
    %             'LTOE' 'LHEE' 'SACR'};    
    
% Filter properties
    filterMkr.bool     = 0;            % Filter the data (true/false)
    filterMkr.Fcut     = 16;           % Filter cut-off 
    filterMkr.N        = 4;            % Filter order
    filterMkr.filtType = 'crit';       % Filter crit

    filterFP.bool     = 1;            % Filter the data (true/false)
    filterFP.Fcut     = 40;           % Filter cut-off 
    filterFP.N        = 4;            % Filter order
    filterFP.filtType = 'crit';       % Filter crit
    
    
% Connect2bodies. 
    % Specify if you would like the forces to be connected to a 'body'.
    % This would be used to sort forces into columns that correspond to an
    % external forces file in opensim. 
    body.useBodies = 0;
    body.bodies.rFoot = {'RMT1' 'RMT2' 'RCAL' };
    body.bodies.lFoot = {'LMT1' 'LMT2' 'LCAL' };
    
%% Markers

    % Keep a subset of the Markers for Printing
    if useMkrList
        structData = keepMarkersFromList(structData,keepMkrs);    
    end

    % Replace zeros with NaNs
    structData = replaceZerosWNaNs(structData);

    % Filter Mkrs
    structData.marker_data.Markers = filterDataSet(structData.marker_data.Markers, filterMkr, structData.marker_data.Info.frequency);           

    % Rotate the structData into the coodinate system of OpenSim
    [structData.marker_data.Markers] = rotateCoordinateSys(structData.marker_data.Markers,...
                                                            rotation);

    % Print the structData into a OpenSim trc format 
    printTRC(structData.marker_data.Markers,...         % Markers
             structData.marker_data.Info.frequency,...  % video freq
             structData.marker_data.Filename);          % filename

     
%% Forces, moments and COP.      
if isempty(findstr(lower(structData.marker_data.Filename),'static')) && check4forces( structData )  

    % Number of forceplates
    nFP = length(structData.fp_data.Info);
    
    % Rotate the forceplate data (forces and moments) to the global
    structData = forces2Global(structData);    

    % Processing of the GRF structData will include taking bias out of the 
    % forceplate, zeroing below a threshold, and perhaps filtering. 
    [structData] = grfProcessing(structData, filterFP, 1, 1);

    % Calculate COP    
    structData = copCalc(structData);  

    % Rotate Forces into OpenSim Frame
    for i = 1 : nFP
        [structData.fp_data.GRF_data(i)] = rotateCoordinateSys(structData.fp_data.GRF_data(i), rotation);
    end

    % Change the forces from a forceplate allocation to a body allocation
    % structData = connectForces2Bodies(structData, body);

    % Print MOT 
    printMOT(structData)       
end

end

















