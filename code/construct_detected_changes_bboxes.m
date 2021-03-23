function [status, detected_bboxes] = construct_detected_changes_bboxes(change_mask, frame_img, bbox_min_area, frame_counter, output_folder, display_flag)
%==========================================================================
% Project: Moving object detection and tracking for fixed camera data
%==========================================================================
% File: construct_detected_changes_bboxes.m
% Author: Mohsen Ghazel (mghazel2020)
% Date: Mar 12, 2021 
%==========================================================================
% Specifications: 
%==========================================================================
% To constructed the bounding boxes from the detected changes mask
%==========================================================================
% Input:
%==========================================================================
% - change_mask: the input change mask
% - frame_img: the input frame image
% - bbox_min_are: the minimum area of the bounding box to be acceptable
% - frame_counter: the frame counter
% - output_folder: the output folder
% - display_flag: a display and save flag( 1: display and save the results,
%   0, otherwise)
%==========================================================================
% Output:
%==========================================================================
%  - status: Execution status (1: Success, 0: Failure)
%  - detected_bboxes: an array fo the detected bounding-boxes
%==========================================================================
% Execution: 
%
% >> [status] = construct_detected_changes_bboxes()
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
% initialize the detected bounding-boxes
detected_bboxes = [];

%--------------------------------------------------------------------------
% Set display to visible
%--------------------------------------------------------------------------
set(0,'DefaultFigureVisible','on');
%--------------------------------------------------------------------------
% simple bounding-box construction
%--------------------------------------------------------------------------
% Aply morphological operation on the change mask
se = strel('disk',10);
J = imclose(change_mask, se); 
% set the window size
windowSize = 11;
kernel = ones(windowSize) / windowSize ^ 2;
blurryImage = conv2(single(J), kernel, 'same');
binaryImage = blurryImage > 0.5; % Rethreshold
J = binaryImage;
% save the post-processed mask
change_mask_new = J;
% detcet the bounding-boxes
[B,L] = bwboundaries(change_mask_new, 'noholes');
%------------------------------------------------------------------
% display bboxes detection results:
%------------------------------------------------------------------
h601 = figure(601); 
subaxis(2,2,1, 'Spacing', 0.02, 'Padding', 0.03, 'Margin', 0.025);
subplot(2,2,1), imshow(binaryImage); title('Contours', 'FontSize',7); hold on;
subaxis(2,2,2, 'Spacing', 0.02, 'Padding', 0.03, 'Margin', 0.025);
subplot(2,2,2), imshow(frame_img); title('Contours', 'FontSize', 7);hold on;
for k = 1:length(B)
   boundary = B{k};
   area = polyarea(boundary(:,2),boundary(:,1));
   if ( area > bbox_min_area )
        subplot(2,2,1), plot(boundary(:,2),boundary(:,1),'g','LineWidth',2); hold on;
        subplot(2,2,2), plot(boundary(:,2),boundary(:,1),'g','LineWidth',2); hold on;
   end
end
% diusplay results
subplot(2,2,1),hold off
subplot(2,2,2),hold off

% method-002
fg1 = J;  
subaxis(2,2,3, 'Spacing', 0.02, 'Padding', 0.03, 'Margin', 0.025);
subplot(2,2,3), imshow(J); title('Bounding-Boxes', 'FontSize', 7); hold on;
subaxis(2,2,4, 'Spacing', 0.02, 'Padding', 0.03, 'Margin', 0.025);
subplot(2,2,4), imshow(frame_img); title('Bouding-Boxes', 'FontSize', 7); hold on;
% figure(3);imshow(fg1);
% drawnow;
% hold on;
labeledImage = bwconncomp(fg1,8);
measurements = regionprops(labeledImage,'BoundingBox', 'Centroid', 'Area');
totalNumberOfBlobs = length(measurements);
for blobNumber = 1:totalNumberOfBlobs
    bb = measurements(blobNumber).BoundingBox;
    bco = measurements(blobNumber).Centroid;
    area = measurements(blobNumber).Area;
    %----------------------------------------------------------------------
    % Overlay the deccted contours and b-boxes on the change mask and the
    % original image:
    %----------------------------------------------------------------------
    subplot(2,2,3), rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
    subplot(2,2,4), rectangle('Position',bb,'EdgeColor','g','LineWidth',2)  
    % save bbox
    bbox = [bb(1) bb(2) bb(3) bb(4)];
    detected_bboxes = [detected_bboxes; bbox ];
%--------------------------------------------------------------------------
% Only plot regions with sufficiently large areas
%--------------------------------------------------------------------------
%     if ( area > bbox_min_area )
%         subplot(2,2,3), rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
%         subplot(2,2,4), rectangle('Position',bb,'EdgeColor','g','LineWidth',2)  
%         % save bbox
%         bbox = [bb(1) bb(2) bb(3) bb(4)];
%         detected_bboxes = [detected_bboxes; bbox ];
%     end
%--------------------------------------------------------------------------
end
% save the figure
if ( display_flag == 1 )
    f_name = [output_folder 'detections_' num2str(frame_counter) '.jpg'];
    saveas(h601, f_name);
end
% hold off
hold off
% close all open figures
close('all');
% display the number of detected bboxes
fprintf('The number of detected change detection bboxes = %d\n', size(detected_bboxes, 1));

% set execution status: 1: Success
status = 1;

% return
end
