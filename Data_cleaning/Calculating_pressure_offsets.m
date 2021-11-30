% Sript to convert pressures into depths and apply offset due to difference
% of glider pressure sensor and instruments

%% Load in data, clear wokrspace and add paths
clear
close all

addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\MASMMO_4\MASSMO4_Micro_Structure_Data\Processing'));

load('p_slow_com.mat'); % slow channel data from logger
load('p_fast_com.mat'); % fast channel data from logger
load('sg613_withQC.mat'); % load in raw glider data in

%% Convert pressure (dbar) into depth (m) for microstructure data

prof_min = 10; prof_max = 34; % profiles to work on
lat = 59.95; % define lattitude of location

for ii = prof_min:prof_max
    
    tic
    
    % Define fast and slow variables for processing
    eval(['slow = p_slow_com.dive' num2str(ii,'%03d') ';']); % define slow variable
    eval(['fast = p_fast_com.dive' num2str(ii,'%03d') ';']); % define fast variable
    
    % Calculate z from pressure
    depth_slow = gsw_z_from_p(slow,lat); 
    depth_fast = gsw_z_from_p(fast,lat); 
    
    % Define new variables for slow and fast depth
    eval(['z_slow.profile' num2str(ii,'%03d') '= slow;']); 
    eval(['z_fast.profile' num2str(ii,'%03d') '= fast;']);
    
    clear slow fast
    
    toc
end

% save new variables with rest of variables
save('C:\UEA\MatLab_Working_Folder\MASMMO_4\MASSMO4_Micro_Structure_Data\Processing\Processed_variables\z_slow','z_slow');
save('C:\UEA\MatLab_Working_Folder\MASMMO_4\MASSMO4_Micro_Structure_Data\Processing\Processed_variables\z_fast','z_fast');

%% Comparison between medium resolution pitch and low resolution pitch


%% Offset the depths by the the distance between the pressure sensor and the instrument
% calculate offset on the glider data
% Load in relevant data

%load('z_slow.mat'); load('pitch.mat');

% define constants

h = 0.579; % vertical distance between pressure sensor and microstructure probes
alph = -19.87; % angle from pressure sensor to microstrucutre sensors
max_prof_num = 25; % maximum profile number


% calculate the offset values and corrected depth values

[offset, corrected] = pres_correct(h, alph, z_slow, pitch, max_prof_num, 9); 


%% Apply offset to high resolution data
% Both the offset and corrected depths will be upsampled and then compared 
% to see which is the best to use 

% load in extra variables that are needed
%load('t_fast_com.mat'); load('t_slow_com.mat'); load('z_fast.mat'); 

% start with umpsampling offset values and applying them to the high
% resolution temperature

sprintf('Upsampling offset and applying')
for ii = prof_min:prof_max
    tic 
    prof = ii - 9;
    
    % profile used to decided if offset is add or subtracted from z
    dir = mod(prof,2);
    
    % high resolution depth
    eval(['z = z_fast.profile' num2str(ii,'%03d') ';'])
    
    % medium resolution offset
    eval(['os = offset.profile' num2str(ii,'%03d') ';'])
    
    % medium resolution time
    eval(['t_slow = t_slow_com.dive' num2str(ii,'%03d') ';'])
    
    % high resolution time
    eval(['t_fast = t_fast_com.dive' num2str(ii,'%03d') ';'])

    % linearly interpolate up offset
    os_fast = interp1(t_slow,os,t_fast);
    
    % apply offset
    if dir == 0 
        os_z = z + os_fast; % asscent
    else 
        os_z = z - os_fast; % descent
    end
    % save into structure
    eval(['corrected_z_fast_os_up.profile' num2str(ii,'%03d') '= os_z;']);
    
    clear os_z t_slow t_fast z os os_fast
    toc
end

% upsample the correct depth values
sprintf('Upsampling corrected values')
for ii = prof_min:prof_max
    tic
  
    % medium resolution offset
    eval(['corr_z = corrected.profile' num2str(ii,'%03d') ';'])
    
    % medium resolution time
    eval(['t_slow = t_slow_com.dive' num2str(ii,'%03d') ';'])
    
    % high resolution time
    eval(['t_fast = t_fast_com.dive' num2str(ii,'%03d') ';'])

    % linearly interpolate up offset
    corr_z_fast = interp1(t_slow,corr_z,t_fast);

    % save into structure
    eval(['corrected_z_fast_corr_up.profile' num2str(ii,'%03d') '= corr_z_fast;']);
    toc
end

%% Compare the two methods so that one can be picked 
% plot a statistically show the options using a linear regression. This in
% formation can then be used to pick one of the two methods to use
    
    profile_offset = 9;

for ii = prof_min:prof_max
    
    % define variables
    eval(['x = corrected_z_fast_corr_up.profile' num2str(ii,'%03d') ';'])
    eval(['y = corrected_z_fast_os_up.profile' num2str(ii,'%03d') ';'])

    % check for nans and remove, then make sure that the profiles are the
    % same length
    x(isnan(x)) = [];
    y(isnan(y)) = [];
    
    length_check = mod(length(x)-length(y),2);
    
    if length_check == 0
    
    else
    error('Different number of NaNs removed')
    end

    % Calculate gradient and y intercept of the lines 
    X = [ones(length(x),1) x];
    beta_1 = X\y; 
    linear_equ(ii - profile_offset,1) = beta_1(1);
    linear_equ(ii - profile_offset,2) = beta_1(2);

    clear x y X length_check

end
    
    % profile numbers to plot against
    profile_num = [prof_min:prof_max]';
    
    % calculate median and create a plotable vector
    mead_y_int = [1:25]';
    mead_y_int(:) = median(linear_equ(:,1));
    
    % plot up y_intercepts and the median value
    
    close
    
    f1 = figure('Position',[50,100,800,600],'Units','normalized');
    ax1 = axes('Position',[0.09 0.12 0.8 0.82]);
    plot(profile_num,linear_equ(:,1),'k-*','LineWidth',2);
    hold on
    plot(profile_num,mead_y_int,'r--','LineWidth',2)
        grid on
        xlim([9 35]); ylim([-5.5e-3 1e-3]);
        ylabel('Y Intercept [m]','FontSize',16)
        xlabel('Profile Number','FontSize',16)

        legend('Y Intercept [m]','Median','Location','NorthEast')

         set(f1,'Renderer','Painter')










    