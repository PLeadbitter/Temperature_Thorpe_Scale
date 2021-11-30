function [mask,mask_std,adj_e,adj_r] = cal_cut_off(eps,sal_temp_ratio)
% Create a mask to filter the epsilon data data with, using a z score 
%
% INPUTS
% eps = epsilon grid of X by Y
% sal_temp_ratio = grid of s_std/t_std of X by Y
% X and Y must be the same for both inputs. s_std is the standard deviation
% for each depth bin of salinity and t_std is the standard deviation for
% each depth bin of temperature. The sal_temp_ratio is calculated in the
% filt_ratio function
%
% OUTPUTS
% mask = an X by Y mask for the epsilon data
% mask_std = the standard deviation of the mask

% Check both inputs are the same size
if isequal(size(eps), size(sal_temp_ratio)) || ...
    (isvector(eps) && isvector(sal_temp_ratio) && numel(eps) == numel(sal_temp_ratio))
else
    error('Input Arrays must both be X by Y') 
end 


% Calculate the Z Score for the Salinity Temperature ratio
mean_r = nanmean(nanmean(log10(sal_temp_ratio))); 
std_r = nanstd(nanstd(log10(sal_temp_ratio)));
adj_r = 10.^((log10(sal_temp_ratio) - mean_r)/std_r);

% Calculate the Z Score for the epsilon data
mean_e = nanmean(nanmean(log10(eps))); 
std_e = nanstd(nanstd(log10(eps)));
adj_e = 10.^((log10(eps) - mean_e)/std_e);

% Create the filter mask and associated standard deviation
mask = log10(adj_r.*adj_e);
mask_std = nanstd(nanstd(mask));
end

