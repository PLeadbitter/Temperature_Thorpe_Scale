function [LT]=calc_tl(L)
% calclulate the thorpe scale of an overturn
% Inputs
% L = Thorpe displacement across and overturn
%
% Outputs
% LT = Thorpe length scale associated with an overturn

LT=sqrt(nanmean(L.^2)); 


end