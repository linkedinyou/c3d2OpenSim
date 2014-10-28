function c3d2Opensim(varargin)
% c3d2OpenSim()
% 
% Function to export struture structData created from btk_btkloadc3d()
% to .trc (marker strutData) and .mot (force structData).  
%
% Input - structData - structured data which may contain fields for;
%           marker_data - any calculated data from the reconstructed C3D
%               file including marker trajectories and any calculated  
%               angles, moments, powers or GRF data
%           analog_data - analog data (often sampled at a higher rate)often
%               force plate data and EMG data that might be collected.
%           grf_data - structure with the position magnitude of ground 
%               reaction force vector and moments relative to the global
%               cooridinate system
%           fp_info - structure with the force outputs from the force 
%               plates including the ground reaction wrench (force vector 
%               calculated in the global axis frame) and relevant 
%               sampling and forceplate position information             
%           sub_info - extra data from the C3D file if it exists, inlcuding
%               height and weight etc.
%
% Output - trialName.trc - a trc file containing marker positions using a 
%                          "Y is up" right handed global frame
%          trialName.mot - a mot file containing forces, COP and moment
          
% 
% [rotation, filterProp, body, keepMkrs] = c3d2Opensim(path2file, ...
%             'rotation',{'z' 120}, ...
%             'filter',  {'mks' 2 'butt' 'grf' 15 'butt'},...
%             'mrkList', {'LTH1' 'LTH2'},...
%             'body',    body)
           
% Author: James Dunne, Thor Besier, C.J. Donnelly, S. Hamner.  
% Created: March 2009  Last Update: Oct 2014 

%% create variable from input arguments. 
    
for i = 1 : nargin
     % if input string is rotation, next value will be a rotation cell array
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'c3dFilePath'))
               c3dFilePath = varargin{i+1};
        end
    end
    % if input string is rotation, next value will be a rotation cell array
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'rotation'))
               rotation = varargin{i+1};
        end
    end
    % if input string is filter, next value will be a filter cell array
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'filter'))
               filterProp = varargin{i+1};
        end
    end
    % if input string is body, next value will be a body structure
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'body'))
               body = varargin{i+1};
               body.useBodies = 1;
        end
    end
    % if input string is mrkList, next value will be a array of strings
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'mrkList'))
               keepMkrs = varargin{i+1};
               useMkrList = 1;
        end
    end
end

%% Read the c3d file

if nargin == 0
        [filein, pathname] = uigetfile({'*.c3d','C3D file'}, 'C3D data file...');
        structData = btk_loadc3d(fullfile(pathname,filein), 10);
elseif nargin >= 1
        % structData is a path to a c3d file.
        [PATH,NAME,EXT] = fileparts(c3dFilePath);
        display(['processing trial ' NAME])
        structData = btk_loadc3d(fullfile(PATH,[NAME EXT]), 10);
end

%% If input arguments dont exist, create default properties

% ordered rotations
if ~exist('rotation')    
    rotation = [{'x' 90 }];
end

% keep marker list
if ~exist('keepMkrs')
    useMkrList = false;
end

% filter properties
if ~exist('filterProp')
    filterProp = {};
end

% definition of bodies. 
if ~exist('body')
    body.useBodies = 0;
end
    
    
%% Markers

    % Keep a subset of the Markers for Printing
    if useMkrList
        structData = keepMarkersFromList(structData,keepMkrs);    
    end

    % Replace zeros with NaNs
    structData = replaceZerosWNaNs(structData);

    % Filter Mkrs
    structData.marker_data.Markers = filterDataSet(structData.marker_data.Markers,...
                                                       filterProp,...
                                                       structData.marker_data.Info.frequency,...
                                                       'mrks');           
    
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
    [structData] = grfProcessing(structData, filterProp, 1, 1);

    % Calculate COP    
    structData = copCalc(structData);  

    % Rotate Forces into OpenSim Frame
    for i = 1 : nFP
        [structData.fp_data.GRF_data(i)] = rotateCoordinateSys(structData.fp_data.GRF_data(i), rotation);
    end

    % Change the forces from a forceplate allocation to a body allocation
    structData.fp_data.GRF_data = connectForces2Bodies(structData, body);

    % Print MOT 
    printMOT(structData)       
end

end

















