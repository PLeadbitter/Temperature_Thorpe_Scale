function [RL, ot_dep] = runlen(t_f,ot_num,depth)
% function to determine the run-lengths of a thorpe scaled data set
% INPUTS
% t_f : Thorpe fluctuations or thorpe displacements
% ot_num : Number of overturn, used to filter out overturns
% OUTPUTS
% filter : Filter of sign value
% runs : vector with length of runs for a profile 
    
    max_ot_num = nanmax(ot_num);
    rl = 1:max_ot_num; rl(:) = NaN;
    
    
for ii = 1:1:max_ot_num
    
    ot_t_f = t_f(ot_num == ii);
    ot_dep(ii) = nanmean(depth(ot_num == ii));
    
    ot_t_f(ot_t_f == 0) = [];
    filter = ot_t_f; filter(:) = NaN;
    
    
    n = 1; filter(1) = n;
    
        for jj = 2:length(ot_t_f)
            nn = jj - 1;
            
            if (isequal(sign(ot_t_f(jj)), sign(ot_t_f(nn)))) && (ot_t_f(jj) ~= 0)
                filter(jj) = n;
            elseif (~isequal(sign(ot_t_f(jj)), sign(ot_t_f(nn)))) && (ot_t_f(jj) ~= 0)
                n = n + 1;
                filter(jj) = n; 
%             else 
%                 filter(jj) = NaN;
            end    
        end

        ix = find(diff(filter(:))); 
        runs = [ix; numel(filter)] - [0; ix];
        
        rl(ii) = rms(runs);
        clear runs ix filter
end
    
    RL = rl;

end

