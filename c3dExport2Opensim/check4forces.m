function [ outPut ] = check4forces( structData )
%check4forces checks if forces are in the structure
%   Searches throught the strucutres fieldnames to see if the forces are
%   present. 

% get the list of the names in the strucutre
fNames =  fieldnames(structData);
% pre define the output to be zero
outPut = 0;
% cycle through the fieldnames and string match at each one    
for i = 1 : length(fNames) 
 % check for the forceplate string type
 if strmatch(fNames(i),'fp_data')
    outPut = 1;
 end
end



end

