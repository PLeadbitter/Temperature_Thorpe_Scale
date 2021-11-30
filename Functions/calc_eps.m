function [e_whole,e] = calc_eps(ot_no,L_T,n2,eps_c,end_val)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%   

% define the largest of the vectors to put the complete data sets into    
    e_whole(1:end_val,1) = nan;
    e(1:length(L_T),1) = nan;
    
    for jj = 1:max(ot_no)
        
        idx = (ot_no == jj); % overturn index
          
        e(jj) = eps_c * (L_T(jj)^2) * (n2(jj)^(3/2));

        e_whole(idx) = e(jj); 
        
    end
end

