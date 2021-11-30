% Script for calculting the Thorpe Length scale of temperature data from
% FP07 thermistors. Designed to be used with both profilers and gliders
%% Clear up the workspace and load in data
clear  
close all

% add relevant paths for data, functions and toolboxes
addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\EURECA'));
 
load MSdata_Eur.mat; MSdata = MSdata_Eur; clear MSdata_Eur
%load SG613_MS_data.mat;
fldnm = 'Eur';

disp(sprintf('Data Loaded'));

prof_offset = 0; % in the case of the micropod system the first profile isn't always profile 1, use to offset any loops 
prof_st = 1; prof_end = 258; % profiles in the data set
%% Calculate reordered temperature, thorpe fluctuation and thorpe length
% here the FP07 temperature is reordered and the thorpe fluctuation and
% thorpe length are calculated and then the thorpe fluctuations are 
% summed so that the over turns can be determined from them. 

% create variable that is the length of the number of profiles and amd
% assign each profile either a 1 for a downcast or a 0 for an upcast
% (gliders or surface profilers only)
prof_dir = zeros(1,prof_end); prof_dir(:) = 1; 

cut_off = 0.00000001; % value below which cummulative sum will convert to a zero value

for ii = prof_st:prof_end
    tic
    
    prof_num = ii + prof_offset; % apply profile offset
    
    T1 = MSdata.Binned(ii).T; % load in temperature from ms structure
    z = MSdata.Binned(ii).Z; % load in asociated depth from ms structure
    
    dir = prof_dir(ii);
    [t_d_1,reot_1,t_tf_1] = temp_reorder(T1,z,prof_dir(1)); % calculate Thorpe displacement (t_d), Thrope fluctuation (t_f) and reordered temperature (reot)
    
    cumt_d_1 = cumsum(t_d_1,'omitnan'); % calculate the cummulative sum of the thorpe displacements
    
    cumt_d_1 = -cumt_d_1; % reverse direction of cummulative sum step if needed. Needs to be positive for cutt_off to work
    
    % Due to small variations over turns do not always collapse back onto 
    % zero values so set a cut of threshold as an assume value for
    % overturns this value you should be set after processing a profile to
    % see what the minimum is likely to be.  
    indices_1 = find(cumt_d_1 < cut_off); cumt_d_1(indices_1) = 0;
    
    % save variables to the ms structure
    MSdata.Binned(ii).T_D_1 = t_d_1; 
    MSdata.Binned(ii).reoT_1 = reot_1; 
    MSdata.Binned(ii).T_TF_1 = t_tf_1; 
    MSdata.Binned(ii).cumT_D_1 = cumt_d_1; 
    
    t = toc; t = t/60;
    disp(sprintf('Reordered and summed profile %d of %d in %.1f minutes',prof_num,prof_end,t));
    
    clear t T1 z cumt_d_1 t_d_1 reot_1 t_tf_1 
end

%% Determine over turns for each profile
% Here using the idea that that cumulative sum will collapse onto zero if
% there is an overturn. This is then used as an index for the period over
% wich the thorpe scale calculations will be conducted

for ii = prof_st:prof_end
    tic
    prof_num  = ii + prof_offset;
    
    cumt_d_1 = MSdata.Binned(ii).cumT_D_1;
    
    ot_no_1 = find_ot(cumt_d_1);
    
    MSdata.Binned(ii).ot_no_1 = ot_no_1;
    
    for jj = 1:max(ot_no_1)
        idx = (ot_no_1 == jj); % overturn index
            height_range = MSdata.Binned(ii).Z(idx);
            ot_height_1(jj) = max(height_range) - min(height_range);
            Z_mid_1(jj) =  (max(height_range) + min(height_range))/2;
            clear idx height_range
    end
    
    MSdata.Binned(ii).ot_height_1 = ot_height_1; MSdata.Binned(ii).ot_Z_1 = Z_mid_1;
    
    clear ot_no_1 cumt_d_1 ot_height_1 Z_mid_1
    t = toc; t= t/60;
    
    disp(sprintf('Overturns determined for profiles %d of %d in %.1f minutes',prof_num,prof_end,t));
