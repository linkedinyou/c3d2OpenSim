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
        % easier to read and make ajustments later.
        
        fx = structData.fp_data.GRF_data(i).F(:,1);
        fy = structData.fp_data.GRF_data(i).F(:,2);
        fz = structData.fp_data.GRF_data(i).F(:,3);
        mx = structData.fp_data.GRF_data(i).M(:,1);
        my = structData.fp_data.GRF_data(i).M(:,2);
        mz = structData.fp_data.GRF_data(i).M(:,3);

        % Dump out the forceplate X&Y coordinates
        xCorners = structData.fp_data.FP_data(i).corners(:,1);
        zCorners = structData.fp_data.FP_data(i).corners(:,3); 
        
        fpCenter = ...
        (structData.fp_data.FP_data(i).corners(1,:) +...
        structData.fp_data.FP_data(i).corners(2,:) +...
        structData.fp_data.FP_data(i).corners(3,:) +...
        structData.fp_data.FP_data(i).corners(4,:))/4;
        
        
        % get the height of the forceplate below ground
        h = mean(round(structData.fp_data.FP_data(i).corners(:,2)));
        if h == 0
            h  = 1;
        end

        % Calculate the COP from the forces and moments
        COPx = ((-h*fx + mz)./fy) + fpCenter(1);
        COPz= fpCenter(3) - ((-h*fz + mx)./fy) ;
        COPy = zeros(length(COPx),1);
              
        % Calculate the free moment (Tz) of the forceplate
        xlength = max(xCorners)-min(xCorners);
        zlength = max(zCorners)-min(zCorners);
        a  =  my;
        b  =  fz.*(COPx-xlength/2);
        c  =  (COPy-zlength/2).*fx;
        Ty =  (a-b+c)./1000;
            
        Tx = zeros(1,length(Ty))';
        Tz = Tx;
            
        % take out any Nans
        nNaN    = find(isnan(COPx));
        COPx(nNaN) = 0;
        COPy(nNaN) = 0;
        COPz(nNaN) = 0;
        Ty(nNaN)   = 0;
        Tz(nNaN)   = 0;
        Tx(nNaN)   = 0;
        
        % Plot the calculated COP vs the original COP
        hold on 
        plot(structData.fp_data.GRF_data(i).P,'k')
        plot(COPx,'b')
        plot(COPz,'r')

        % back up the original COP in the struct
        structData.fp_data.GRF_data(i).P_old = structData.fp_data.GRF_data(i).P;
        % save the processed COP to the structure
        structData.fp_data.GRF_data(i).P = [COPx COPy COPz];  
        % save the processed Z torque to the structure
        structData.fp_data.GRF_data(i).M = [Tx Ty Tz];  
         
end
       
end