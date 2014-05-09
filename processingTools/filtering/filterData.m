function [ FData ] = filterData(oData, Fcut, rate, filtType, N)
%   Runs a buttterworth filter on the oData
%   Fcut_butt =     Cut off Frequency
%   Rate      =     Sampling frquency of the oData
%   oData      =     MxN matrix to be filtered



% Check to see if data is a matrix 
if  isstruct(oData) 
    % iterate over the fields to filter
    fields = fieldnames(oData);
    nFields = length(fields) ;
    FData  = oData;
    for i = 1:nFields
            % dump the field data out into a matrix
            eval(['oDataMatrix = oData.' char(fields(i)) ';'])
            % filter the data
            [fData] = filtData(oDataMatrix, rate, Fcut, filtType, N);
            % rebuild a filtered structure
            eval(['FData.' char(fields(i)) ' = fData;'])
    end
    
    

elseif ~isstruct(oData) && ismatrix(oData)
    % Filter the data matrix
    [FData] = filtData(oData, rate,Fcut, filtType, N );
    
else
    error('Data input type for filter is not correct. Check input data is a matrix or structure')
    
end
    





end
    





