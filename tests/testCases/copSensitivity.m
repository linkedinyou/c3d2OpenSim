


% marker filter properties 
filterProp.bool     = 1;
filterProp.Fcut     = 16;
filterProp.N        = 4;
filterProp.filtType = 'crit';



Fcut = [8 9 10 12 16 20 30 40 50];
plotCol = [{'b' 'g' 'b' 'c' 'y' 'm' 'w' 'k' 'g.'}];


for i = 1: length(Fcut)
    % set the cut off frequency of the filter    
    filterProp.Fcut     = i;

    % get a fresh structure of the data   
    structData = btk_loadc3d(fullfile(pathname,filein), 10);
    
    % Rotate the forces and moments into the global frame
    structData = forces2Global(structData);    
    
    % Process the forces and moments
    %grfProcessing(structData, filterProp, zeroOffsets, thresholdChannels)
    [structData] = grfProcessing(structData, filterProp, 0, 1);
    
    % Calculate the COP andfree moment
    structData = copCalc(structData);
    
    % dump data for conveniance
    oCOP = structData.fp_data.GRF_data(2).P ;
    fCOP = structData.fp_data.GRF_data(2).PNew; 

    % plot 2d-representation of the data data COP      
    hold on
    scatter( oCOP(:,1) , oCOP(:,2),'r');
    scatter( fCOP(:,1) , fCOP(:,2), plotCol{i} );       

end










