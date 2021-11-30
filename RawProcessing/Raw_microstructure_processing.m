%%Script to process raw .p files in a usabel format DO NOT RUN AS A SINGLE
%%SCRIPT. RUN IN SUBSECTIONS!!
%% 1. Clear workspace and bring in data
% This scrip will be able to process the .p file created by the RSI logger
% on a micropod equiped seaglider and creating .mat files that can then be
% modified as normal

%% Set up work space and load data 
close all
clear

% add data and working folder to start converting
addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\EURECA\'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\EURECA\Data\MS_Data_raw'));

%% Update parameters for converting the data
% Reset the converting file
convert_info=odas_p2mat; % to get default values
convert_info.aoa=3; % angle of attack
convert_info.vehicle='sea_glider'; % vehicle type
convert_info.profiler = 'glider'; % profiler platform
convert_info.model = 'MicroPod'; % sensor package
convert_info.speed_cut_out = 0.05; % minimum vertical speed before cutting out
convert_info.hotel_file = 'p620_0001_0131_toolboxA.mat';
%convert_info.hotel_file = 'eurec4a_sg620_hotel_toolbox.mat';
%convert_info.constant_speed = 0.2;
save convert_info.mat convert_info;

%% Modify some of the parameters in quick look
% As with the previous section change some of the stock values for quick
% look, make sure to turn off as many figures as possible, especially if
% the process is a long one otherwise you'll have a mass of images on your
% screen
ql_info = quick_look;

% Plotting parameters
ql_info.plot_battery = false;
ql_info.plot_dissipation = false;
ql_info.plot_kinematics = false;
ql_info.plot_rawaccel = false;
ql_info.plot_sensors = false;
ql_info.plot_spectra = false;
ql_info.plot_spectrograms = false;


ql_info.hotel_file = 'p620_toolboxA_modelspd.mat';
ql_info.vehicle = 'sea_glider';
ql_info.profile_min_W = 0.06;
ql_info.min_duration = 1000;
ql_info.speed_cutout = 0.05;
%% Temperature calibration a) Convert a full length profile to calibrate temperature from
% Pick a profile somewhere in the middle that is full depth to act as the
% calibration dive. Don't need to do every dive for a 24 hour deployment
    ii = 15; % profile you want to use
    
   filename = ['RS',num2str(ii,'%04d'),'AU.P'];
   diss.profile = quick_look(filename,[],[],ql_info);

%% Temperature calibration b) Pull out calibration coefficents
% Extract setup file to find thermistor serial number for both thermistors
    ii = 15;

    extractfile = ['RS',num2str(ii,'%04d'),'AU.P'];
    configfilename = 'setup_Eur_015.cfg';

    configfile = extract_setupstr(extractfile, configfilename);
  
% Open .cfg file and determine the serial numbers of the two thermisotrs
    SN_1 = 'T1118'; 
  
%% Temperature calibration c) Run the calibration the two temperature channels using the SBT1 variable 
% This will give new temperature calibration coefficents

    temp_info = cal_FP07_in_situ;
    temp_info.profile_min_W = 0.1;
   
    % Calibrate each of the matfiles 
    a = 'RS0015AU.mat';
    b = 'T1_slow';
    c = 'T1';
    d = SN_1;
        [T_0, beta, lag] = cal_FP07_in_situ(a,b,c,d,temp_info);
     
    calib_coef(1,1) = T_0; calib_coef(2,1) = beta(1,1); calib_coef(3,1) = beta(1,2); calib_coef(4,1) = lag;    
        
    close all
%% Temperature calibration d)Plug new coefficents into the setup file
% Put the new coefficents into the .cfg and patch this back into the .p
% file
    
    rawdatafile = ['RS',num2str(ii,'%04d'),'AU.P'];
    configfilename = 'setup_Eur_005.cfg';
    
    patch_setupstr(rawdatafile, configfilename);
    
%% Re-Run the above section until the coeffcient values come out close to the previous ones
% Rerun Temperature calibration a - d as many times as needed to get good
% calibration values. This may take a single pass or many passes
%% Replace all the calibration coefficents with the final values

for ii = 1:9
   
    profile = ii;
    format_extractfile = 'R01B_065_%03d.p';
    format_configfilename = 'setup_R01B_065.cfg';
    
    rawfile = sprintf(format_extractfile,ii);
    configfilename = sprintf(format_configfilename,ii);
    
    patch_setupstr(rawfile, configfilename);
end

%% 9. Rerun the conversion from .p to .mat with new coefficetns

for ii = 98:131
   %tic
   % downcasts
   filename = ['RS',num2str(ii,'%04d'),'AU.P'];
   eval(['diss.profile_' num2str(ii,'%03d') ' = quick_look(filename,[],[],ql_info)'])
   
   % upcasts
   filename = ['RS',num2str(ii,'%04d'),'BU.P'];
   eval(['diss.profile_' num2str(ii,'%03d') ' = quick_look(filename,[],[],ql_info)'])
   %toc  
   clear diss
end

    %save quick_look_outputs diss

%% Calibrate the profiles

