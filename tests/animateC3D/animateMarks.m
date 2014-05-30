function animateMarks
% Author: Glen Lichtwark (The University of Queensland)
% Updated: 06/12/2011
    [fname, pname] = uigetfile('*.c3d', 'Select C3D file');
     % load the c3dfile
        [data] = btk_loadc3d([pname, fname], 10);
        anim = 'on';
    %%
    % if the mass, height and name aren't present then presribe - it is
    % preferrable to have these defined in the data structure before running 
    % this function - btk_loadc3d should try and do this for vicon data

    %% define the start and end frame for analysis as first and last frame unless 
    % this has already been done to change the analysed frames
    if ~isfield(data,'Start_Frame')
        data.Start_Frame = 1;
        data.End_Frame = data.marker_data.Info.NumFrames;
    end

    %%
    % define some parameters 
    nrows = data.End_Frame-data.Start_Frame+1;
    nmarkers = length(fieldnames(data.marker_data.Markers));

    data.time = (1/data.marker_data.Info.frequency:1/data.marker_data.Info.frequency:(data.End_Frame-data.Start_Frame+1)/data.marker_data.Info.frequency)';

    nframe = 1:nrows;

    % anim the trial if animation = on
    if strcmp(anim,'on')
        data.marker_data.First_Frame = data.Start_Frame;
        data.marker_data.Last_Frame = data.End_Frame;
        if isfield(data,'fp_data')
            btk_animate_markers(data.marker_data, data.fp_data, 5)
        else btk_animate_markers(data.marker_data)
        end
    end
end




