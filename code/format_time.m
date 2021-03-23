
function [timeString] = format_time(timeInSecs)
%==========================================================================
% File: format_time.m
% Author: Mohsen Ghazel 
% Date: Mar 12, 2021 
%==========================================================================
% Specifications: 
%==========================================================================
% - This function converts and formats the input time from seconds to 
%   hours, minutes, seconds
% - This utility function used to format the execution time of the program
%==========================================================================
% Intput:
%==========================================================================
% - timeInSecs: time in seconds
%==========================================================================
% Output:
%==========================================================================
%  - timeString: time formatted in hours, minutes, seconds
%--------------------------------------------------------------------------
% Execution: 
%
% >> [timeString] = format_time(timeInSecs)
%
%==========================================================================
% History
%==========================================================================
% Date                      Changes
%--------------------------------------------------------------------------
% March 12th, 2021        Initial definition
%==========================================================================
% License
%==========================================================================
% MIT License: Free to copy, use, modify, share and redistribute.
% Copyright (c) 2021 mghazel2020
%==========================================================================
%--------------------------------------------------------------------------
% Step 1: Initialize the ouput variables
%--------------------------------------------------------------------------
timeString = '';

%--------------------------------------------------------------------------
% Step 2: Initialize local variables
%--------------------------------------------------------------------------
% number of hours
numHours = 0;

% number of minutes
numMins = 0;

%--------------------------------------------------------------------------
% Step 3: Format the time from seconds to  hours, minutes, seconds
%--------------------------------------------------------------------------
% 3.1) check if input time is longer than 3600 seconds (1 hours)
%--------------------------------------------------------------------------
if ( timeInSecs >= 3600 ) % if time is more than one hour
    % compute the number of hours (integer division)
    numHours = floor(timeInSecs/3600);
    % if more then 1 hour, then plural (hours)
    if ( numHours > 1 )
        hourString = ' hours, ';
    else % otherwise, then singular (hour)
        hourString = ' hour, ';
    end
    % the time string
    timeString = [num2str(numHours ) hourString];
end
%--------------------------------------------------------------------------
% 3.2) check if input time is longer than 60 seconds (1 minute)
%--------------------------------------------------------------------------
if ( timeInSecs >= 60 ) % if time is more than one minute
    % number of minutes
    numMins = floor((timeInSecs - 3600*numHours)/60);
    if numMins > 1
        minuteString = ' mins, ';
    else
        minuteString = ' min, ';
    end
    timeString = [timeString num2str(numMins) minuteString];
end

%--------------------------------------------------------------------------
% 3.3) the remaining number of seconds
%--------------------------------------------------------------------------
numSecs = timeInSecs - 3600*numHours - 60*numMins;

%--------------------------------------------------------------------------
% 3.4) the final formatted time string
%--------------------------------------------------------------------------
timeString = [timeString sprintf('%2.1f', numSecs) ' secs'];

% return
return;

end


