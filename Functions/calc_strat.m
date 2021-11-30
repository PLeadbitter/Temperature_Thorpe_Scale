function [N2_bulk_whole,N2_mean_whole,N2_bulk,N2_mean,mean_alpha,mean_R_rho,...
    mean_alpha_whole,mean_r_rho_whole,theta_mean,theta_bulk]= calc_strat(Z,L_T,T_F,ot_no,reoT,alph,r_rho,g)
% Calculate the Buoyancy frequency (N2) using the bulk and mean gradients
% of temperature from Thrope Scaling Parameters
%
% INPUTS
% Z : Depth 
% L_T : Thorpe Length Scale
% T_F : Thorpe Fluctuations
% ot_no : Overturn number, used as an index
% reoT : Reordered temperature
% alph : Thermal expansion coefficent
% r_rho : stability ratio
% g : Gravitaional acceleration constant
%
% OUTPUTS
% N2_bulk_whole : N2 calculated from bulk gradient across all binned values
% N2_mean_whole : N2 calculated from mean gradient across all binned values
% N2_bulk : N2 calculated from bulk gradient at overturn centre
% N2_mean : N2 calculated from mean gradient at overturn centre

% Predetermine outputs
    N2_bulk_whole(1:length(reoT),1) = nan; 
    N2_mean_whole(1:length(reoT),1) = nan; 
    N2_bulk(1:length(L_T),1) = nan;
    N2_mean(1:length(L_T),1) = nan;
    mean_alpha(1:length(L_T),1) = nan;
    mean_R_rho(1:length(L_T),1) = nan;
    mean_alpha_whole(1:length(reoT),1) = nan; 
    mean_r_rho_whole(1:length(reoT),1) = nan; 
    
% Calculate Buoyancy frequency for each overturn     
    for jj = 1:max(ot_no)
        
        idx = (ot_no == jj); % overturn index
        
        theta_mean(:,jj) = polyfit(Z(idx),reoT(idx),1); % calculate the gradient of reordered temperature using a linear regression
        theta_bulk(jj) = (sqrt(nanmean((T_F(idx)).^2)))/L_T(jj); % calculate the bulk gradient of the temperature using Thorpe fluctuation
        
        mean_alpha(jj) = nanmean(alph(idx)); % mean thermal expansion coefficent over overturn
        mean_R_rho(jj) = nanmean(r_rho(idx)); % mean stability constant over overturn
        
        N2_bulk(jj) = g * mean_alpha(jj) * theta_bulk(jj) * (1-1/mean_R_rho(jj)); % calculate N2 from the bulk gradient
        N2_mean(jj) = g * mean_alpha(jj) * theta_mean(1,jj) * (1-1/mean_R_rho(jj)); % calculate N2 from the mean gradient
        
        N2_bulk(N2_bulk < 0) = NaN; % Any buoyancy frequency values below 0 removed as these cannot be real 
        N2_mean(N2_mean < 0) = NaN; % Any buoyancy frequency values below 0 removed as these cannot be real
    
        N2_bulk_whole(idx) = N2_bulk(jj); N2_mean_whole(idx) = N2_mean(jj);
        mean_alpha_whole(idx) = mean_alpha(jj); mean_r_rho_whole(idx) = mean_R_rho(jj);
    end
end

