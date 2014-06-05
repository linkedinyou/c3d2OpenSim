function structData = replaceZerosWNaNs(structData)
%% replaceZerosWNaNs()
%   btk outputs marker frames with no vales as zero's. In openSim, zero's
%   are interpreted literally
%    Replaces zero values of marker data with NaN's

mkrNames = fieldnames(structData.marker_data.Markers);
nMkrs    = length(mkrNames);

for i = 1 : nMkrs
    % Find when the rows are zero
    zeroFrames = find(round(structData.marker_data.Markers.(mkrNames{i})(:,1)) == 0);
    % For those rows, replace with nan's
    structData.marker_data.Markers.(mkrNames{i})(zeroFrames,:) = NaN;
end






end