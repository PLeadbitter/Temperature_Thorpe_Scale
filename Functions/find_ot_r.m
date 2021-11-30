function [ot_r] = find_ot_r(ot_no,ot_height,ot_z,min_ot_size,min_spacing,max_r_size)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Combining overturns into overturning regions
comb_matr(1:6,1:max(ot_no)) = NaN;

for jj = 1:max(ot_no)
    % index for where region equal to ot_no
    idx = (ot_no) == jj;
    
    % determine inital conditions
    if ot_height(1) > min_ot_size
        comb_matr(1,1) = 1;                                 % Overturn Number
        comb_matr(2,1) = 0;                                 % Is overturn bigger than min_ot_size
        comb_matr(3,1) = 0;                                 % Distance between overturn and previous overturn
        comb_matr(4,1) = 0;                                 % Is distance smaller than minimum distance
        comb_matr(5,1) = ot_height(1);                      % Overturn height
        comb_matr(6,1) = comb_matr(3,1) + comb_matr(5,1);   % combined height of overturn and distance between overturns
    elseif ot_height(1) < min_ot_size
        comb_matr(1,1) = 1;                                 % Overturn Number    
        comb_matr(2,1) = 1; 
        comb_matr(3,1) = 0;
        comb_matr(4,1) = 0;
        comb_matr(5,1) = ot_height(1);
        comb_matr(6,1) = comb_matr(3,1) + comb_matr(5,1);
    else
        
    end
        
    % determine values for the rest of the overturn numbers    
        
    for jj = 2:max(ot_no)
        if ot_height(jj) >= min_ot_size
            comb_matr(1,jj) = jj;
            comb_matr(2,jj) = 0; 
            comb_matr(3,jj) = (ot_z(jj)-(ot_height(jj)/2))-(ot_z(jj-1)+(ot_height(jj-1)/2));
            if comb_matr(3,jj) >= min_spacing
                comb_matr(4,jj) = 0;
            else
                comb_matr(4,jj) = 1;
            end
            comb_matr(5,jj) = ot_height(jj);
            comb_matr(6,jj) = comb_matr(3,jj) + comb_matr(5,jj);
        else
            comb_matr(1,jj) = jj;
            comb_matr(2,jj) = 1; 
            comb_matr(3,jj) = (ot_z(jj)-(ot_height(jj)/2))-(ot_z(jj-1)+(ot_height(jj-1)/2));
            if comb_matr(3,jj) >= min_spacing
                comb_matr(4,jj) = 0;
            else
                comb_matr(4,jj) = 1;
            end
            comb_matr(5,jj) = ot_height(jj);
            comb_matr(6,jj) = comb_matr(3,jj) + comb_matr(5,jj);
        end
    end
end

    % predetermine ot_r
    ot_r(1:length(ot_no)) = 0;
    ot_no_new(1:2,1:max(ot_no)) = NaN; 
    ot_no_new(1,1) = 1;
    ot_no_new(2,1) = comb_matr(6,1);
    
    % Group overturns
    current_ot = 1;
for jj = 2:max(ot_no)
    if comb_matr(2,jj) == 0
        current_ot = current_ot +1;
        ot_no_new(1,jj) = current_ot;
        ot_no_new(2,jj) = comb_matr(6,jj);
    elseif comb_matr(2,jj) == 1 && comb_matr(4,jj) == 0
        current_ot = current_ot +1;
        ot_no_new(1,jj) = current_ot;
        ot_no_new(2,jj) = comb_matr(6,jj);
    elseif comb_matr(2,jj) == 1 && comb_matr(4,jj) == 1
        if ot_no_new(2,jj-1) > max_r_size
            current_ot = current_ot +1;
            ot_no_new(1,jj) = current_ot;
            ot_no_new(2,jj) = comb_matr(6,jj);
        else 
            ot_no_new(1,jj) = current_ot;
            ot_no_new(2,jj) = ot_no_new(2,jj-1) + comb_matr(6,jj);
        end
    end
end

% Determine overturning regions
ot_no_short = 1:max(ot_no);

for jj = 1:max(ot_no_new(1,:))
    idx = ot_no_short(ot_no_new(1,:) == jj);
    
    st_point = find(ot_no == min(idx),1);
    end_point = find(ot_no == max(idx),1,'last');
    
    ot_r(st_point:end_point) = jj;   
end
end

