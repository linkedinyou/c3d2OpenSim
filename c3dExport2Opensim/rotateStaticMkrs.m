function [ rotmkrStruct rot1 ] = rotateStaticMkrs( mkrStruct,mkrFileInfo, bodyName )
% Rotates all Markers so that the 'Pelivs' is in same direction as 'Global'
%   Calculates angle between subject and global. Rotates subject to match
%   Global.


%% Extract Pelvis Markers

% get the parent and child mkr names
[b parentMkrs childMkrs d c]    = mkrFileSearch(mkrFileInfo,bodyName);
% parentMkrs = {'RASI' 'LASI' 'RPSI' 'LPSI'}

% Order the pelvis in the structure
    pelvisStruct                = reorderStruct(mkrStruct, parentMkrs );
  % Calculatre the position of the Sacrum using the 2 PSIS markers
    Sacr                        = (pelvisStruct(3).data + pelvisStruct(4).data)/2;
  % Add SACR to a copy of the fitered data. Just overwrite one of the
  % PSIS markers as they are not used in the analysis.
    pelvisStructCopy            = pelvisStruct;
    pelvisStructCopy(3).data    = Sacr;
    pelvisStructCopy(3).name    = 'SACR';
    pelvisNameArray(3)          = {'SACR'};
    
%% Calculate the Vector defining direction of subject (local X vector)       
    RASI = pelvisStructCopy(1).data;
    LASI = pelvisStructCopy(2).data;
    SACR = pelvisStructCopy(3).data;
    
    origin=(SACR+RASI+LASI)/3;
    x1=origin-SACR; % Line representing orgin and SACR

    for i=1:length(x1)
       xunitvector(i,:)=x1(i,:)/sqrt(dot(x1(i,:),x1(i,:))); %vector for x
    end

    localorientation=[mean(xunitvector(:,1:2)) 0]; % pure X vector
    

    globalorientation =[1 0 0];
    
    u = localorientation;
    v = globalorientation;
    CosTheta = dot(u,v)/(norm(u)*norm(v));
    ThetaInDegrees = acos(CosTheta)*180/pi;
 
%% if the y vector in the calculation is negative, the obtuse angle needs to be calculated
        % having the yvector negative means that the vector is in the
        % negative quadratic space
if localorientation(:,2)<0  % 
        rot1=360-ThetaInDegrees(1);
else
        rot1=ThetaInDegrees(1);
end

%% Apply this rotation to the markers 
RotAboutZ = [cos(rot1*pi/180),-(sin(rot1*pi/180)),0;sin(rot1*pi/180),cos(rot1*pi/180),0;0,0,1];

for ii=1:length(mkrStruct)
        v=mkrStruct(ii).data;
        data =[RotAboutZ'*v']';  %#ok<NBRAK>
        rotmkrStruct(ii).data=data;
        rotmkrStruct(ii).name=mkrStruct(ii).name;
end

end










