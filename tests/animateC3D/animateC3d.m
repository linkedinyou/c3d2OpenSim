function animateC3d
% Author: Glen Lichtwark (The University of Queensland)
% Updated: 06/12/2011

keepLooping = 1;
pname = cd;

while keepLooping

    % load the c3dfile
    [fname, pname] = uigetfile('*.c3d', 'Select C3D file', pname);
    % break the loop if 'cancel' is selected
    if fname == 0
        display('c3d animation ended')
        break
    end
    [data] = btk_loadc3d([pname, fname], 10);
    
    % Define the start and end frame
    if ~isfield(data,'Start_Frame')
        data.Start_Frame = 1;
        data.End_Frame = data.marker_data.Info.NumFrames;
    end

    % define some parameters 
    nrows = data.End_Frame-data.Start_Frame+1;
    nmarkers = length(fieldnames(data.marker_data.Markers));
    data.time = (1/data.marker_data.Info.frequency:1/data.marker_data.Info.frequency:(data.End_Frame-data.Start_Frame+1)/data.marker_data.Info.frequency)';
    nframe = 1:nrows;

    % anim the trial if animation = on
    data.marker_data.First_Frame = data.Start_Frame;
    data.marker_data.Last_Frame = data.End_Frame;
    if isfield(data,'fp_data')
         btk_animate_markers(data.marker_data, data.fp_data, 5)
    else btk_animate_markers(data.marker_data)
    end
    
end


end




