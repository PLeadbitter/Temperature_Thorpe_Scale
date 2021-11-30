%% set up files for density thorpe scaling
clear  
close all

% add relevant paths for data, functions and toolboxes
addpath(genpath('C:\UEA\MatLab_Working_Folder\Toolboxes'));
addpath(genpath('C:\UEA\MatLab_Working_Folder\RidgeMix\Processing'));
 
%load MS_data_RS.mat; 
%load RidgeMix_RS_MSdata.mat; n = RidgeMix_RS_MSdata; clear RidgeMix_RS_MSdata
load vmp2000_all.mat; D = D3; RS = R1; RN = R1N; clear D3 R1 R1N 
load Seabird_data.mat; 

%% Take the data from the seabird data and put it into the RAW part of the MS structure

fldnm = 'D';
prof_srt = 1;
prof_end = 23;

for ii = prof_srt:prof_end
    MSdata.Raw(ii).T1 = Seabird_data.(fldnm)(ii).constemp;
    MSdata.Raw(ii).S1 = smoothdata(Seabird_data.(fldnm)(ii).abssal,'movmedian',10,'includenan');
    MSdata.Raw(ii).Z = Seabird_data.(fldnm)(ii).height;
    MSdata.Raw(ii).R1 = gsw_sigma1(MSdata.Raw(ii).S1,MSdata.Raw(ii).T1) + 1000;
end

%% Bin the data so that it is all on the correct spacing 
% bin data in RAW to 0.05m

% create depth profile 
    z_profile = (0:0.05:2000);

for ii = prof_srt:prof_end
    tic
    disp(sprintf('Binning profile %d of %d',ii,prof_end))
    
    xbin = -MSdata.Raw(ii).Z;
    tobin_temp_1 = MSdata.Raw(ii).T1;
    tobin_sal_1 = MSdata.Raw(ii).S1;
    tobin_rho_1 = MSdata.Raw(ii).R1;

    bin_data(:,1) = xbin; bin_data(:,2) = tobin_temp_1; 
    bin_data(:,3) = tobin_sal_1; bin_data(:,4) = tobin_rho_1;
    
    bins = discretize(bin_data(:,1), z_profile);

    binned_data(:,1) = z_profile;
    binned_data(:,2) = z_profile; binned_data(:,2) = nan;
    binned_data(:,3) = z_profile; binned_data(:,3) = nan;
    binned_data(:,4) = z_profile; binned_data(:,4) = nan;
    
    for jj = 1:length(z_profile)
       idx = bins == jj; 
       binned_data(jj,2) = median(bin_data(idx, 2));
       binned_data(jj,3) = median(bin_data(idx, 3));
       binned_data(jj,4) = median(bin_data(idx, 4));
       clear idx
    end
    
    
    MSdata.Binned(ii).Z = binned_data(:,1);
    MSdata.Binned(ii).T1 = binned_data(:,2);
    MSdata.Binned(ii).S1 = binned_data(:,3);
    MSdata.Binned(ii).R1 = binned_data(:,4);
 
    clear binned_data bin_data xbin tobin_time tobin_temp_1 tobin_temp_2
    
       
    save(['C:\UEA\MatLab_Working_Folder\RidgeMix\Processing\Processed_variables\MS_SB_data_' fldnm],'MSdata');
    
    t = toc; t = t/60;
    disp(sprintf('Binned profile number %d of %d in %.1f minutes',ii,prof_end,t))
end