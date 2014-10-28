function [ filterCutOff, filterType ] = filterPropertiesHelper(filterProp, dataType )
% Helper function for reading from a filter property variable. 

nFilterProps = length(filterProp);

if nargin == 1 && nFilterProps > 2
   error('data type must be defined when filterProp is greater than 2')
end

if nFilterProps == 0
    filterCutOff = 0;
    filterType   = '';
    return
end

    % If only 1 input, then can only be filter type or fcut
    if nFilterProps == 1
         if ischar(filterProp{1})
                filterType = filterProp{1};
         elseif isnumeric(filterProp{1})
                filterCutOff     = filterProp{1};
         end
    end
    
    % If 2 inputs, then can only be a filter type and fcut
    if nFilterProps == 2
       for  i = 1 : 2
            if ischar(filterProp{i})
                    filterType = filterProp{i};
            elseif isnumeric(filterProp{i})
                    filterCutOff     = filterProp{i};
            end
       end
    end
 
    % If 3 inputs, then can only be a dataType, filter type and fcut
    if nFilterProps == 3
        if ~strmatch(dataType, filterProp{1})
            error('filterProp has been incorrectly defined. DataType (mkrs,grf,imu) must be defined in first for size 3 properties')
        end
        
        for  i = 2 : 3
            if ischar(filterProp{i})
                    filterType = filterProp{i};
            elseif isnumeric(filterProp{i})
                    filterCutOff     = filterProp{i};
            end
       end
    end
        
    % If 4 or more inputs, then more than one filter prop has been defined.
    % Search through the names and find the filter corresponding to the
    % datatype. 
    if nFilterProps > 3
       for i = 1 :  nFilterProps
             if strmatch(dataType, filterProp{i})
                 for u = i+1 : i+2
                        if ischar(filterProp{u})
                                filterType = filterProp{u};
                        elseif isnumeric(filterProp{u})
                                filterCutOff     = filterProp{u};
                                break
                        end
                 end    
             end
       end
    end
 
    
if ~exist('filterCutOff')
    filterCutOff = 16;
end

if ~exist('filterType')
    filterType = 'butt';
end

% if nargin == 1
%     display(['filtering with a ' filterType ' filter, at cutoff ' num2str(filterCutOff)])
% elseif nargin == 2
%     display(['filtering data ' dataType ' with a ' filterType ' filter, at cutoff ' num2str(filterCutOff)])
% end


end