for ii = 96:131
    tic
    fprintf('Profile %d of %d',ii,131)
    temp_info = cal_FP07_in_situ;
    temp_info.profile_min_W = 0.1;
    temp_info.profile_num = 1;
    temp_info.vehicle_info.profile_dir = 'glide';
   
    % Calibrate each of the matfiles 
    a = ['RS' num2str(ii,'%04d') 'AU.mat'];
    b = 'T1_slow';
    c = 'T1';
    d = SN_1;
        [T_0, beta, lag] = cal_FP07_in_situ(a,b,c,d,temp_info);
    close all 
    %calib_coef(1,1) = T_0; calib_coef(2,1) = beta(1,1); calib_coef(3,1) = beta(1,2); calib_coef(4,1) = lag;    
    
    %temp_info.vehicle_info.profile_dir = 'up';
    
    a = ['RS' num2str(ii,'%04d') 'BU.mat'];
    b = 'T1_slow';
    c = 'T1';
    d = SN_1;
        [T_0, beta, lag] = cal_FP07_in_situ(a,b,c,d,temp_info);
    
    %calib_coef(1,2) = T_0; calib_coef(2,2) = beta(1,1); calib_coef(3,2) = beta(1,2); calib_coef(4,2) = lag;    
    close all
    
    toc    
end    
%% Save the data from each profile in a structure
    
    clear % clear any current data to make sure that nothing gets overwrittenc
    profile = 5; 
    
for ii = 3:131
    tic
    fprintf('Profile %d of %d ',ii,131)
    % downcasts
    filename = ['RS',num2str(ii,'%04d'),'AU.mat'];
    load(filename);

    % FP07 Temperature data
    eurec4a_MSdata.profile(profile).T1 = T1_fast;
    eurec4a_MSdata.profile(profile).T1_slow = T1_slow;
    eurec4a_MSdata.profile(profile).T1_dT1 = T1_dT1;
    
    %Shear data
    eurec4a_MSdata.profile(profile).Sh1 = sh1;
    
    % Hydrographic Data
    eurec4a_MSdata.profile(profile).T1_slow = T1_slow;
    eurec4a_MSdata.profile(profile).P_fast = P_fast;
    eurec4a_MSdata.profile(profile).P_slow = P_slow;
    
    %Engineering Data
    eurec4a_MSdata.profile(profile).V_bat = V_Bat;
    eurec4a_MSdata.profile(profile).Incl_T = Incl_T;
    eurec4a_MSdata.profile(profile).Incl_Y = Incl_Y;
    eurec4a_MSdata.profile(profile).Incl_X = Incl_X;
    eurec4a_MSdata.profile(profile).YD_fast = t_fast_YD;
    eurec4a_MSdata.profile(profile).YD_slow = t_slow_YD;
    eurec4a_MSdata.profile(profile).time_elapsed_fast = t_fast;
    eurec4a_MSdata.profile(profile).time_elapsed_slow = t_slow;
    eurec4a_MSdata.profile(profile).W_fast = W_fast;
    eurec4a_MSdata.profile(profile).W_slow = W_slow;
    eurec4a_MSdata.profile(profile).Start_time = time;
    eurec4a_MSdata.Profile(profile).pitch = pitch_slow;
   
    %save('C:\UEA\MatLab_Working_Folder\EURECA\Data\MS_Data_Raw\eurec4a_sg620_ms_processed\eurec4a_MSdata','eurec4a_MSdata');
    clearvars -except eurec4a_MSdata profile ii
    profile = profile + 1;
    
    % upcasts
    filename = ['RS',num2str(ii,'%04d'),'BU.mat'];
    load(filename);
    
    % FP07 Temperature data
    eurec4a_MSdata.profile(profile).T1 = T1_fast;
    eurec4a_MSdata.profile(profile).T1_slow = T1_slow;
    eurec4a_MSdata.profile(profile).T1_dT1 = T1_dT1;
    
    %Shear data
    eurec4a_MSdata.profile(profile).Sh1 = sh1;
    
    % Hydrographic Data
    eurec4a_MSdata.profile(profile).T_slow = T1_slow;
    eurec4a_MSdata.profile(profile).P_fast = P_fast;
    eurec4a_MSdata.profile(profile).P_slow = P_slow;
    
    %Engineering Data
    eurec4a_MSdata.profile(profile).V_bat = V_Bat;
    eurec4a_MSdata.profile(profile).Incl_T = Incl_T;
    eurec4a_MSdata.profile(profile).Incl_Y = Incl_Y;
    eurec4a_MSdata.profile(profile).Incl_X = Incl_X;
    eurec4a_MSdata.profile(profile).YD_fast = t_fast_YD;
    eurec4a_MSdata.profile(profile).YD_slow = t_slow_YD;
    eurec4a_MSdata.profile(profile).time_elapsed_fast = t_fast;
    eurec4a_MSdata.profile(profile).time_elapsed_slow = t_slow;
    eurec4a_MSdata.profile(profile).W_fast = W_fast;
    eurec4a_MSdata.profile(profile).W_slow = W_slow;  
    eurec4a_MSdata.profile(profile).Start_time = time;
    eurec4a_MSdata.Profile(profile).pitch = pitch_slow;
   
    %if rem(ii,100) == 0
    %save('C:\UEA\MatLab_Working_Folder\EURECA\Data\MS_Data_Raw\eurec4a_sg620_ms_processed\eurec4a_MSdata','eurec4a_MSdata');
    %if ii == 131
    save('C:\UEA\MatLab_Working_Folder\EURECA\Data\MS_Data_Raw\eurec4a_sg620_ms_processed\eurec4a_MSdata_mdlspd','eurec4a_MSdata');
    %else
        
    profile = profile + 1;    
    toc
    clearvars -except eurec4a_MSdata profile ii 
end

for ii = 1:258
    profile = ii +4;
    eurec4a_MSdata.profile(profile).pitch = eurec4a_MSdata.Profile(profile).pitch;
end