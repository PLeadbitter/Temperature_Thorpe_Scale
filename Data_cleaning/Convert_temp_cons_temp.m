% Sript to convert fast thermistor and seabird thermistor temperatures to
% conservative temperature

%% Load in data, clear wokrspace and add paths
clear
close all

addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\MASMMO_4\Thorpe_Scaling_MS_data'));


load('MSdata_M4.mat'); MSdata = MSdata_M4; clear MSdata_M4
load('SG613_MASSMO4_2m_binned.mat'); sg613_withQC = gridded_data; clear gridded_data
%load('adjusted_p_str.mat');
%load('fast_temp.mat'); T = fast_temp; clear fast_temp
load('SG613_MS_data.mat');
%% Create fast salinity variables for calculting conservative temperature
prof_min = 1; prof_max = 258; % profiles to work on
n = sg620_data; % define the string for the data 

for ii = prof_min:prof_max
    tic
    prof_off = ii + 4; 
    % Define fast and slow variables for processing
    % Temperature, conductivity and absolute salinity
    SBT = n.temp(~isnan(n.abs_salinity(:,prof_off)),prof_off);
    SBC = n.abs_salinity(~isnan(n.abs_salinity(:,prof_off)),prof_off);
    % SBS = n.salinity(~isnan(n.abs_salinity(:,ii)),ii);
     
    % Pressure variables 
    P_slow = n.pressure(~isnan(n.abs_salinity(:,prof_off)),prof_off);
    P_fast = eurec4a_MSdata.profile(prof_off).P_fast;
    
    % Calculate z from pressure if using conductivity
     Sal.profile(ii).Prac_Sal = gsw_SP_from_SA(SBC,P_slow,-57,14); % calculate salinity 
    
    % Calculate z from pressure if using absolute salinity
    % Sal.profile(ii).Prac_Sal = gsw_SP_from_SA(SBS,P_slow); % calculate salinity 
    
    % Upsample the practical salinity
    Sal.profile(ii).Prac_Sal_fast = interp1(P_slow,Sal.profile(ii).Prac_Sal,P_fast); % upsample salinity
   
    t = toc; t = t/60;
    disp(sprintf('Converted conductivty to practical salinity profile %d of %d in %.1f minutes',ii,prof_max,t));

    clear SBT SBC P_fast P_slow
end

%% Convert in situ temperature to conservative temperature for microstructure data

for ii = prof_min:prof_max
    
    tic
    prof_off = ii + 4; 
    % Define fast and slow variables for processing
    FP07_1 = eurec4a_MSdata.profile(prof_off).T1; % FP07 temp
    SBT = n.temp(~isnan(n.abs_salinity(:,prof_off)),prof_off);   % Seabird temp
    Prac_sal = Sal.profile(ii).Prac_Sal;        % seabird sal
    Prac_sal_fast = Sal.profile(ii).Prac_Sal_fast;  % seabird sal for FP07 
    P_slow = n.pressure(~isnan(n.abs_salinity(:,prof_off)),prof_off); % slow pressure
    P_fast = eurec4a_MSdata.profile(prof_off).P_fast; % fast pressure
    
    % Conservative temperature from in situ
    cons_temp_FP07_1 = gsw_CT_from_t(Prac_sal_fast,FP07_1,P_fast); 
    %cons_temp_FP07_1 = gsw_CT_from_pt(Prac_sal_fast,FP07_1); 
    cons_temp_SBT = gsw_CT_from_t(Prac_sal,SBT,P_slow);
    
    % Define new variables for slow and fast depth
    MSdata.Raw(ii).T1_cons = cons_temp_FP07_1;
    MSdata.Raw(ii).SBT_cons = cons_temp_SBT;
    
    MSdata.Raw(ii).SBT_PS = Prac_sal;
    MSdata.Raw(ii).SBT_PS_fast = Prac_sal_fast;
    
    clearvars -except Sal MSdata prof_max prof_min ii n eurec4a_MSdata MSdata_Eur
    
    t = toc; t = t/60;
    disp(sprintf('Converted insitu temperature to conservative temperature profile %d of %d in %.1f minutes',ii,prof_max,t));

end
    MSdata_Eur = MSdata;

%%
% save new variables with rest of variables
save('C:\UEA\MatLab_Working_Folder\EURECA\Data\MSdata_Eur','MSdata_Eur');