end
%% Combine together overturns that are smaller than 2m
% If an overturn is smaller than 2m and within 1m of their nearest
% neighbour combine into a single overturning region

for ii = prof_st:prof_end
    tic
    prof_num  = ii + prof_offset;
    % Set overturn constants
    min_ot_size = 2;
    min_spacing = 1;
    max_r_size = 2;
    
    %FP07 1
    ot_no = MSdata.Binned(ii).ot_no_1;               % Overturn numbers
    ot_height = MSdata.Binned(ii).ot_height_1;       % Height of overturns
    ot_z = -MSdata.Binned(ii).ot_Z_1;                % mid point of overturns
    
    ot_r = find_ot_r(ot_no,ot_height,ot_z,min_ot_size,min_spacing,max_r_size);
    
    MSdata.Binned(ii).ot_r_no_1 = ot_r;
    
    clear ot_no ot_height ot_z ot_r
    
    t = toc; t= t/60;
    disp(sprintf('Overturning regions defined for profile %d of %d in %.1f minutes',prof_num,prof_end,t));
end
%% Calculate LT

for ii = prof_st:prof_end
    tic
    prof_num = ii + prof_offset;
    
    disp(sprintf('Calculating LT for profile %d',prof_num));
    
    ot_r_no_1 = MSdata.Binned(ii).ot_r_no_1; 
    t_d_1 = MSdata.Binned(ii).T_D_1; 
    yd = MSdata.Binned(ii).yd;
    z = -MSdata.Binned(ii).Z;
    
    [lt_mid_1,l_t_whole_1,z_mid_1,yd_mid_1] = calc_LT(ot_r_no_1,t_d_1,yd,z);

    MSdata.Binned(ii).L_T_1 = lt_mid_1; 
    MSdata.Binned(ii).L_T_whole_1 = l_t_whole_1;
    MSdata.Binned(ii).ot_Z_1 = z_mid_1; 
    MSdata.Binned(ii).ot_YD_1 = yd_mid_1;
    
    clear ot_no_1 t_d_1 yd z l_t_whole_1 lt_mid_1 z_mid_1 yd_mid_1
    
    t = toc; t = t/60;
    disp(sprintf('Calculated Thorpe Length for profile %d of %d in %.1f minutes',prof_num,prof_end,t));

end

%% Plot up variables for a sanity check
% use this section to plot up temperature, reordered temperature, thorpe
% fluctuation, thorpe displacement and cumulative thorpe displacement to
% sanity check the values that you are getting out, do the thorpe
% fluctuations and displacemtns matach in region, are there any spurious
% values in one of the two channels that isn't there in the other one etc.

close all
path = ['C:\UEA\MatLab_Working_Folder\EURECA\Thorpe_Scaling\LT_checks'];
for ii = prof_st:prof_end
    cumtd_1 = MSdata.Binned(ii).cumT_D_1; 
    t_tf_1 = MSdata.Binned(ii).T_TF_1; 
    t_d_1 = MSdata.Binned(ii).T_D_1; 
    reoT_1 = MSdata.Binned(ii).reoT_1; 
    TL_1 = MSdata.Binned(ii).L_T_whole_1; 
    t1 = MSdata.Binned(ii).T;
    z = MSdata.Binned(ii).Z;
   
f1 = figure('Position',[50,100,1200,800],'Units','normalized');
subplot(1,5,1)
plot(t1,z,'b',reoT_1,z,'k')
ylim([-1000 0])
title('T1, REOT1')
ylabel('Z [m]','Fontsize',14)
xlabel('\Theta [^\circC]','FontSize',14)
grid on
%text(1,-50,'i)','Color','k','Fontsize',12)
legend('T1','FP07_1','Location','SouthEast')

subplot(1,5,2)
plot(t_tf_1,z,'k')
ylim([-1000 0])
title('TF1, TF2')
xlabel('T_F [^\circC]','FontSize',14)
grid on
%text(-0.09,-50,'iii)','Color','k','Fontsize',12)

