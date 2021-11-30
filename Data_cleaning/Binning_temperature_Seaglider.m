
%% SCript to bin Micro Structure data
%% Set up work space and load data 
close all
clear

addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\EURECA'));


load('MSdata_Eur.mat'); 
load('eurec4a_MSdata_mdlspd.mat');

%% Set up binning parameters
% calculate the binning increment 
% Calculting the depth difference for a vertical profile, use this section
% for a profiler and to calculate the vertical depth changes of the glider
    % for ii = 1:258
    %     tic
    %     prof_dz(ii) = nanmedian(diff(MSdata_Eur.Raw(ii).Z_fast));
    %     toc
    % end


% extra section for working along slope depth change rather than vertical
% depth change for use when calculting with gliders
    for ii = 1:258
        tic
        prof_num = ii + 4;
        A = eurec4a_MSdata.profile(prof_num).pitch; % pitch from glider
        Z1 = gsw_z_from_p(eurec4a_MSdata.profile(prof_num).P_slow,14); % z to go with pitch 
        Z2 = MSdata_Eur.Raw(ii).Z_fast;
        dz = diff(Z2);

        [Z1, idx] = unique(Z1);

        new_A  = interp1(Z1,A(idx),Z2); % interpolate pitch to the 512 Hz resolution

        dz_diff = dz; dz_diff(:) = nan;

        for jj = 1:(length(Z2)-1)
            dz_diff(jj,1) = dz(jj,1)/tand(new_A(jj,1)); 
        end

        prof_dz_as(ii) = nanmedian(dz_diff);

        clear new_A A Z1 Z2 dz dz_diff
        toc
    end
    

% using the dz calculated above, work out what the binning intervals should
% be used and create a depth profile based on the calculated differnces
    dz = nanmedian(abs(prof_dz_as)); % average depth spacing of the glider across all dives
    sr = 1/512; % sampling rate in seconds
    bin_fq = 1/100; % binning frequency
    min_dz = (dz*512)*bin_fq; % minimum physical resolution of the date based on glider speed and sampling frequency
    max_z = 800; % maximum depth of the profiles we need to bin
    
    z_profile = (0:min_dz:max_z)'; % create a depth profile to bin onto based on the physcial resolution of the glider and instrument

%% Binning each profile 

    prof_start = 2; prof_end = 20; % microstructure profiles to be binned    

for ii = prof_start:prof_end
    tic
    disp(sprintf('Binning profile %d of %d',ii,prof_end))
    c1 = datetime('now'); c1 = datestr(c1);
    disp((['Time at start of binning was ',c1]))
    prof_num = ii + 4; 
    
    xbin = -MSdata_Eur.Raw(ii).Z_fast;
    tobin_temp = MSdata_Eur.Raw(ii).T1_cons_100hz;
    tobin_time = eurec4a_MSdata.profile(prof_num).YD_fast;

    bin_data(:,1) = xbin; bin_data(:,2) = tobin_temp; bin_data(:,3) = tobin_time;
    
    bins = discretize(bin_data(:,1), z_profile);

    binned_data(:,1) = z_profile; 
    binned_data(:,2) = z_profile; binned_data(:,2) = nan;
    binned_data(:,3) = z_profile; binned_data(:,3) = nan;
    
    
    for jj = 1:length(z_profile)
       idx = bins == jj; 
       binned_data(jj,2) = median(bin_data(idx, 2));
       binned_data(jj,3) = median(bin_data(idx, 3));
       clear idx
    end
    
    MSdata_Eur.Binned(ii).Z = binned_data(:,1);
    MSdata_Eur.Binned(ii).T = binned_data(:,2);
    MSdata_Eur.Binned(ii).yd = binned_data(:,3);
 
    clear binned_data bin_data xbin tobin tobin_2
    
    if rem(ii,10) == 0 
        save('C:\UEA\MatLab_Working_Folder\EURECA\Data\MSdata_Eur','MSdata_Eur');
    elseif ii == prof_end
        save('C:\UEA\MatLab_Working_Folder\EURECA\Data\MSdata_Eur','MSdata_Eur');
    else
        
    end    
    
    c2 = datetime('now'); c2 = datestr(c2);
    disp((['Time at end of binning was ',c2]))
    t = toc; t = t/60;
    disp(sprintf('Binned profile number %d of %d in %.1f minutes',ii,prof_end,t))
end

