  function [xtrend,xamp,xph,xts,xr,stats] = quick_tidal_analysis(x,t,T,trend)

% [xtrend,xamp,xph,xts,xr,stats] = quick_tidal_analysis(x,t,T,trend)
%
% This function performs a harmonic analysis of timeseries x for a single
% or multiple tidal constituents including removal of trend and time-mean.
%
% INPUTS
% x:      variable (any units)
% t:      time (yearday)
% T:      tidal periods (hours) [T1,T2,T3,... default: 12.4206 (M2)]
% trend:  switch to remove trend as well as time-mean [default: 1]
%
% OUTPUTS
% xtrend: variable time-mean (same units as x)
%         and variable trend (same units as x / same units as t)
% xamp:   amplitude of each tidal constituent (same units as x)
% xph:    phase of each tidal constituent (radians)
% xts:    timeseries of each tidal constituent (same units as x)
% xr:     residual timeseries (same units as x)
% stats:  regression statistics
%         (R-square statistic, F statistic, p value, error variance)
%
% Rob Hall (Aug 2014)

if nargin < 2
    error('Must input variable and time')
end

%% default tidal period

if ~exist('T','var') || isempty(T)
    T = 12.4206;
end

%% default trend switch

if ~exist('trend','var') || isempty(trend)
    trend = 1;
end

%% ensure inputs are column vectors

if size(x,1) == 1
    x = x';
end
if size(t,1) == 1
    t = t';
end

%% calculate tidal periods in days

T = T/24;

%% size of arrays

% number of tidal constituents
N = length(T);

% number of data points
nx = length(x);

%% construct matrix

if trend == 0
    A1 = zeros(nx,N*2+1);
elseif trend == 1
    A1 = zeros(nx,N*2+2);
end

% constant
A1(:,1) = 1;

% tidal constituent loop
for n = 1:N
    
    % cos component of each tidal constituent
    A1(:,n*2) = cos(2*pi/T(n)*t);
    
    % sin component of each tidal constituent
    A1(:,n*2+1) = sin(2*pi/T(n)*t);
    
end

% linear trend
if trend == 1
    A1(:,N*2+2) = linspace(0,1,nx)';
end

%% least squares fit

%A2 = A1';
%A = A2*A1;
%B = A2*x;
%C = A\B;

[C,~,~,~,stats] = regress(x,A1);

%% calculate outputs

xamp = zeros(1,N);
xph = zeros(1,N);

xts = zeros(nx,N);

% variable time-mean
xtrend(1) = C(1);

% variable trend
if trend == 1
    xtrend(2) = C(N*2+2)/(max(t) - min(t));
end

% tidal constituent loop
for n=1:N
    
    % amplitude of each tidal constituent
    xamp(n) = sqrt(C(n*2)^2 + C(n*2+1)^2);
    
    % phase of each tidal constituent
    xph(n) = atan2(C(n*2+1),C(n*2));
    
    % timeseries of each tidal constituent
    xts(:,n) = xamp(n)*cos(2*pi/T(n)*t - xph(n));
    %xts(:,n) = C(n*2)*cos(2*pi/T(n)*t) + C(n*2+1)*sin(2*pi/T(n)*t);    

end

% residual timeseries
if trend == 0
    xr = x - xtrend(1) - sum(xts,2);
elseif trend == 1
    xr = x - xtrend(1) - xtrend(2)*(t - min(t)) - sum(xts,2);
end

return