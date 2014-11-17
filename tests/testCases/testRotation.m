function testRotation




frame_position1 = [1 0 0;0 1 0;0 0 1]; 

rotation = {'x' 90};
rotated_position = rotateCoordinateSys(frame_position1, rotation);

% should be [0 0 -1]
frame_position1 = [1 0 0]
rotation = {'z' 90};
rotated_position = rotateCoordinateSys(frame_position1, rotation);





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
        if max(data.fp_data.GRF_data(i).F(:,2)) > 10
        
            [x yCol] =  max(max(data.fp_data.GRF_data(i).F));

            if yCol == 2
                display(['test_forceplate2Global :: data_' num2str(i) ':: forceplate' num2str(u) ':: passed'])
            else
                display(['test_forceplate2Global :: data_' num2str(i) ':: forceplate' num2str(u) ':: failed'])
            end                                
        end
    end
end
                                                    
                                                    
                                                    
                                                    

                                                    
                                                    
                                                    
                                                    
                                                    
end




