% get column and row values for input matrix and create new matrix the same
% size as it to put data into later
function bathy = Track_depth(la,lo,lat,lon,ele)
[r c] = size(la);
lat_reverse = zeros(r,c);

lat_play = la;
%%
%find all non-NaN values in the given matrix and extract their locations,
%find their exact values, flip the values to reverse the order and input
%them into the new matrix

for n = 1:c
    
    q = ~isnan(lat_play(:,n));
    q1 = lat_play(q,n);
    q2 = flipud(q1);
    
    %find the length of q2 to allow it to be inputed into the larger matrix
    l = length(q2);

lat_reverse(1:l,n) = q2;

clear q1
clear q2
end

%% Calculate the average of every other pair e.g. 1-2 3-4 5-6 etc.
%take the top row
row_1 = lat_reverse(1,:);
% create to vectors with the correct 


for n = 1:2:c
        
    row_1_avg(n,1) = (row_1(1,(n))+row_1(1,(n+1)))/2;
    
end
%% 
%repeat the script but for longitutde 
[r c] = size(lo);
lon_reverse = zeros(r,c);

lon_play = lo;
%%
%find all non-NaN values in the given matrix and extract their locations,
%find their exact values, flip the values to reverse the order and input
%them into the new matrix

for n = 1:c
    
    v = ~isnan(lon_play(:,n));
    v1 = lon_play(v,n);
    v2 = flipud(v1);
    
    %find the length of q2 to allow it to be inputed into the larger matrix
    l = length(v2);

lon_reverse(1:l,n) = v2;

clear v1
clear v2
end

%% Calculate the average of every other pair e.g. 1-2 3-4 5-6 etc.
%take the top row
row_1_1 = lon_reverse(1,:);
% create to vectors with the correct 


for n = 1:2:c
        
    row_1_1_avg(n,1) = (row_1_1(1,(n))+row_1_1(1,(n+1)))/2;
    
end
%% Remove 0 values from the lat and lon values, then find the associate depth values in the jebco data set
%rename row_1 files 
lat_row_1 = row_1_avg;
lon_row_1 = row_1_1_avg;

lat_row_1(lat_row_1 == 0) = NaN;
lon_row_1(lon_row_1 == 0) = NaN;

lat_row_1(find(isnan(lat_row_1)))=[];
lon_row_1(find(isnan(lon_row_1)))=[];
%%
%find asociated gebco deapths with the lat and lon values
new_depth = interp2(lon,lat,ele,lon_row_1,lat_row_1);
new_depth_2 = repelem(new_depth,2);
bathy = -new_depth_2;
end