subplot(1,5,3)
plot(t_d_1,z,'k')
ylim([-1000 0])
title('TD1, TD2')
xlabel('T_D [m]','FontSize',14)
grid on
%text(-46,-50,'iv)','Color','k','Fontsize',12)

subplot(1,5,4)
plot(cumtd_1/1e4,z,'k')
ylim([-1000 0])
title('cumTD1, cumTD2')
xlabel('Cum T_D [m 10^4]','FontSize',14)
grid on
%text(1.7e4/1e4,-50,'v)','Color','k','Fontsize',12)

subplot(1,5,5)
plot(TL_1,z,'k')
ylim([-1000 0])
title('TL1, TL2')
xlabel('T_L [m]','FontSize',14)
grid on
%text(8,-50,'vi)','Color','k','Fontsize',12)

set(f1,'Renderer','Painter')

fig = [path,filesep,['T_L_Comparison_' fldnm '_test_Profile'],num2str(ii),'.png'];
saveas(f1,fig,'png')
close
end
%% PLot a single profiel
close all

ii = 25; 

cumtd_1 = MSdata.Binned(ii).cumT_D_1; cumtd_2 = MSdata.Binned(ii).cumT_D_2;
    t_tf_1 = MSdata.Binned(ii).T_TF_1; t_tf_2 = MSdata.Binned(ii).T_TF_2;
    t_d_1 = MSdata.Binned(ii).T_D_1; t_d_2 = MSdata.Binned(ii).T_D_2;
    reoT_1 = MSdata.Binned(ii).reoT_1; reoT_2 = MSdata.Binned(ii).reoT_2;
    TL_1 = MSdata.Binned(ii).L_T_whole_1; TL_2 = MSdata.Binned(ii).L_T_whole_2;
    t1 = MSdata.Binned(ii).T1; t2 = MSdata.Binned(ii).T2;
    z = -MSdata.Binned(ii).Z;
   
f1 = figure('Position',[50,100,1200,800],'Units','normalized');
ax1 = axes('Position',[.08 .1 .17 .85]);
plot(t1,z,'k',reoT_1,z,'b')
ylim([-2000 0])
title('T1, REOT1')
ylabel('Z [m]','Fontsize',14)
xlabel('\Theta [^\circC]','FontSize',14)
grid on
text(1,-50,'i)','Color','k','Fontsize',12)
legend('T1','ReoT','Location','SouthEast')

ax2 = axes('Position',[.28 .1 .16 .85]);
plot(t_tf_1,z,'b')
ylim([-2000 0])
title('TF1')
xlabel('T_F [^\circC]','FontSize',14)
grid on
yticklabels([])
xlim([-0.07 0.07])
text(-0.06,-50,'ii)','Color','k','Fontsize',12)

ax3 = axes('Position',[.46 .1 .16 .85]);
plot(t_d_1,z,'b')
ylim([-2000 0])
title('TD1')
xlabel('T_D [m]','FontSize',14)
grid on
yticklabels([])
xlim([-40 40])
text(-36,-50,'iii)','Color','k','Fontsize',12)

ax4 = axes('Position',[.64 .1 .16 .85]);
plot(cumtd_1/1e4,z,'b')
ylim([-2000 0])
title('cumTD1')
xlabel('Cum T_D [10^4 m]','FontSize',14)
grid on
yticklabels([])
text(0.85e4/1e4,-50,'iv)','Color','k','Fontsize',12)

ax5 = axes('Position',[.82 .1 .16 .85]);
plot(TL_1,z,'b')
ylim([-2000 0])
title('TL1')
xlabel('T_L [m]','FontSize',14)
grid on
yticklabels([])
text(7,-50,'v)','Color','k','Fontsize',12)

set(f1,'Renderer','Painter')



%%
tic
MSdata_Eur = MSdata;
save('C:\UEA\MatLab_Working_Folder\EURECA\Data','MSdata_Eur');
toc; 
disp(sprintf('Data Saved'));