% Sript to filter fast temperature data using a low pass 100 Hz filter

%% Load in data, clear wokrspace and add paths
clear
close all

addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\MASMMO_4\Thorpe_Scaling_MS_data'));

load('MSdata_M4.mat'); %MSdata = MSdata_M4; % load in temperature data post having the battery mask applied
load('SG613_MS_data.mat') % load in assocaited time variable

%% Apply filter to all the temperature data
prof_st = 1;
prof_end = 258;

% input values for the filter
fc = 100;   % cutoff frequency
fs = 512;   % sample frequency
ord = 12;   % order for filtering

% Create filtering coefficents
[coef_b,coef_a] = butter(ord,fc/(fs/2),'low');   % create low pass filter coefficents

% run data through the filter

offset = 0; % if profile number doesn't start at 1, use offset value, if not set as 0

for ii = prof_st:prof_end
    tic
    
    prof_num = ii + offset; % actually profile number
    sprintf('Filtering profile %d',prof_num)
    
    T1 = MSdata.Raw(ii).T1_cons; % FP07 1
    % time = n.profile(ii).time_elapsed_fast; % time 
    z = MSdata.Raw(ii).Z_fast; % pressure
    
    % find where in the profile there are nan values, create a variable
    % without nans in it for filtering, create index so that filtered
    % profile can have NaN values reinserted following filtering
    % FP07 1
    not_nan_1 = ~isnan(T1); 
    not_nan_loc_1 = find(not_nan_1 == 1); 
    temp_not_nan_1 = T1(not_nan_1); 
    
    
    % filter temperature
    low_pass_filt_1 = filtfilt(coef_b, coef_a, temp_not_nan_1); % FP07 1

    % create a new variable for the filtered temperature that is the length
    % of the original temperature profile
    
    %FP07 1
    filt_temp_1 = T1; filt_temp_1(:) = nan;
    filt_temp_1(not_nan_loc_1) = low_pass_filt_1;

    MSdata.Raw(ii).T1_cons_100hz = filt_temp_1;
    
    %figure
    %plot(T1,z,'k',filt_temp_1,z,'r');
    toc
end

% out from this should be a structure of temperature filtered to 100 Hz
% from each profile inputted. 

    MSdata_Eur = MSdata;
%%
save('C:\UEA\MatLab_Working_Folder\EURECA\Data\MSdata_Eur','MSdata_Eur');
