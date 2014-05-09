function [fltData] = filtData(data,rate,Fcut_butt,filtType,N)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here




 
     if strcmp('butt',filtType)
        dt = 1/rate;
        Fcut_butt = Fcut_butt /(sqrt(2) - 1)^(0.5/N);
        Wn = 2 * Fcut_butt * dt;
        [b, a] = butter(N, Wn);
     end
       
     if strcmp('crit',filtType)
        Ccrit = 1/sqrt(2^(1/(2*n))-1);
        Fcrit = Fcut * Ccrit;
        Wn= tan((pi*Fcrit)/Fsp);
        K1= 2*Wn;
        K2=(Wn)^2;a0 = K2 / (1 + K1 + K2);
        a1 = 2 * a0;
        a2 = a0;
        b1 = 2*a0 * (1/K2 - 1);
        b2 = 1 - (a0 + a1 + a2 + b1);
        a = [a0 a1 a2];
        b = [1 -b1 -b2];
     end

     fltData  = data;
     [nRow nCol]= size(data);
        
     
     for i = 1:nCol
         if N>1
             for passes = 1 : N-1
                 fltData(:,i)       = filtfilt(b, a, fltData(:,i));
             end
         end
                 fltData(:,i)   = filtfilt(b,a, fltData(:,i));
     end

end

