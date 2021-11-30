function [J,conc_grad] = ficks_law(Dt,C,Z,n)
% Calculate the flux of variable
%
% INPUTS
% Dt = Diffusivity
% C = variable of flux
% z = the z profile over which flux wants to be caluculated
% n = number of points to calculate gradient over
%
% OUTPUTS
% J = flux of variable C
%
%
%
%

% create an empty gradient vector
conc_grad = zeros(length(C),1); conc_grad(:) = NaN; 
% calculate the gradient of the variable with depth
for ii = 1:n:length(C)
    if ii+(n-1) < length(C) 
        c = C(ii:ii+(n-1));
        z = Z(ii:ii+(n-1));
    % calculate the gradident using a linear regression
        %regr = z\c;
        regr = polyfit(z,c,1);
        conc_grad(ii) = regr(1);
    else
        c = C(ii:end);
        z = Z(ii:end);
    % calculate the gradident using a linear regression
        %regr = z\c;
        regr = polyfit(z,c,1);
        conc_grad(ii) = regr(1);    
    end   
end    
    conc_grad(isnan(conc_grad)) = [];
    
% pad the end to allow multiplication against Dt
if length(conc_grad) ~= length(Dt)
    conc_grad(end+1:length(Dt)) = NaN;
else 
    
end
    

% Calculate J
J = -Dt.*conc_grad;

end