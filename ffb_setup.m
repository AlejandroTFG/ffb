%@ UAS Formation Flight Benchmark.
% This file takes all necessary steps to set up the FFB.

% Check if necessary libraries are available:
try
   uavsimblockset_addtomatlabpath;
   % Initialize uavsimblockset library:
   uavsimblockset_init;
catch e
    disp([mfilename '>> Exception ' e.message]);
    disp([mfilename '>> Please add uavsimblockset library to Matlab path and re-run this script.']);
    return;
end

try
   trajectory_addtomatlabpath 
catch e
    disp([mfilename '>> Exception ' e.message]);
    disp([mfilename '>> Please add STRAGE library to Matlab path and re-run this script.']);
    return;
end
ffb_addtomatlabpath

% Now, either re-load the workspace generated by an earlier run or
% re-initialize:
setup = true;
if setup    
    % Configure sampling times:
    uavsim.simConfig.tsample_model = 1/100;
    uavsim.simConfig.tsample_UAV3D = findclosemultiple(1/30, uavsim.simConfig.tsample_model);
    
    % Max number of UAS, needed for some fixed-dimension signals:
    uavsim.nUAS_max = 10;
    
    % Generate trajectorie(s):
    args = {};
    args{end+1} = 60*60;
    args{end+1} = uavsim;
    benchmarkTrajectory = cachedcall(@ffb_generatebenchmarkTrajectory,args);
    
    % Run user-defined configuration script (wind, initial aircraft states etc.)
    ffb_configure;
    
    % Compute trim states and inputs:
    ffb_trim;
    ffb_generateInitialBusValues
    setupForLatexFigures;
    
    % Load baseline controllers:
    cs = load('baselineControllers.mat');
    uavsim.ap.control = cs.controllers.control;
    
    % Save generated ffb workspace:
    save('ffb_workspace.mat');
    disp([mfilename '>> ffb freshly set up, you are good to go.']);
else
    load('ffb_workspace.mat');
    disp([mfilename '>> ffb workspace loaded, you are good to go.']);
end