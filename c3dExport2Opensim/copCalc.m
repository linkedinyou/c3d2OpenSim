function [newForceStruct] = copCalc(forceStruct)
%Calculates the COP for force and moment data from in ground forceplates
%%   
%            
% ForceDimStruct is a strucutre that has the formate such
% Cell(n,1)= XYZ coodinates of forceplate corner1 (should be four cells
% four each forceplate. n represents the row/number of forceplates in trial
%         
nFplates = length(forceStruct);

for u = 1:nFplates
        
    
    % Place these data into their variable Name. This is slower but is
        % easier to read and make ajustments later
        fx = forceStruct(u).force(:,1);
        fy = forceStruct(u).force(:,2);
        fz = forceStruct(u).force(:,3);
        mx = forceStruct(u).moment(:,1);
        my = forceStruct(u).moment(:,2);
        mz = forceStruct(u).moment(:,3);
        
        
        %% Process the grf data to get the correct cop results.
            % This is a while loop. With each cycle you will be able to
            % pick the points on the fz plot which you want to use for
            % processing. The edges of the forceplate will then be plotted
            % against the calculated COP. A input selection will appear in
            % matlab allowing the input of either 'n' or 'y'. 'n' repeats
            % the cycle while 'y' accepts the data and moves on.
            
        for i = 1:4
            xCorners(i)=forceStruct(u).corners(i,1); % create matrix with X coordinates
            yCorners(i)=forceStruct(u).corners(i,2); % create matrix with Y coordinates
        end

        % Find Closest Xcorner
        xCorner = min(xCorners);
        xlength = max(xCorners)-min(xCorners);
        % Find the Closest Y Corner
        yCorner = min(yCorners);
        ylength = max(yCorners)-min(yCorners);


        h = forceStruct(u).corners(1,3);
         if h == 0
            h  = 1;
         end
         
        COPx = (xCorner+(0.5*xlength))+((-h*fx - my)./fz);
        COPy = abs(-1*(yCorner+(0.5*ylength))+((-h*fy - mx)./fz));
        COPz = zeros(length(COPx),1);
              
        a  =  mz;
        b  =  fy.*(COPx-xlength/2);
        c  =  (COPy-ylength/2).*fx;
        Tz =  (a-b+c)./1000;
            
        Tx = zeros(1,length(Tz))';
        Ty = Tx;
            
        % take out any Nans
         for j=1:length(COPx)
            if isnan(COPx(j))==1 | isinf(COPx(j))==1 %#ok<OR2>
                COPx(j)=0;
                COPy(j)=0;
                Tz(j)=0;
            end
         end

        % save the processed COP to the structure
        forceStruct(u).cop    = [COPx COPy COPz];  
        % save the processed COP to the structure
        forceStruct(u).moment = [zeros(length(Tz),1) Tz zeros(length(Tz),1)];
         
end
        % save the processed COP to the structure
        newForceStruct = forceStruct; 
end