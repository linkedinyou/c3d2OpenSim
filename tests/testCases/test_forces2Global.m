function test_forces2Global

data1 = btk_loadc3d('E:\temp\c3dfiles\Lab1.c3d', 10);
data2 = btk_loadc3d('E:\temp\c3dfiles\Lab2.c3d', 10);
data3 = btk_loadc3d('E:\temp\c3dfiles\Lab3.c3d', 10);
% 
% structData = data1

%%

data1 = forces2Global(data1);    
data2 = forces2Global(data2);    
data3 = forces2Global(data3);    





%% data 1
    for i = 1 : length(data1.fp_data.GRF_data)


        forceDiff = mean(mean(data1.fp_data.GRF_data(i).F - data1.fp_data.GRF_data(i).F_original));

    %     hold 
    %     plot(data1.fp_data.GRF_data(i).F,'k')
    %     plot(data1.fp_data.GRF_data(i).F_original,'r')

        if forceDiff > 0
             display(['test_forceplate2Global :: data_1:: forceplate' num2str(i) ':: failed'])
        elseif  forceDiff == 0
              display(['test_forceplate2Global :: data_1:: forceplate' num2str(i) ':: passed'])
        end

    end

%     data2
    for i = 1 : length(data2.fp_data.GRF_data)


        forceDiff = mean(mean(data2.fp_data.GRF_data(i).F - data2.fp_data.GRF_data(i).F_original));

    %     hold 
    %     plot(data1.fp_data.GRF_data(i).F,'k')
    %     plot(data1.fp_data.GRF_data(i).F_original,'r')

        if forceDiff > 0
             display(['test_forceplate2Global :: data_2 :: forceplate' num2str(i) ':: failed'])
        elseif  forceDiff == 0
             display(['test_forceplate2Global :: data_2:: forceplate' num2str(i) ':: passed'])
        end

    end


%  data 3

     for i = 1 : length(data2.fp_data.GRF_data)


        forceDiff = mean(mean(data2.fp_data.GRF_data(i).F - data2.fp_data.GRF_data(i).F_original));

    %     hold 
    %     plot(data1.fp_data.GRF_data(i).F,'k')
    %     plot(data1.fp_data.GRF_data(i).F_original,'r')

        if forceDiff > 0
             display(['test_forceplate2Global :: data_3 :: forceplate' num2str(i) ':: failed'])
        elseif  forceDiff == 0
             display(['test_forceplate2Global :: data_3:: forceplate' num2str(i) ':: passed'])
        end

    end






end