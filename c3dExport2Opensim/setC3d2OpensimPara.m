function fhelp = setC3d2OpensimPara( varargin )

display(['number of parameters: ' num2str(nargin)]);



for i = 1 : nargin
    
    if ischar(varargin{i})
        if ~isempty(strfind(varargin{i}, 'help'))
         
            fhelp = varargin{i+1};
            
        end
    end
end
    
return


% ordered rotations
    % set of ordered rotations to be completed to take your lab frame into
    % that of OpenSim. 
    % rotation = [{'z' 90 'x' 90}];
    rotation = [{'x' 90 }];
    
% Keep marker list 
    % Pass a list of markers that you would like to keep. 
    useMkrList = false;
    % keepMkrs = {'LKNE' 'RKNE' 'RASI' 'RANK'...
    %             'RTIB' 'RTOE' 'LTIB' 'LANK'...
    %             'LASI' 'RTHI' 'RHEE' 'LTHI'...
    %             'LTOE' 'LHEE' 'SACR'};    
    
% Filter properties
    filterProp = {'mrks' 'crit' 16 4  'grf' 'crit' 40 4};
    
    
    
% Connect2bodies. 
    % Specify if you would like the forces to be connected to a 'body'.
    % Use this to sort forces into columns that correspond to an
    % external forces file in opensim. 
    body.useBodies = 1;
    body.order = {'rFoot' 'lFoot'};
    
    
    body.bodies.rFoot = {'rFoot' 'RMT1' 'RMT2' 'RCAL' };
    body.bodies.lFoot = {'lFoot' 'LMT1' 'LMT2' 'LCAL' };
    
    
    
% Draft input method to 
%
% setC3d2OpensimPara(path2file, ...
%             'rotation',{'x' 90}, ...
%             'filter',  {'mks' 16 'crit' 'grf' 40 'crit'},...
%             'body',    {'rFoot' 'RMT1' 'RMT2' 'RCAL'  },...
%             'body',    {'lFoot' 'LMT1' 'LMT2' 'LCAL'  })
%         
%         
% khelp = setC3d2OpensimPara('help', {'x' 90} )       

% 
% 
% setC3d2OpensimPara(1)




    
    
end