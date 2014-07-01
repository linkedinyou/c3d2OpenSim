function fltData = filterDataSet( oData, Fcut, N, filtType, rate )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


if strcmp('butt',filtType)
    [b a] = butCoeff(rate, Fcut, N); 
elseif strcmp('crit',filtType)
    [b a] = critCoeff(rate, Fcut, N);
end

if  ~isstruct(oData) && ismatrix(oData)

    [m n]   = size(oData);
    fltData = [];
    rows2beFiltered = [];
    fData = NaN(m,n);
    for i = 1:n
        % get the row range's to be filtered
        rows2beFiltered = splitColmn( oData(:,i) );
    
        for k = 1 : size(rows2beFiltered,1)
            r1 = rows2beFiltered(k,1);
            r2 = rows2beFiltered(k,2);
            if length(r1:r2)>3*N
                fData(r1:r2,i)   = filtfilt(b, a, oData( r1:r2,i) );
            else
                fData(r1:r2,i)   = oData( r1:r2 ,i);
            end
        end
    end
    
    fltData = [fltData fData];
end

if isstruct(oData) 

    fields = fieldnames(oData);
    nFields = length(fields) ;
    
    for i = 1:nFields
         % dump the field data out into a matrix
         eval(['oDataMatrix = oData.' char(fields(i)) ';'])
         [m n]  = size(oDataMatrix);
         fData  = NaN(m,n);
         % get the row range's to be filtered
         rows2beFiltered = splitColmn( oDataMatrix(:,1) );
         
         for k = 1 : size(rows2beFiltered,1)
            r1 = rows2beFiltered(k,1);
            r2 = rows2beFiltered(k,2);
            if length(r1:r2)>3*N
                fData(r1:r2,:)   = filtfilt(b, a, oDataMatrix(r1:r2,:));
            else
                fData(r1:r2,:)   = oDataMatrix(r1:r2,:);
            end
         end
        
        % rebuild a filtered structure
        eval(['fltData.' char(fields(i)) ' = fData;'])
        
    end
end 

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

function [b a] = butCoeff(rate, Fcut, N)
    % butterworth filter coeffecients
    dt = 1/rate;
    Fcut = Fcut /(sqrt(2) - 1)^(0.5/N);
    Wn = 2 * Fcut * dt;
    [b, a] = butter(N, Wn);
end

function [b a] = critCoeff(rate, Fcut, N)
    % Critically damped filter coeffecients
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
end







