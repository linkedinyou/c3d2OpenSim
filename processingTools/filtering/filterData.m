function [ fdata ] = filterData(Fcut_butt,order,rate,data)
%   Runs a buttterworth filter on the data
%   Fcut_butt =     Cut off Frequency
%   Rate      =     Sampling frquency of the data
%   data      =     MxN matrix to be filtered

dt = 1/rate;
Fcut_butt = Fcut_butt /(sqrt(2) - 1)^(0.5/order);
Wn = 2 * Fcut_butt * dt;
[b, a] = butter(order, Wn);

    if isstruct(data)
        
        nStructs   = length(data);
        if nStructs == 1
            fields  = fieldnames(data(1));
            nFields = length(fields);
        end
        
       for i = 1:nFields
            % Dump the data into a matrix
            eval(['Fdata = data.' char(fields(i)) ';' ]);
            % Analysis the matrix for NaN values and find valid rows
            vRows = find(~isnan(Fdata(:,1)) == 1)
            % Create a subset array with the valid data
            vData = Fdata(vRows,:)
            % Filter the data 
            filtData =  filtfilt(b, a, vData);
            % Store the data back in a matrix 
            Fdata(vRows, :) = filtData;
            % create a filtered marker structure
            eval(['fdata.' char(fields(i)) '= Fdata;' ]);
       end

    else

        [m n] = size(data);

        if n>1
            for ii=1:n
                fdata(:,ii) = filtfilt(b, a, data(:,ii));
            end
        elseif n==1
                fdata = filtfilt(b, a, data); %Tranpose Rows and Columns in Data
        end
    end
end
