function [e_bulk_whole,e_bulk,e_mean_whole,e_mean] = calc_eps(ot_no,L_T,n2b,n2m,eps_c,end_val)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%   

% define the largest of the vectors to put the complete data sets into    
    e_bulk_whole(1:end_val,1) = nan;
    e_mean_whole(1:end_val,1) = nan;
    e_bulk(1:length(L_T),1) = nan;
    e_mean(1:length(L_T),1) = nan;
    
    for jj = 1:max(ot_no)
        
        idx = (ot_no == jj); % overturn index
          
        e_bulk(jj) = eps_c * (L_T(jj)^2) * (n2b(jj)^(3/2));
        e_mean(jj) = eps_c * (L_T(jj)^2) * (n2m(jj)^(3/2));

        e_bulk_whole(idx) = e_bulk(jj); e_mean_whole(idx) = e_mean(jj);
        
    end
end

