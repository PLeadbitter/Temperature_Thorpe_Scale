function [L,reoT,tf] = temp_reorder(T,Z,dir) 

tic

orig_T = [Z T];
new_T = orig_T;

if dir == 1
    dir = 'dn';
else
    dir = 'up';
end

switch dir
    case 'up'
        trans_T = sortrows(orig_T,[2,1],{'ascend' 'descend'});
        new_T(~isnan(orig_T(:,2)),:) = trans_T(~isnan(trans_T(:,2)),:);
        
        reoT = new_T(:,2);
        tf = new_T(:,2) - orig_T(:,2);
        
        concat_T = [new_T,Z];
        %concat_R = sortrows(concat_T, 1, 'descend');
        L = concat_T(:,3) - concat_T(:,1);
    case 'dn'
        trans_T = sortrows(orig_T,[2,1],{'ascend' 'ascend'});
        new_T(~isnan(orig_T(:,2)),:) = trans_T(~isnan(trans_T(:,2)),:);
        
        reoT = new_T(:,2);
        tf = new_T(:,2) - orig_T(:,2);
        
        concat_T = [new_T,Z];
        %concat_R = sortrows(concat_T, 1, 'ascend');
        L = concat_T(:,1) - concat_T(:,3);    
    otherwise
        warning('no direction specified, use up for up or dn for down')
end
        
toc
return