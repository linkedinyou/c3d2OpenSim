function [rotatedMkrStruct rotationMatrix] = rotateCoordinateSys(mkrStruct, rotAxis, Rot1)
%% rotateCoordinateSys()
%    Rotates data 

% Author: Cyril J Donnelly, James Dunne, Thor Besier.  
% Written: March, 2009. Updated: Dec,2013
    
    % If the 3D space is oriented in the usual way,
    % i.e. x going to the front, y going to the right and z going up
    % These matrices represent CLOCKWISE rotations of an object relative
    % to fixed coordinate axes, by an angle of Rot1. 
    
    
    % The direction of the rotation is as follows:
    % Rx 90 rotates the y-axis towards the z-axis (RotAboutX_90 = [1,0,0;0,0,-1;0,1,0];)
    % Ry 90 rotates the z-axis towards the x-axis (RotAboutY_90 = [0,0,1;0,1,0;-1,0,0];)
    % Rz 90 rotates the x-axis towards the y-axis (RotAboutZ_90 =
    % [0,-1,0;1,0,0;0,0,1];)
    

    
%%  Determine the coordinate to rotate around   
if     nargin < 3
 % if a vaild rotation matrix is input
    rotationMatrix = rotAxis;
   
elseif nargin == 3
 % Create roation matrices according to Rot1 (degrees)   
    RotAboutX1 = [1,0,0;0,cos(Rot1*pi/180),-(sin(Rot1*pi/180));0,sin(Rot1*pi/180),cos(Rot1*pi/180)];
    RotAboutY1 = [cos(Rot1*pi/180),0,sin(Rot1*pi/180);0,1,0;-(sin(Rot1*pi/180)),0,cos(Rot1*pi/180)];
    RotAboutZ1 = [cos(Rot1*pi/180),-(sin(Rot1*pi/180)),0;sin(Rot1*pi/180),cos(Rot1*pi/180),0;0,0,1];
  % choose which rotation matrix to use based on user input 
    if     strcmpi(rotAxis,'x') 
            rotationMatrix = RotAboutX1;
    elseif strcmpi(rotAxis,'y') 
            rotationMatrix = RotAboutY1;
    elseif strcmpi(rotAxis,'z')
            rotationMatrix = RotAboutZ1;
    end
end    
    
%% Multiple all valid arrays by the rotation matrix  
    nMkrs   = length(mkrStruct);
    fields  = fieldnames(mkrStruct(1));
    nFields = length(fields);

    for i = 1:nMkrs
         for u = 1:nFields
            % assign the strucutre field to data 
            eval(['data = mkrStruct(i).' char(fields(u)) ';' ])
            % if data is an array, rather than a string
            if ~ischar(data) 
                % Rotate the data
                  rotateData = [rotationMatrix'*data']';
                % assign the rotated datae back to field  
                 eval(['mkrStruct(i).' char(fields(u)) ' = rotateData ;' ]) ;  
            end
            
         end
    end
    
    rotatedMkrStruct = mkrStruct;
end

