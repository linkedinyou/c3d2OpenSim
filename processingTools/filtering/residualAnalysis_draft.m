



N    =   2;

FcutG = 1:50;
plotCol = [{'b' 'g' 'b' 'c' 'y' 'm' 'w' 'k' 'g.'}];




forces = structData.fp_data.GRF_data(2).F;
moments = structData.fp_data.GRF_data(2).M;

oData = moments(:,2);

for i = 1:length(FcutG)

    [a1 b1] = butCoeff(rate,  FcutG(i), n);
    [a2 b2] = critCoeff(rate, FcutG(i), n);

    fDataButt   = filtfilt(a1, b1, oData );
    fDataCrit   = filtfilt(a2, b2, oData );
    

    hold on
    plot(oData,'r')
    plot(fDataButt,'k')
    plot(fDataCrit,'b')

    
    residButt(:,i) = oData-fDataButt;
    residCrit(:,i) = oData-fDataCrit;
    
    
    Rbutt(i) = sqrt(1/length(oData)*(sum(abs(oData-fDataButt).^2)));
    Rcritt(i) = sqrt(1/length(oData)*(sum(abs(oData-fDataCrit).^2)));

end



