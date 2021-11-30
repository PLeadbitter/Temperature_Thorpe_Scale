function [offset, corrected] = pres_correct(h, alph, depth, pitch, prof_num, prof_os)
% Function to add an offset to pressure on a glider when the probe and
% pressure sensor are not along the same axes
% Inuputs:
    % h = distance between probe and pressure sensor
    % alph = angle that h is at
    % pressure = structure with pressure in it. should have the form
        % pressure.profile(n) where n is profile number to 3 decimal places
        % profile(n) should also be a (m,1) vector
    % pitch = structure with pitch in it. should have the form
        % pitch.profile(n) where n is profile number to 3 decimal places
        % profile(n) should also be a (m,1) vector
    % prof_num = the maximum number of indiviual profiles in the structures
        % pressure and pitch
    % prof_os = a profile offset for if profile numbers do not start at 1,
        % use a value of 0 if profiles start at 1
% Outputs
    % offset = offset value in height as a structure the same size as
        % pressure and pitch
    % corrected = a corrected value of pressure with the offset applied
    % NOTE 20190818, corrected is currently a height added to a pressure
    % value not a pressure to a pressure value
    % 20200113 PJL, Added timing for each section and changed p.dive to
    % p.profile in the third loop where the offset is applied
    % 202001013 PJL, Changed theta for phi, modified it to calculate the
    % offset for a depth value and inveresed the additions to give correct
    % sized angles for phi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    p = depth; % set up the input pressure values 
    pt = pitch; % set up the input pitch values 
    
    sprintf('calculating phi');
for ii = 1:prof_num
    tic
    ii = ii + prof_os;
    
    dir = mod(ii,2); % 0 is descent is profile 1
    
    if dir == 0 % descent 
       eval(['phi.profile' num2str(ii,'%03d') ...
           '= pt.profile' num2str(ii,'%03d') '+ alph;']);  
    else
       eval(['phi.profile' num2str(ii,'%03d') ...
            '= pt.profile' num2str(ii,'%03d') '+ alph;']) ;
    end
    toc
end 

    sprintf('Calculating offset')
for ii = 1:prof_num
    tic
    ii = ii + prof_os;
    
    eval(['len = length(phi.profile' num2str(ii,'%03d') ');']);
    for jj = 1:len
    
    eval(['offset.profile' num2str(ii,'%03d') ...
        '(jj,:) = abs(h * sind(phi.profile' num2str(ii,'%03d') '(jj,:)));']);
    end
    toc
end
    
sprintf('Applying offsets')
for ii = 1:prof_num
    tic
    ii = ii + prof_os;
    
    eval(['len = length(phi.profile' num2str(ii,'%03d') ');']);
    
    dir = mod(ii,2);
    
    for jj = 1:len
    if dir == 0 %descent
        
    eval(['pres_corrected.profile' num2str(ii,'%03d') ...
        '(jj,:) =  p.profile' num2str(ii,'%03d') ...
        '(jj,:) - offset.profile' num2str(ii,'%03d') '(jj,:);']);
    else
    eval(['pres_corrected.profile' num2str(ii,'%03d') ...
        '(jj,:) =  p.profile' num2str(ii,'%03d') ...
        '(jj,:) + offset.profile' num2str(ii,'%03d') '(jj,:);']);
    end
    end
    toc
end 

corrected = pres_corrected;

end