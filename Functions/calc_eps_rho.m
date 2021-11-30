function [e_whole,e,n2_mean] = calc_eps_rho(ot_no,L_T,rho,rho0,z,eps_c,end_val)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%   

% define the largest of the vectors to put the complete data sets into    
    e_whole(1:end_val,1) = nan;
    e(1:length(L_T),1) = nan;
    n2_mean(1:length(L_T),1) = nan;
    
    for jj = 1:max(ot_no)
        
        idx = (ot_no == jj); % overturn index
          
        n2 = bfrqsq(rho(idx),z(idx),rho0);
        n2_mean(jj) = nanmean(n2);
        
        e(jj) = eps_c * (L_T(jj)^2) * (n2_mean(jj)^(3/2));

        e_whole(idx) = e(jj); 
        
    end
end

