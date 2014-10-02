function fltData = filterDataSet(oData, filterProp, rate)
%filterDataSet()
%  Can take either a matrix or srtucture of matrices and filter them
%  according to properties found in filterProp.


Fcut =   filterProp.Fcut;
N    =   filterProp.N;
filtType = filterProp.filtType;

%% Determine filter coeffecients from the the filter properties.
if strcmp('butt',filtType)
        [a b] = butCoeff(rate, Fcut, N); 
elseif strcmp('crit',filtType)
        [a b] = critCoeff(rate, Fcut, N);
else  
        warning('Filter type incorrectly defined, using butterworth typ')
        [a b] = butCoeff(rate, Fcut, N); 
end


%% Data is a matrix (not a structure)
if  ~isstruct(oData) && ismatrix(oData)
    fltData  = filterMatrixData(oData, a, b);
end


%% Data is in a structure. Need to read 1 level down to get matrix.
if isstruct(oData) 
    % get the filednames in the structure
    fields = fieldnames(oData);
    nFields = length(fields) ;
    
    for i = 1:nFields
        % dump the field data out into a matrix
        eval(['oDataMatrix = oData.' char(fields(i)) ';'])
        % Filter the matrix data
        fData  = filterMatrixData(oDataMatrix, a, b);
        % rebuild a filtered structure
        eval(['fltData.' char(fields(i)) ' = fData;'])
    end
end 

end

function fltData  = filterMatrixData(oData, a, b)
    % get the size of the data
    [m n]   = size(oData);
    % set up some conveniance containers
    fltData = [];
    rows2beFiltered = [];
    fData = NaN(m,n);

    % for each colomn 
    for i = 1:n
        % Due to potential missing rows of data (NaNs). We need to split up
        % the rows into chunks that can be filtered individually and then
        % inserted back. 
        rows2beFiltered = splitColmn( oData(:,i) );
    
        for k = 1 : size(rows2beFiltered,1)
            r1 = rows2beFiltered(k,1);
            r2 = rows2beFiltered(k,2);
                
                if length(r1:r2)>3*4
                    fData(r1:r2,i)   = filtfilt(a, b, oData( r1:r2,i) );
                else
                    fData(r1:r2,i)   = oData( r1:r2 ,i);
                end
        end
    end
    
    fltData = [fltData fData];
end


function validFrameNum = splitColmn(data)

    validFrameNum = [];
    rowNaNs = find(~isnan(data));
    N = 3; % Required number of consecutive numbers following a first one
    x = diff(rowNaNs)==1;
    f = find([false,x']~=[x',false]);
    g = find(f(2:2:end)-f(1:2:end-1)>=N,1,'first');
    
    for u = 1 : (length(f)/2)
        validFrameNum(u,1:2) = rowNaNs( f([(u*2)-1  (u*2)]) )';
    end
end











