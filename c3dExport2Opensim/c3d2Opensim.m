function c3d2Opensim

%   Export Data from C3D Into OpenSim ready format (through vicon Pecs)
%   Author: James Dunne, Thor Besier, C.J. Donnelly, S. Hamner.  
%   Created: March 2009  Last Update: Dec 2013 
%


%% Interact with Vicon Pecs server
global  hServer;
global  hTrial;
global  hProcessor;
global  hParamStore;
global  hEvStore;
hServer     = actxserver( 'PECS.Document' );
invoke( hServer, 'Refresh' );
hTrial      = get(hServer, 'Trial' );
hProcessor  = get(hServer, 'Processor' );
hParamStore = get(hTrial, 'ParameterStore' );
hEvStore    = get(hTrial, 'EventStore' );

%% Create strucutre with all marker names in the trial 
    [mkrStruct,trialName, dataPath,analogRate,sampleRate,firstFrame,lastFrame]  =  c3dPecsData(hTrial, true)
%% Filter the data
    filtMkrStruct = filterData(12,4,sampleRate,mkrStruct);
    
    
%% Rotate the data into the coodinate system of OpenSim  %%%
     rotAxis  ='x';
     Rot1 = 90;
     [osimMkrStruct osimRotMatrix] = rotateCoordinateSys(filtMkrStruct, rotAxis, Rot1);

%% Print data into a usable reference frame to be used in OpenSim%%%
    printTRC(osimMkrStruct,sampleRate,trialName,dataPath);

%% Read the Forces, moments and Force plate dimensions from trial%%%

% Nuber of forceplates
    nFP = invoke(hTrial, 'ForcePlateCount');

if isempty(findstr(lower(trialName),'static'))   
     if nFP>0  
         
         
%% Access the C3D for forceplate data. Including force, moments and COP
    [forceStruct] = c3dPecsForceData(nFP,hTrial);
            
            
%% Processing of the GRF data includes taking bias out of the 
    % forceplate, zeroing below a threshold, and filtering. 
    Fcut      = 22;  % Cut off frequency for the forceplate
    order     = 4;   % filter order, must be an even number
    fzChannel = 3;   % The colm that Fz is on
    zeroThres = 5;   % Threshold for the Fz channel to zero under
    filterType= 'crit'; % crit = critically damped, 'butt' = butterworth

    [processedForceStruct]  ...
                = grfProcessing(forceStruct,...
                    order,...
                    Fcut,...
                    analogRate,...
                    fzChannel,...
                    zeroThres,... 
                    filterType);
            
%% Calculate COP 
    [copForceStruct] = copCalc(processedForceStruct);
            
            
%% Create a time array for the force that sync's the force and mker data
    firstAnalogTime     =(firstFrame/sampleRate)*analogRate; % first frame
    lastAnalogTime      =(lastFrame/sampleRate)*analogRate;  % Last frame
    analogArray         =(firstAnalogTime:lastAnalogTime)';  % create a time array

% Concate the data to the same time as the Markerdata 
    for u=1:length(copForceStruct)
          copForceStruct(u).force   = copForceStruct(u).force(analogArray,:);
          copForceStruct(u).moment  = copForceStruct(u).moment(analogArray,:);
          copForceStruct(u).cop     = copForceStruct(u).cop(analogArray,:);
    end

%% Change the forces from a forceplate allocation to a body allocation
    bodyNames= {'r.Foot' 'l.Foot'};
    bodyMkrs = {'RCAL' 'RMT1' 'RMT2' 'LCAL' 'LMT1' 'LMT2'};
    bodyMkrStruct = reorderStruct(mkrStruct,bodyMkrs);

    [bodyForces] = connectBody2Forces(copForceStruct,...
                                    bodyMkrStruct,...
                                    analogRate,...
                                    sampleRate,...
                                    bodyNames);

%% Rotate direction (if direction is changed)
    % Rotate into OpenSim Frame
    [osimBodyForces rotationMatrix] = rotateCoordinateSys(bodyForces, osimRotMatrix);
    % convert COP into meters rather than mm
    for i = 1:length(osimBodyForces)
            osimBodyForces(i).cop = (osimBodyForces(i).cop)/1000;
    end    

% Print MOT 
    printMOT(osimBodyForces,analogRate,trialName,dataPath);


     end
end

%%
release( hEvStore );
release( hParamStore );
release( hProcessor );
release( hTrial );
release( hServer );



end

















