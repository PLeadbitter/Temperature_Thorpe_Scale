% Sript to convert pressures into depths and apply offset due to difference
% of glider pressure sensor and instruments

%% Load in data, clear wokrspace and add paths
clear
close all

addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\MASMMO_4\Thorpe_Scaling_MS_Data'));


%% Convert pressure (dbar) into depth (m) for microstructure data

prof_min = 5; prof_max = 262; % profiles to work on
lat = 14.18; % define lattitude of location, taking the mid point
n = eurec4a_MSdata.profile; % redefine the front matter of the data file

for ii = prof_min:prof_max
    
    tic
    prof_n = ii + 0;
    % Define fast and slow variables for processing
    fast = n(ii).P_fast; % define fast variable
    
    % Calculate z from pressure
    depth_fast = gsw_z_from_p(fast,lat); 
    
    % Define new variables for slow and fast depth
    output(ii).Z_fast = depth_fast;
    
    clear slow fast depth_slow depth_fast
    
    t = toc; t = t/60;
    disp(sprintf('Converted pressure to depth of profile %d of %d in %.1f minutes',ii,prof_max,t));
end
%% Input into Eureca structure 
    for ii = 1:258
    MSdata_Eur.Raw(ii).Z_fast = output(ii+4).Z_fast; 
    end
    
    for ii = 1:258
        n = ii + 4;
        [M,I] = min(sg620_data.cons_temp(:,n),[],'omitnan');
        MSdata_Eur.Raw(ii).Z_slow = sg620_data.z(1:I);
        clear I
    end
        
    
% save new variables with rest of variables
save('C:\UEA\MatLab_Working_Folder\EURECA\Data\MSdata_Eur','MSdata_Eur');
