function [a b] = butCoeff(rate, Fcut, n)
%butterworth filter coeffecients
% from "Design and responses of butterworth and critically damped digital
% filters' by DGE Robertson and JJ Dowling (2003)
% This outputs coefficients for a 2nd order filter given the number of
% passes of the filter over the data. A zero-lag filter will pass over the
% data once in the forward firection and once in the backward direction.
% Doubling the order. 
    
    % filtfilt uses a a duaal pass method, once forward, once in reverse. 
    % so the minimum passes is 2. 
    if nargin < 3
        n = 2;                          % number of passes by the filter
    end

    % Adjust the number of Fcut based on the number of passes. 
    Cbtw = 1 / nthroot( (2^(1/n)-1) , 4);
    Fcut = Fcut * Cbtw;
        
    % correct the cut-off based on the number of passesCbtw = 1 / nthroot( (2^(1/n)-1) , 4);
    Fcut = Fcut * Cbtw;
        
    % Adjust the corrected cut-off
    Wn = tan((pi*Fcut)/rate  ); 
    
    K1= sqrt(2) * Wn;
    K2= (Wn)^2;
    
    %% a
    a0 = K2 / (1 + K1 + K2);
    a1 = 2 * a0;
    a2 = a0;
    
    %% b
    b1 = 2*a0 * (1/K2 - 1);
    b2 = 1 - (a0 + a1 + a2 + b1);

    a = [a0 a1 a2];
    b = [1 -b1 -b2];
    
end

