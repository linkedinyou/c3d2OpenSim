function [processedForceStruct] = grfProcessing(forceStruct,order,Fcut,analogRate,fzChannel,zeroThreshold,filterType )
%grfProcessing() Processes raw force and moment data
%   Detailed explanation goes here

%% zero the channels
for u = 1:length(forceStruct)
    for i = 1:3
        % Force's
        % get the force channel offset
        offSet = mean(forceStruct(u).force(1:200,i));
        % apply the offset to the force channel 
        forceStruct(u).force(:,i)  = forceStruct(u).force(:,i) - offSet;
        % Moment's
        % get the force channel offset
        offSet = mean(forceStruct(u).moment(1:200,i));
        % apply the offset to the force channel 
        forceStruct(u).moment(:,i)  = forceStruct(u).moment(:,i) - offSet;
     end
end

%% zero the channels below a zeroThreshold value fo the Fz channel 
for u = 1:length(forceStruct)
        rows2zero = find(forceStruct(u).force(:,fzChannel)<zeroThreshold);

        for i = 1:3
            % Force's
            forceStruct(u).force(rows2zero,i)   = 0;
            % Moment's
            forceStruct(u).moment(rows2zero,i)  = 0;
        end
end

%% filter the plates...
%   Filter the channels using a critically damped filter
processedForceStruct = forceStruct;


if strcmpi(filterType, 'crit') % if a critically damped filter is chosen
    for u = 1:length(forceStruct)
        for i = 1:3
            % Force's
            processedForceStruct(u).force(:,i) ...
                = critDampedFiltFilt(order,...
                                     Fcut,...
                                     analogRate,...
                                     forceStruct(u).force(:,i) );
            % Moment's
            processedForceStruct(u).moment(:,i) ...
                = critDampedFiltFilt(order,...
                                     Fcut,...
                                     analogRate,...
                                     forceStruct(u).moment(:,i) );
         end
    end
    
elseif strcmpi(filterType, 'butt') % if a butterworth filter is chosen
    for u = 1:length(forceStruct)  
        for i = 1:3
            % Force's
            processedForceStruct(u).force(:,i)...
                = filterData(Fcut,...
                             order,...
                             analogRate,...
                             forceStruct(u).force(:,i));
    
            % Moment's
            processedForceStruct(u).moment(:,i)...
                = filterData(Fcut,...
                             order,...
                             analogRate,...
                             forceStruct(u).moment(:,i));
        end
    end
end

%% zero the channels below a zeroThreshold value fo the Fz channel 
for u = 1:length(processedForceStruct)
        rows2zero = find(processedForceStruct(u).force(:,fzChannel)<0.5);

        for i = 1:3
            % Force's
            processedForceStruct(u).force(rows2zero,i)   = 0;
            % Moment's
            processedForceStruct(u).moment(rows2zero,i)  = 0;
        end
end


end

