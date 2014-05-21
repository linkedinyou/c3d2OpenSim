function structData = keepMarkersFromList(structData,keepMkrs); 





mkrnames = fieldnames(structData.marker_data.Markers);

for i = 1 : length(mkrnames)
    
    ind = find(ismember(keepMkrs, mkrnames{i}));

    if isempty(ind)
        structData.marker_data.Markers = ...
                rmfield(structData.marker_data.Markers,(mkrnames{i}));
    end
    
end

end