function [N2,zz] = bfrqsq(rho,z,rho0)
%[N2,zz] = bfrqsq(rho,z)
%
% This function calculates buoyancy frequency squared from a      
% profile of potential density.
%
% INPUTS
% rho = potential density (kg m^-3)
% z   = profile depth levels (m)
% rho0 = refernce denisty (kg m^-3)
%
% OUTPUTS
% N2  = buoyancy frequency squared (s^-2)
% zz  = N2 profile depth levels (m)

% define constants
g = 9.81; % gravity (m s^-2)

% calculate vertical potential density gradient (kg m^-4)
rho_grad = diff(rho)./diff(z); 

% calculate buoyancy frequency squared (s^-2)
N = sqrt(- g/rho0*rho_grad);
N2 = N.^2;

% calculate N2 profile depth levels (m)
zz = 0.5*(z(1:end-1)+z(2:end));
end

