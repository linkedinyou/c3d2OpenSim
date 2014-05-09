function transformForceplate2Global(structData)






% The corners of the forceplates are written in a particular order. The
% first column (corner 1) is the bottom left corner of the plate. The
% fourth column (corner 4) is the bottom right. 
%
% Using this convention, we can get the direction of the forceplate in the
% global frame. If the forceplate is NOT in the same direction as the
% global frame, we can rotate it accordingly. 


nFp = size(structData.fp_data);


for i = 1 : nFp
    
corners = structData.fp_data.FP_data(i).corners;


xDirection = (corners(:,2)-corners(:,1))';
yDirection = (corners(:,1)-corners(:,4))';

x = xDirection./abs(xDirection)
yDirection./abs(yDirection)



u = cellfun(@(M) nansum(M,1),x,'UniformOutput',false)



xGlobal = [1 0];
yGlobal = [0 1];






    
end








i = 1


eval([' fx = -structData.analog_data.Channels.Fx' num2str(i) '(:,1);']);
eval([' fy = structData.analog_data.Channels.Fy' num2str(i) '(:,1);']);
eval([' fz = -structData.analog_data.Channels.Fz' num2str(i) '(:,1);']);
        
i = 2

eval([' fx2 = -structData.analog_data.Channels.Fx' num2str(i) '(:,1);']);
eval([' fy2 = structData.analog_data.Channels.Fy' num2str(i) '(:,1);']);
eval([' fz2 = -structData.analog_data.Channels.Fz' num2str(i) '(:,1);']);



hold
plot(fx,'k')
plot(fx2,'r')

hold
plot(fy,'k')
plot(fy2,'r')

hold
plot(fz,'k')
plot(fz2,'r')










