function [structData] = copCalc(structData)
%Calculates the COP for force and moment data from in ground forceplates
%%   
%            
% ForceDimStruct is a strucutre that has the formate such
% Cell(n,1)= XYZ coodinates of forceplate corner1 (should be four cells
% four each forceplate. n represents the row/number of forceplates in trial
%         

for i = 1 : length(structData.fp_data.GRF_data)
        
        % Place these data into their variable Name. This is slower but is
        % easier to read and make ajustments later
        
%         fx = structData.fp_data.GRF_data(i).F(:,1);
%         fy = structData.fp_data.GRF_data(i).F(:,2);
%         fz = structData.fp_data.GRF_data(i).F(:,3);
%         mx = structData.fp_data.GRF_data(i).M(:,1);
%         my = structData.fp_data.GRF_data(i).M(:,2);
%         mz = structData.fp_data.GRF_data(i).M(:,3);

        
        eval([' fx = -structData.analog_data.Channels.Fx' num2str(i) '(:,1);']);
        eval([' fy = structData.analog_data.Channels.Fy' num2str(i) '(:,1);']);
        eval([' fz = -structData.analog_data.Channels.Fz' num2str(i) '(:,1);']);
        eval([' mx = -structData.analog_data.Channels.Mx' num2str(i) '(:,1);']);
        eval([' my = structData.analog_data.Channels.My' num2str(i) '(:,1);']);
        eval([' mz = -structData.analog_data.Channels.Mz' num2str(i) '(:,1);']);
        
        % Dump out the forceplate X&Y coordinates
        xCorners = structData.fp_data.FP_data(i).corners(1,:);
        yCorners = structData.fp_data.FP_data(i).corners(2,:); 
        
        % Find Closest Xcorner
        xCorner = min(xCorners);
        xlength = max(xCorners)-min(xCorners);
        % Find the Closest Y Corner
        yCorner = min(yCorners);
        ylength = max(yCorners)-min(yCorners);

        % get the height of the forceplate below ground
        h = structData.fp_data.FP_data(i).corners(3,1);
        if h == 0
            h  = 1;
        end

        % Calculate the COP from the forces and moments
        COPx = (xCorner+(0.5*xlength))+((-h*fx - my)./fz);
        COPy = abs(-1*(yCorner+(0.5*ylength))+((-h*fy - mx)./fz));
        COPz = zeros(length(COPx),1);
              
        % Calculate the free moment (Tz) of the forceplate
        a  =  mz;
        b  =  fy.*(COPx-xlength/2);
        c  =  (COPy-ylength/2).*fx;
        Tz =  (a-b+c)./1000;
            
        Tx = zeros(1,length(Tz))';
        Ty = Tx;
            
        % take out any Nans
        nNaN    = find(isnan(COPx));
        COPx(nNaN) = 0;
        COPy(nNaN) = 0;
        Tz(nNaN)   = 0;

        % Plot the calculated COP vs the original COP
        hold on 
        plot(structData.fp_data.GRF_data(i).P,'k')
        plot(COPy,'r')
        plot(COPx,'r')

        % save the processed COP to the structure
        structData.fp_data.GRF_data(i).P(:,1:2) = [COPx COPy];  
         
end
       
end