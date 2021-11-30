function [norm_sal_temp_ratio,sal_temp_ratio,rsquared] = filt_ratio(inc,data_in,prof_st,prof_end)
% Calculate a ratio of salintiy/temperatre standard deviation
% INPUTS
% inc = depth increments to use as bins. In the form 0 in steps of X to -Y
% data_in = A structure that is 1 X X where X is the max profile number,
% needs to contain
%       surface lat in the form .lat
%       pressure for each data point in the form .p
%       temperature for each data point in the form .td
%       salinity for each data point in the form .sd
%
% OUTPUTS
% sal_temp_ratio = ratio of salinity/temperautre std, for us in function cal_cut_off


for jj = prof_st:1:prof_end
% Calculate height for the profile
z_prof = gsw_z_from_p(data_in(jj).p,data_in(jj).lat);

% Assign temperature and salinity variables
t_prof = data_in(jj).td;
s_prof = data_in(jj).sd;

for ii = 2:1:length(inc)
    % Data subsections
    t_prime = t_prof(z_prof <= inc(ii - 1) & z_prof > inc(ii));
    s_prime = s_prof(z_prof <= inc(ii - 1) & z_prof > inc(ii));
    
    % calculate the rsquared value
    if isempty(t_prime) == 1 & isempty(s_prime) == 1
        rsquared(ii-1,jj) = NaN;
    else
        mdl = fitlm(s_prime,t_prime);
        rsquared(ii-1,jj) = mdl.Rsquared.Ordinary;
    end
    % Calculate the STD of temperature
    t_prime(isnan(t_prime)) = []; t_prime = diff(t_prime);
    t_std(ii-1,jj) = std(t_prime,'omitnan');
    
    % Calculate the STD of salinity
    s_prime(isnan(s_prime)) = []; s_prime = diff(s_prime);
    s_std(ii-1,jj) = std(s_prime,'omitnan');
   
    clear t_prime s_prime 
end    
end

% Bulk our the bottoms of the standard deviations so that they are the size
% they where when input
s_std(end+1,:) = NaN;
t_std(end+1,:) = NaN;
rsquared(end+1,:) = NaN;

% Calculate the ratio of Salinity/temperature standard deviation
sal_temp_ratio(:,:,1) = (s_std./t_std);

% apply normalisation to the ratio
ratio_mean = mean(log10(sal_temp_ratio(:)),'omitnan');
ratio_std = std(log10(sal_temp_ratio(:)),'omitnan');

norm_sal_temp_ratio = (log10(sal_temp_ratio)-ratio_mean)./ratio_std;

end

