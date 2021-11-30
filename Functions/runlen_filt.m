function [filt_LT,filt_E] = runlen_filt(prof_lt,prof_e,runlen,cutoff)
% function to filter overturns using a cut off value determined from a
% run length calculation. Provides out puts of both LT and E. 
% INPUTS
% prof_lt : Profile of LT 
% prof_e : Profile of epsilon 
% runlen : An associted run length profile for the two inputed profiles
% cutoff : Cut off based on runlength, needs to be a single number
% Note: Apart from cut off, all other inputs should be the same size and 1 x A
% vectors
% OUTPUTS
% filt_LT : Filtered value of LT
% filt_E : Filtered value of E

% Check that the profiles and run lengths are all the same length and that
% the cut off value is a single number

    if isequal(size(prof_lt), size(prof_e), size(runlen)) || ...
        (isvector(prof_lt) && isvector(prof_e) && isvector(runlen) && numel(prof_lt) == numel(prof_e) == numel(runlen))

    else
        error('prof_lt, prof_e and runlen must be the same size')
    end

    if length(cutoff) > 1
        error('Cutoff must be a vector of length 1, containing a single value')
    else

    end


%% Create a mask based on cutoff and runlength
% create variable for filter and place 1 where the the run length is higher
% than the cut off value
    
    filt = runlen; filt(:) = NaN;
    
    filt(runlen > cutoff) = 1;

    
%% Apply mask to prof_e and prof_lt
% take the filter based on run length and remove values for prof_lt and
% prof_e where they are below the threshold value

    filt_LT = prof_lt;  filt_E = prof_e;
     
    filt_LT(filt ~= 1) = NaN; filt_E(filt ~= 1) = NaN;

end