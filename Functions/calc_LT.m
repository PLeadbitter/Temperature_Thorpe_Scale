function [lt_mid,l_t_whole,z_mid,yd_mid] = calc_LT(ot_no,t_d,yd,z)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    jj = 1;
    i = max(ot_no);

    l_t_whole(1:length(t_d),1) = nan; z_mid(i:1) = nan; yd_mid(i:1) = nan; lt_mid(i:1) = nan;
    
    % check if yd has a any values, if not replace it with a NaN array
    % yd is not a needed input
    if isempty(yd)
        yd(length(z),1) = NaN;
    else
        %yd = yd;
    end 
        
    
    for b = 1:i
        
        c = find(ot_no == b);
        
        z_mid(jj) = (max(z(c))+min(z(c)))/2; % calculate the mid point of an overturn in depth
        yd_mid(jj) = (min(yd(c))+max(yd(c)))/2; % calculate the mid point of an overturn in time
        
        lt_mid(jj) = calc_tl(t_d(c)); % calculate Thorpe length for each overturn
        l_t_whole(c) = lt_mid(jj);
        
        jj = jj + 1;

    end
end

