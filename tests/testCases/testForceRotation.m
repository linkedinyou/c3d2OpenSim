function testForceRotation

warning('on')

data1 = btk_loadc3d('E:\temp\c3dfiles\Lab1.c3d', 10);
data2 = btk_loadc3d('E:\temp\c3dfiles\Lab2.c3d', 10);
data3 = btk_loadc3d('E:\temp\c3dfiles\Lab3.c3d', 10);

%% data 1 

for i = 1 : 3

 eval(['data = data' num2str(i) ';'    ]);
    
 if     i == 1
     rotation.axis = {'x'};
     rotation.value= [90];
 elseif i == 2
     rotation.axis = {'z' 'x'};
     rotation.value= [90 90];
 elseif i == 3
     rotation.axis = {'z' 'x'};
     rotation.value= [90 90];    
 end
 
 
 
    nFP = length(data.fp_data.Info); 
 
    data = forces2Global(data);     

    for u = 1 : nFP
        % Forces
        [data.fp_data.GRF_data(u)] = ...
                        rotateCoordinateSys(data.fp_data.GRF_data(u),...
                                            rotation);
        % corners
        [data.fp_data.FP_data(u).corners] = ...
                        rotateCoordinateSys(data.fp_data.FP_data(u).corners,...
                                            rotation);
                                        
        % should now be in the opensim frame
        if max(data.fp_data.GRF_data(u).F(:,2)) > 30
        
            % coloumn 2 should be the vertical grf
            [x yCol] =  max(max(data.fp_data.GRF_data(u).F));

            % coloumn 2 should have 0 COP 
            YCOP = sum(round(data.fp_data.GRF_data(u).P(:,2)) )
            
            
            if yCol == 2 && YCOP == 0
                display(['test_forceplate2Global :: data_' num2str(i) ':: forceplate' num2str(u) ':: passed'])
            else
                display(['test_forceplate2Global :: data_' num2str(i) ':: forceplate' num2str(u) ':: failed'])
            end                                
        end
    end  
        
        
        
        
    end
end
                                                    
                                                    
                                                    
                                                    

                                                    
                                                    
                                                    
                                                    
                                                    
end




