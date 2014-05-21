function testForceRotation

data1 = btk_loadc3d('D:\temp\c3dfiles\Lab1.c3d', 10);
data2 = btk_loadc3d('D:\temp\c3dfiles\Lab2.c3d', 10);
data3 = btk_loadc3d('D:\temp\c3dfiles\Lab3.c3d', 10);

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
            YCOP = sum(round(data.fp_data.GRF_data(u).P(:,2)) );
        end
        
        eval(['fpFrames.data' num2str(u) '= find(data.fp_data.GRF_data(u).F(:,2)>30);']);
        
        eval(['COP_store.data' num2str(u) '= data.fp_data.GRF_data(u).P;']);
        
    end
    
        [data] = copCalc_openSim(data);
        
        
        
        for u = 1 : nFP
            eval(['fpData  = data.fp_data.GRF_data(u).P(fpFrames.data' num2str(u) ',:);']);
            eval(['calData = COP_store.data' num2str(u) '(fpFrames.data' num2str(u) ',:);']);
            
            hold on 
             plot(fpData,'k')
             plot(calData,'r')
        
            diffData = rms((fpData(:,1) - calData(:,1)))
             
        
            
            
            
            
            
            

        end
        
        
        hold on 
        plot(data.fp_data.GRF_data(2).P(fpFrames.data2,:),'k')
        plot(COP_store.data2(fpFrames.data2,:),'r')
        
        
        
        y = sqrt(sum(u.*conj(u))/size(u,1))
        
        
        
    end  
        
        
        
    
    
    
    
    
    
    
    
    
    
        
    
end
                                                    
                                                    
                                                    
                                                    

                                                    
                                                    
                                                    
           


