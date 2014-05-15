function [ FData ] = filterData(oData, Fcut, N, filtType, rate)
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
            [fData] = filtfiltData(oDataMatrix,Fcut, N, filtType, rate);
            % rebuild a filtered structure
            eval(['FData.' char(fields(i)) ' = fData;'])
    end
    
    

elseif ~isstruct(oData) && ismatrix(oData)
    % Filter the data matrix
    [FData] = filtfiltData(oData,Fcut, N, filtType, rate);
    
else
    error('Data input type for filter is not correct. Check input data is a matrix or struct')
    
end
    
end


function [fltData] = filtfiltData(data,Fcut, N, filtType, rate)


 

    if strcmp('crit',filtType)
        Ccrit = 1/sqrt(2^(1/(2*N))-1);
        Fcrit = Fcut * Ccrit;
        Wn= tan((pi*Fcrit)/Fcut);
        K1= 2*Wn;
        K2=(Wn)^2;a0 = K2 / (1 + K1 + K2);
        a1 = 2 * a0;
        a2 = a0;
        b1 = 2*a0 * (1/K2 - 1);
        b2 = 1 - (a0 + a1 + a2 + b1);
        a = [a0 a1 a2];
        b = [1 -b1 -b2];
        
        
       fltData  = data;
       [nRow nCol]= size(data);
       for i = 1:nCol 
           fltData(:,i)   = filtfilt(b, a, fltData(:,i));
       end
       
    else
        strcmp('butt',filtType)
        dt = 1/rate;
        Fcut = Fcut /(sqrt(2) - 1)^(0.5/N);
        Wn = 2 * Fcut * dt;
        [b, a] = butter(N, Wn);
        
        fltData  = data;
        [nRow nCol]= size(data);
       for i = 1:nCol 
           fltData(:,i)   = filtfilt(b, a, fltData(:,i));
       end
        
        
    end   
     

     

end
    





