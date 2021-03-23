function [status, cross_correlation_img] = compute_cross_correlation_between_two_images(img1, img2, filter_size)
%==========================================================================
% Project: Moving object detection and tracking for fixed camera data
%==========================================================================
% File: compute_cross_correlation_between_2_images.m
% Author: Mohsen Ghazel (mghazel2020)
% Date: Mar 12, 2021 
%==========================================================================
% Specifications: 
%==========================================================================
% To Compute the cross-correlation image between the current frame
% image and the background image:
%==========================================================================
% - Area where there is no change:
% 
%    - We expect high-correlation betwene the background and foreground
%      images
%
% - Area where there are changes:
% 
%    - We expect low-correlation between the background and foreground
%      images
%
% - So the squared correlation r^2 is expected to be:
%
%   - High over areas of no-change
%   - Low over areas of change
%
% - Taking the complement, we expect: 1 - r^2 to be:
%
%   - Low over areas of no-change
%   - High over areas of change
%
% - Hence, this should serve as a good change/motion detector.   
%==========================================================================
% Input:
%==========================================================================
% - img1: the first image
% - img2: the second image
% - filter_size: the cross-correlation filter size
%==========================================================================
% Output:
%==========================================================================
%  - status: Execution status (1: Success, 0: Failure)
%  - cross_correlation_img: the computed cross-correlation between the 2
%    images.
%==========================================================================
% Execution: 
%
% >> [status] = compute_cross_correlation_between_2_images()
%
%==========================================================================
% History
%==========================================================================
% Date                      Changes                        Author
%==========================================================================
% Mar 12, 2021              Initial definition             mghazel2020
%==========================================================================
% MIT License:
%==========================================================================
% Copyright (c) 2018-2020 mghazel2020
%==========================================================================
%--------------------------------------------------------------------------
% Initialize the output variables
%--------------------------------------------------------------------------
% execution status (1: Success, 0: Failure)
status = 1;
% Initialize the cross_correlation_img to zeros
cross_correlation_img = zeros(size(img1, 1), size(img1, 2));

%--------------------------------------------------------------------------
% Set display to visible
%--------------------------------------------------------------------------
set(0,'DefaultFigureVisible','on');

%--------------------------------------------------------------------------
% Set the cross-correlation filter size
%--------------------------------------------------------------------------
% the cross-correlation filter-size
cc_filter_size  = filter_size * filter_size;

%--------------------------------------------------------------------------
% Iterate a sliding-window over the images
%--------------------------------------------------------------------------
% iterate over the rows
for row = 3: size(img1, 1) - 1
    % iterate over the cols
    for col = 3: size(img1, 2) - 2
        %------------------------------------------------------------------
        % Set the the sliding window
        %------------------------------------------------------------------
        b_x = img1(row-2:row+1, col-2:col+2);
        b_y = img2(row-2:row+1, col-2:col+2);
        
        %------------------------------------------------------------------
        % Compute the required sums to compute the cross-correlation
        %------------------------------------------------------------------
        % sum of x*y
        s_xy = sum(sum(b_x.*b_y));
        % sum of x
        s_x = sum(sum(b_x));
        % sum of x^2
        s_x2 = sum(sum(b_x.^2));
        % sum of y
        s_y = sum(sum(b_y));
        % sum of y^2
        s_y2 = sum(sum(b_y.^2));
        
        %------------------------------------------------------------------
        % Compute the correlation coefficient
        %------------------------------------------------------------------
        r = (cc_filter_size  * s_xy - s_x * s_y ) / sqrt( ( cc_filter_size  * s_x2 - (s_x^2) ) * ( cc_filter_size  * s_y2 - (s_y^2) ) );
        % truncate r between -1 and 1
        r = min([max([r -1]) 1]);
        %------------------------------------------------------------------
        % Transform the cross-correlation to: 1 - r^2
        %------------------------------------------------------------------
        % - High values indicate changes
        cross_correlation_img(row, col) = 1 - r^2;
    end
end
% close all figures
close('all');

% set execution status: 1: Success
status = 1;

% return 
return;

end