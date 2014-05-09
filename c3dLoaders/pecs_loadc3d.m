function pecs_loadc3d

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



[mkrStruct,trialName, dataPath,analogRate,sampleRate,firstFrame,lastFrame]  =  c3dPecsData(hTrial, true);

%% Processing code goes here

nFP = 2

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
                




%% 

release( hEvStore );
release( hParamStore );
release( hProcessor );
release( hTrial );
release( hServer );



end


