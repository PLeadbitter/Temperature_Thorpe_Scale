%% Binning each profile 

    prof_start = 11; prof_end = 258; % microstructure profiles to be binned 

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
    
    %bins = discretize(bin_data(:,1), z_profile);
    bin_data(:,4) = discretize(bin_data(:,1), z_profile);
    
    bin_groups = findgroups(bin_data(:,4));  %use findgroups to return the group numbers associated with the bins
    binned_data_z_idx = splitapply(@median,bin_data(:,4),bin_groups); %applies the median function to each group (bin)
    binned_data_z = z_profile(binned_data_z_idx); % lookup the bin_group in the z_profile to return the actual depth rather than the line number
    binned_data_T = splitapply(@median,bin_data(:,2),bin_groups);
    binned_data_YD = splitapply(@median,bin_data(:,3),bin_groups);
    %then you need to join this back with z_profile, because this performs
    %really fast, but only on the section of depth that the glider ran
    %across, not the full z_profile. This would be done with something
    %similar to an outerjoin on multiple variables. 
    
    binned_data(:,1) = binned_data_z;
    binned_data(:,2) = binned_data_T;
    binned_data(:,3) = binned_data_YD;
    
    binned_data_table = array2table(binned_data,...
        'VariableNames',{'Z','T','YD'}); % create a table from the array to use outer join
    
    binned_profile(:,1) = z_profile; 
    %binned_profile(:,2) = z_profile; binned_profile(:,2) = [];
    %binned_profile(:,3) = z_profile; binned_profile(:,3) = nan;
    
    binned_profile_table = array2table(binned_profile,...
        'VariableNames',{'Z'}); % create a table from the array to use outer join
    
    binned_complete_table = outerjoin(binned_profile_table,binned_data_table,'MergeKeys',true);
    
    binned_complete = table2array(binned_complete_table);
    
    MSdata_Eur.Binned(ii).Z = binned_complete(:,1);
    MSdata_Eur.Binned(ii).T = binned_complete(:,2);
    MSdata_Eur.Binned(ii).yd = binned_complete(:,3);
 
    clear binned_data bin_data xbin tobin tobin_2 
    clear bin_groups binned_data_z_idx binned_data_z binned_data_T binned_data_YD
    clear binned_data_table binned_profile binned_profile_table binned_complete_table binned_complete
    
    if rem(ii,50) == 0 
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