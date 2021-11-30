function [krho_whole,krho] = calc_krho(ot_no,L_T,ns,krho_c,end_val)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%   

% define the largest of the vectors to put the complete data sets into    
    krho_whole(1:end_val,1) = nan;
    krho(1:length(L_T),1) = nan;
    
    for jj = 1:max(ot_no)
        
        idx = (ot_no == jj); % overturn index
          
        krho(jj) = krho_c * (L_T(jj)^2) * ns(jj);

        krho_whole(idx) = krho(jj); 
        
    end
end