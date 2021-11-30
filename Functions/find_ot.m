function [ot_no] = find_ot(cumt_d)
% FIND_OT finds the overturns in a profile
% Find the overturns in a profile based on the cumulative thorpe
% displacement
% cumt_d : cumulative Thorpe Displacement 
% ot_no : a incremental number associated with a given overturn

    jj = 1;                                     % overturn number count
    ot_no(1:length(cumt_d)) = nan;              % overturn number
    a = length(cumt_d);
    
    % Initial overturn conditions 
        if cumt_d(1) ~= 0
            ot_no(1) = jj; 
        elseif cumt_d(1) == 0 && cumt_d(2) ~= 0
            ot_no(1) = jj;
        else
            ot_no(1) = 0;
        end
   
        ot_no(end) =0;                           % set the last value as 0   
        
    % Assigning overturn values to overturns
        for z=2:a(length(a))-1
            if cumt_d(z) ~= 0                      
                ot_no(z) = jj;                   % case 1 
            elseif cumt_d(z) == 0                % cases 2 - 6
                if cumt_d(z - 1) == 0            
                    if cumt_d(z + 1) ~= 0        % cases 3 and 4
                        ot_no(z) = jj;           % case 3
                    else
                        ot_no(z) = 0;               % case 4
                    end
                else                             % cases 2,5 and 6
                    if cumt_d(z + 1) ~= 0        
                        ot_no(z) = jj;           % case 2
                    else                         
                        if  cumt_d(z + 2) ~= 0   % cases 5 and 6
                            ot_no(z) = jj;       % case 5
                        else                      
                            ot_no(z) = jj;       % case 6  
                            jj = jj + 1;
                        end
                    end
                end
            else
                ot_no(z) = nan;
            end
        end
        
        ot_no = ot_no';
        
end

