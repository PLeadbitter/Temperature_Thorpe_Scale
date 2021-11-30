%% Clear up the workspace and load in data
clear  
close all

% add relevant paths for data, functions and toolboxes
addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\EURECA'));
 
load MSdata_Eur.mat; MSdata = MSdata_Eur; clear MSdata_Eur
load Binned_MSdata_Eur; Binned = Eur_Binned; clear Eur_binned

prof_st = 1; prof_end = 258;

%% calculate K_rho

for ii = prof_st:prof_end
    tic
    % constants
    cons = 0.1;
    end_val = length(MSdata.Binned(ii).L_T_whole_1);
    % define inputs
    L_T = MSdata.Binned(ii).L_T_1;
    ot_no = MSdata.Binned(ii).ot_r_no_1;
    n2s = MSdata.n2_extra(ii).Seabird_1;
    
    % square root N2
    ns = sqrt(n2s);
    
    [Krw,Kr] = calc_krho(ot_no, L_T, ns, cons, end_val);
    
    MSdata.Outputs(ii).krho_seabird_1 = Kr;
    MSdata.Outputs(ii).krho_seabird_whole_1 = Krw;
    clear Kr Krw L_T ot_no n2s nns
    
    t = toc; t = t/60;
    disp(sprintf('Calculated TKE  from profile %d of %d in %.1f minutes',ii,prof_end,t));
    
end

%% Bin K_rho to 25m bins
% Determine profile string
    fldnm = 'Eur';

% Determine the start and end profiles as well as a profile offset (leave
% as 0 if no offset is needed
    prof_start = 1; prof_end = 258;
    prof_offset = 0;

% clear out any data that may cause issues due to differing array sizes if
% binning at different depth values
% define the depth bin in meters
    bin_step = 25;
    bin_step_str = ['BinStep_' num2str(bin_step)];
% define the max depth that you want to bin too
    max_depth = 800;

    clear binned_seabird_1 mean_seabird_kr z_profile

for ii = prof_start:prof_end
    tic 
    z_profile = [0:bin_step:max_depth]'; 
    prof_num = ii + prof_offset;
    
    % Pick data to bin
        xbin_1 = MSdata.Binned(ii).ot_Z_1';
        tobin_kr_2 = MSdata.Outputs(ii).krho_seabird_1;
        
    % put all data into the same array
        bin_data(:,1) = xbin_1; bin_data(:,2) = tobin_kr_2; 
        bins = discretize(bin_data(:,1), z_profile);  
    
    % set the depth profile based on bin step
        binned_data(:,1) = z_profile; 
    
    % pre-determine the rest of the locations 
        binned_data(:,2) = z_profile; binned_data(:,2) = nan; 
    
    % bin the data 
    for jj = 1:length(z_profile)
       idx = bins == jj; 
       binned_data(jj,2) = 10.^(nanmean(log10(bin_data(idx, 2)))); 
       clear idx 
    end
    
    % split up the data into seperate arrays based on where the data has
    % come from 
        binned_seabird_1(:,ii) = binned_data(:,2); 
            
    clear binned_data bin_data clear xbin_1
    
     t = toc; t = t/60;
    disp(sprintf('Binning E values from bulk and Seabird, profile %d of %d in %.1f minutes',prof_num,prof_end,t));
end  

% Calculate the mean values 
    mean_seabird_krho(:,1) = 10.^(nanmean(log10(binned_seabird_1),2));

    Binned.(bin_step_str).Closest_Krho_1 = binned_seabird_1;   
    Binned.(bin_step_str).Mean_Closest_Krho_1 = mean_seabird_krho;
    
%% Save Data
close all

tic
MSdata_Eur = MSdata; Eur_Binned = Binned;
save('C:\UEA\MatLab_Working_Folder\EURECA\Data\Binned_MSdata_Eur','Eur_binned');
%save('C:\UEA\MatLab_Working_Folder\EURECA\Data\MSdata_Eur','MSdata_Eur');
toc; 
disp(sprintf('Data Saved'));




