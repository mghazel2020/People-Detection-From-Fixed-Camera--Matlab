function [status] = moving_objects_detection_tracking_for_fixed_camera_data()
%==========================================================================
% Project: Moving object detection and tracking for fixed camera data
%==========================================================================
% File: moving_objects_detection_tracking_for_fixed_camera_data.m
% Author: Mohsen Ghazel (mghazel2020)
% Date: Mar 12, 2021 
%==========================================================================
% Change Detection Approach:
%==========================================================================
% The implemented approach for detecting changes from fixed camera imagery
% can be outlined as follows: 
%--------------------------------------------------------------------------
%  - Given a new frame acquired at current time = t: F(t)
%--------------------------------------------------------------------------
%  Step 1: Estimate the background image at current time = t: B(t) 
%          - We explore 3 background estimation methods:
%-------------------------------------------------------------------------- 
%          Method-01: B(t) = The first frame, known to contain no objects
%                            not belonging to the images scene.
%          Method-02: B(t) = The last frame, with no detected changes, 
%                     acquired prior time t.
%          Method-04: B(t)= Average all the frames, with no detected changes, 
%                     acquired prior time t
%          Method-04: B(t) = Average all the frames acquired prior time t
%--------------------------------------------------------------------------
%  Step 2: Detect the change C(t) between the current frame time = t and the
%  estimated background frame, as obtained in Step 1, above:
%          - We explore 2 change detection methods:
%--------------------------------------------------------------------------     
%          Method-01: Simple background absolute subtraction between the 
%                     current frame F(t) and the background frame B(t):
%
%                     C(t) = ABS(F(t) - B(t))                     
%            
%          Method-02: The cross-correlation between the the 
%                     current frame F(t) and the background frame B(t):
%
%                     C(t) = cross-correlation(F(t), B(t)))                     
%==========================================================================
% Input:
%==========================================================================
% - None
%==========================================================================
% Output:
%==========================================================================
%  - status = 1 for success and -1 for failure
%==========================================================================
% Execution: 
%
% >> [status] = moving_objects_detection_tracking_for_fixed_camera_data()
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
% clear the screen
clc;
% close all open figures
close('all');
% suppress any warnings
warning('off');
% the execution status
status = 0;

%--------------------------------------------------------------------------
% Set display to visible
%--------------------------------------------------------------------------
set(0,'DefaultFigureVisible','on');

%--------------------------------------------------------------------------
% display a message indicating the start of the execution
%--------------------------------------------------------------------------
fprintf(1,'===============================================================\n');
fprintf(1,'moving_objects_detection_tracking_for_fixed_camera_data:\n');
fprintf(1,'===============================================================\n');
fprintf(1,'Author: mghazel2020\n');
fprintf(1,'===============================================================\n');
fprintf(1,'Execution date and time: %s\n', datestr(now,'mmmm dd, yyyy HH:MM:SS.FFF AM'));
fprintf(1,'===============================================================\n');

%--------------------------------------------------------------------------
% Add the path to the utilities functions
%--------------------------------------------------------------------------
% add the path to the utilities functions 
addpath('.\utilities\subaxis');
addpath('.\utilities\natsortfiles');

%==========================================================================
% Start of execution
%==========================================================================
% - Keep track of the start of execution in order to compute the total
%   execution time of the program
%--------------------------------------------------------------------------
tic;
    
%==========================================================================
% Set the input folder 
%==========================================================================
% data folder
data_folder = 'C:\MyGitHub\MyRepositories\Today\Object-Detection-Tracking-Fixed-Camera--Matlab\data\PETS2006\input\';

%==========================================================================
% Set the output folders:
%==========================================================================
% output folder
output_folder = 'C:\MyGitHub\MyRepositories\Today\Object-Detection-Tracking-Fixed-Camera--Matlab\results\';

% date-stamp
date_stamp = date;
% create a sub-directory
output_folder = strcat([output_folder date_stamp  '\']);
% create the directory if it does not exist
if ( exist(output_folder, 'dir') ~= 7 )
    mkdir(output_folder);
end

%==========================================================================
% Set the algorithms paramaters:
%==========================================================================
% Correlation filter size
%--------------------------------------------------------------------------
% coerreation filter size
filter_size = 5;

%--------------------------------------------------------------------------
% Detected changes threshold:
%--------------------------------------------------------------------------
% Method-01: Background-subtraction:
%--------------------------------------------------------------------------
% - This is the threshold on the computed cross-correlation between 2
%   images
% - Any changes less than this are filtered out
%--------------------------------------------------------------------------
background_subtraction_change_threshold = 0.25;
%--------------------------------------------------------------------------
% Method-02: Cross-correlation:
%--------------------------------------------------------------------------
% - This is the threshold on the computed cross-correlation between 2
%   images
% - Any changes with cross-correletauon less than this are filtered out
%--------------------------------------------------------------------------
cross_correlation_change_threshold = 0.25;

%--------------------------------------------------------------------------
% Detected changes bounding-boxes properties:
%--------------------------------------------------------------------------
% - Thresholds on the sizes of the detected bounding boxes
% - Any detected boundin0boxes that don't meet these size requirements 
%   are filtered.
%--------------------------------------------------------------------------
% minimum acceptable size of the bounding-box
% minimum bbox height
bbox_min_height = 25;
% minimum bbox width
bbox_min_width = 25;
% minimum bbox area
bbox_min_area = 625;
% minium aspect ratio
min_aspect_ratio = 1.25;
% a buffer added around the detectedd bbox
bbox_buffer = 5;
%==========================================================================
% Change Detection Approach:
%==========================================================================
% The implemented approach for detecting changes from fixed camera imagery
% can be outlined as follows:
% 
%--------------------------------------------------------------------------
%  - Given a new frame acquired at current time = t: F(t)
%--------------------------------------------------------------------------
%  Step 1: Estimate the background image at current time = t: B(t) 
%          - We explore 3 background estimation methods:
%-------------------------------------------------------------------------- 
%          Method-01: B(t) = The first frame, known to contain no objects
%                            not belonging to the images scene.
%          Method-02: B(t) = The last frame, with no detected changes, 
%                     acquired prior time t.
%          Method-04: B(t)= Average all the frames, with no detected changes, 
%                     acquired prior time t
%          Method-04: B(t) = Average all the frames acquired prior time t
%--------------------------------------------------------------------------
%  Step 2: Detect the change C(t) between the current frame time = t and the
%  estimated background frame, as obtained in Step 1, above:
%          - We explore 2 change detection methods:
%--------------------------------------------------------------------------     
%          Method-01: Simple background absolute subtraction between the 
%                     current frame F(t) and the background frame B(t):
%
%                     C(t) = ABS(F(t) - B(t))                     
%            
%          Method-02: The cross-correlation between the the 
%                     current frame F(t) and the background frame B(t):
%
%                     C(t) = cross-correlation(F(t), B(t)))                     
%-------------------------------------------------------------------------- 

%--------------------------------------------------------------------------
% Set the number of skipped frames used to estimate the background:
%--------------------------------------------------------------------------
% - Changes are only detected after this number of frames
%--------------------------------------------------------------------------
% the number of skipped frames
num_skipped_frames = 10;

%--------------------------------------------------------------------------
% A flag to save the results
%--------------------------------------------------------------------------
% set the display flag to 1 to ave the figures
display_flag = 1;

%==========================================================================
% Get the frames in the input folder
%==========================================================================
%--------------------------------------------------------------------------
% get the image list of input JPEG images in the input folder
%--------------------------------------------------------------------------
files_list = dir([data_folder '\*.jpg']);

% list of images
srcFiles = natsortfiles(cellstr(char(files_list(1:end).name)));

% number of frames
num_frames = length(srcFiles);

% the number of change-free frames
num_change_free_frames = 1;

%==========================================================================
% Initialize the background image to the first image:
%==========================================================================
% - convert it to double and scale from 0 to 1
% - convert it to grayscale
%--------------------------------------------------------------------------
% first image file name 
f_name = char(srcFiles{1});
% the full-path image file name
fname = [ data_folder f_name ];

% read the image file
img = imread(fname);
    
% convert image to grayscale if it is color
if ( size(img, 3) > 1 )
    img = rgb2gray(img);
end

% frame size
[nrows, ncols, nchannels] = size(img);

% initialize the background to the first image
estimated_background_image = im2double(img);

%--------------------------------------------------------------------------
% make a copy of this initial background image, selcetd to be the first 
% the first image, which known to not conatain any objects not belonging to
% the imaged scene.
%--------------------------------------------------------------------------
% the first frame 
first_frame_background_image = estimated_background_image;
% the last change-free estimated background-frame
last_change_free_background_frame = estimated_background_image;
% the average of the change-free frames
average_change_free_frames_background_frame = estimated_background_image;

% the numbe ro fprocessed frames
num_procesed_frames = 250;
%==========================================================================
% Start processing all the input images:
%==========================================================================
% Iterater over all the input images
for frame_counter = 1 : num_procesed_frames
    %======================================================================
    % Step 1: Read the next input image
    %======================================================================
    fprintf(1, '===========================================================\n');
    fprintf(1, 'Step 1: Read the next input image:\n');
    fprintf(1, '===========================================================\n');
    % file name
    fname0 = char(srcFiles{frame_counter});
    % Display a message
    fprintf(1, '-----------------------------------------------------------\n');
    fprintf(1, 'Processing image # %d of %d with file name = %s\n', frame_counter, num_procesed_frames, fname0);
    fprintf(1, '-----------------------------------------------------------\n');
    
    % the full-path file name
    fname = strcat(data_folder, fname0);
    
    % read the image file
    original_img = imread(fname);
    
    %======================================================================
    % Step 2: Set the current frame as the foreground frame:
    %         - Convert image to grascale if needed
    %======================================================================
    fprintf(1, '===========================================================\n');
    fprintf(1, 'Step 2: Set the current frame as the foreground frame:\n');
    fprintf(1, '===========================================================\n');
    if ( size(original_img, 3) > 1 )
       img = rgb2gray(original_img);
    end
    % convert to double
    foreground_frame = im2double(img);
    
    %======================================================================
    % Step 3: Estimate the background frame
    %======================================================================
    %  - Given a new frame acquired at current time = t: F(t)
    %----------------------------------------------------------------------
    %  Step 1: Estimate the background image at current time = t: B(t) 
    %          - We explore 3 background estimation methods:
    %---------------------------------------------------------------------- 
    %          Method-01: B(t) = The first frame, known to contain no 
    %                            objects not belonging to the images scene.
    %          Method-02: B(t) = The last frame, with no detected changes, 
    %                     acquired prior time t.
    %          Method-04: B(t)= Average all the frames, with no detected  
    %                     achanges, acquired prior time t
    %          Method-04: B(t) = Average all the frames acquired prior
    %                     to time t.
    %----------------------------------------------------------------------
    fprintf(1, '===========================================================\n');
    fprintf(1, 'Step 3: Estimate the background frame:\n');
    fprintf(1, '===========================================================\n');
    % number ofbackground estimation methods
    num_background_estimation_methods = 4;
    % Iterate over the background-estimation method
    for background_estimation_method = 1:4
        fprintf(1, '\t>Background-estimation method # %d of %d:\n', background_estimation_method, num_background_estimation_methods);
        %------------------------------------------------------------------
        % Method-01: B(t) = The first frame, known to contain no objects
        %                   not belonging to the images scene.
        %------------------------------------------------------------------
        if ( background_estimation_method == 1 )
            estimated_background_image = first_frame_background_image;
        %------------------------------------------------------------------
        % Method-02: B(t) = The last frame, with no detected changes, 
        %                   acquired prior time t.
        %------------------------------------------------------------------
        elseif ( background_estimation_method == 2 )
            %--------------------------------------------------------------
            % keep using the first frame up to: num_skipped_frames since no
            % changes are detectc for teh first 
            % num_skipped_frames frames.
            %--------------------------------------------------------------
            if ( frame_counter <= num_skipped_frames )
                %----------------------------------------------------------
                % set the estimated background frame to the 
                % first_frame_background_image
                %----------------------------------------------------------
                estimated_background_image = first_frame_background_image;
            else
                %----------------------------------------------------------
                % set the estimated background frame to the 
                % last_frame_background_image: the last frame with no
                % detected changes.
                %----------------------------------------------------------
                estimated_background_image = last_change_free_background_frame;
            end
        %------------------------------------------------------------------
        % Method-03: B(t)= Average all the frames, with no detected changes, 
        %                  acquired prior time t
        %------------------------------------------------------------------
        elseif ( background_estimation_method == 3 )
            %--------------------------------------------------------------
            % set the estimated background frame to the 
            % last_frame_background_image: the last frame with no
            % detected changes.
            %--------------------------------------------------------------
            estimated_background_image = average_change_free_frames_background_frame;
        %------------------------------------------------------------------
        % Method-04: B(t)= Average all the frames, with no detected changes, 
        %                  acquired prior time t
        %------------------------------------------------------------------
        elseif ( background_estimation_method == 4 )
            %--------------------------------------------------------------
            % - Update all the pixels of the background frame using the 
            %   average of all previous frames.
            %--------------------------------------------------------------
            estimated_background_image = ((frame_counter - 1) * estimated_background_image + foreground_frame) / frame_counter;
        %------------------------------------------------------------------
        % Handle invalid background_estimation_method option:
        %------------------------------------------------------------------
        else
            % display amessage
            fprintf(1, '---------------------------------------------------\n');
            fprintf(1, 'Error: Invalid value of: background_estimation_method = %d\n', background_estimation_method);
            fprintf(1, '       - Valid values of background_estimation_method = 1, 2, 3 or 4!\n');
            fprintf(1, '---------------------------------------------------\n');
            % set status to failure
            status = -1;
            % return
            return;
        end
        %------------------------------------------------------------------
        % Save the background image, if desired
        %------------------------------------------------------------------
        if ( display_flag == 1 )
            %--------------------------------------------------------------
            % create an output sub-folder to store the detection results
            %--------------------------------------------------------------
            estimated_background_folder = [output_folder 'estimated-background-method-' num2str(background_estimation_method) '\'];
            % create the directory if it does not exist
            if ( exist(estimated_background_folder, 'dir') ~= 7 )
                % make directory
                mkdir(estimated_background_folder);
            end
            % craret a new figure
            h10 = figure(10);
            % display the image
            imshow(estimated_background_image);
            % background image file-name
            estimated_background_fname = [estimated_background_folder 'frame-' num2str(frame_counter) '.jpg'];
            % save the background image
            saveas(h10, estimated_background_fname );
            % close all figures
            close('all');
        end
        %------------------------------------------------------------------
        % Don't detect changes for the first num_skipped_frames frames
        %------------------------------------------------------------------
        % - Use the first num_skipped_frames frames to estimate the 
        %   background  frame.
        %------------------------------------------------------------------
        if ( frame_counter <= num_skipped_frames )
            continue;
        end
        
        %==================================================================
        %  Step 4: Detect the change C(t) between the current frame 
        %          time = t and the estimated background frame, as obtained 
        %          above:
        %        - We explore 2 change detection methods:
        %==================================================================
        %          Method-01: Simple background absolute subtraction 
        %                     between the current frame F(t) and the 
        %                     background frame B(t):
        %
        %                     C(t) = ABS(F(t) - B(t))                     
        %            
        %          Method-02: The cross-correlation between the the 
        %                     current frame F(t) and the background 
        %                     frame B(t):
        %
        %                     C(t) = cross-correlation(F(t), B(t)))                     
        %------------------------------------------------------------------
        fprintf(1, '=======================================================\n');
        fprintf(1, 'Step 4: Detect the changes:\n');
        fprintf(1, '=======================================================\n');
        %------------------------------------------------------------------
        % Iterate over the 2 change detection methods:
        %------------------------------------------------------------------
        % create an output sub-folder to store the detceted changes
        %------------------------------------------------------------------
        detected_changes_folder = [output_folder 'detected-changes--background-method-' num2str(background_estimation_method) '\'];
        % create the directory if it does not exist
        if ( exist(detected_changes_folder, 'dir') ~= 7 )
            % make directory
            mkdir(detected_changes_folder);
        end
            
        % number of change detection methods
        num_change_detection_methods = 2;
        % Iterate over the background-estimation method
        for change_detection_method = 1: num_change_detection_methods
            fprintf(1, '\t\t>Change detecion method # %d of %d:\n', change_detection_method,  num_change_detection_methods);
            %--------------------------------------------------------------
            % Method-01: Simple background absolute subtraction 
            %                     between the current frame F(t) and the 
            %                     background frame B(t):
            %
            %                     C(t) = ABS(F(t) - B(t))        
            %--------------------------------------------------------------
            if ( change_detection_method == 1 )
                % change detection via background-subtraction
                background_subtraction_change = abs(foreground_frame - estimated_background_image);
                %----------------------------------------------------------
                % Detect the changes between the current foreground image and
                % the computed background image based on the cross-correlation 
                % between them:
                %----------------------------------------------------------
                % Threshold the background_subtraction_change image to detect the changes
                detected_change_mask = ( background_subtraction_change >= background_subtraction_change_threshold );
                % display the changes
                h10 = figure(10);
                subplot(1,2,1), imshow(background_subtraction_change);
                subplot(1,2,1), title('Background subtraction','Fontsize', 7);
                subplot(1,2,2), imshow(detected_change_mask);
                subplot(1,2,2), title('Thresholded background subtraction mask','Fontsize', 7);
                % save the figure
                saveas(h10, [detected_changes_folder 'background-subtration-change-detection_frame_' num2str(frame_counter) '.jpg']);
                % close all figures
                close('all');
            %--------------------------------------------------------------
            % Method-02: The cross-correlation between the the 
            %                     current frame F(t) and the background 
            %                     frame B(t):
            %
            %                     C(t) = cross-correlation(F(t), B(t)))      
            %------------------------------------------------------------------
            elseif ( change_detection_method == 2 )
                %----------------------------------------------------------------------
                % Step 6: Compute the cross-correlation image between the current frame
                % image and the background image:
                %----------------------------------------------------------------------
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
                %----------------------------------------------------------------------
                % compute the cross-correlation
                [status, cross_correlation_image] = compute_cross_correlation_between_two_images(foreground_frame, estimated_background_image, filter_size);
                % check the excution status
                if ( status ~= 1 )
                    % display a message
                    fprintf(1, '-------------------------------------------------------\n');
                    fprintf(1, 'Error: compute_cross_correlation_between_two_images(...) FAILED!\n');
                    fprintf(1, 'Returning with execution status = %d\n', status);
                    fprintf(1, '-------------------------------------------------------\n');
                    % return
                    return;
                end
                %--------------------------------------------------------------
                % Detect the changes between the current foreground image and
                % the computed background image based on the cross-correlation 
                % between them:
                %--------------------------------------------------------------
                % Threshold the correlation image to detect the changes
                detected_change_mask = ( cross_correlation_image >= cross_correlation_change_threshold );
                % display the changes
                h10 = figure(10);
                subplot(1,2,1), imshow(cross_correlation_image);
                subplot(1,2,1), title('Cross-correlation: 1 - r^2','Fontsize', 7);
                subplot(1,2,2), imshow(detected_change_mask);
                subplot(1,2,2), title('Thresholded Cross-correlation: 1 - r^2 mask','Fontsize', 7);
                saveas(h10, [detected_changes_folder 'cross-correlation-change-detection_frame_' num2str(frame_counter) '.jpg']);
                % orient landscape
                orient landscape
                % close all figures
                close('all');
            %------------------------------------------------------------------
            % Handle invalid change_detection_method option:
            %------------------------------------------------------------------
            else
                % display amessage
                fprintf(1, '---------------------------------------------------\n');
                fprintf(1, 'Error: Invalid value of: change_detection_method = %d\n', background_estimation_method);
                fprintf(1, '       - Valid values of change_detection_method = 1 or 2!\n');
                fprintf(1, '---------------------------------------------------\n');
                % set status to failure
                status = -1;
                % return
                return;
            end
            %==============================================================
            % Step 5: Construct bounding-boxes for the detected changes:
            %==============================================================
            fprintf(1, '===================================================\n');
            fprintf(1, 'Step 5: Construct bounding-boxes for the detected changes:\n');
            fprintf(1, '===================================================\n');
            %--------------------------------------------------------------
            % create an output sub-folder to store the detection results
            %--------------------------------------------------------------
            bbox_detection_results_folder = [output_folder 'detected-changes-bboxes--background-method-' num2str(background_estimation_method) '--change-method-' num2str(change_detection_method)  '\'];
            % create the directory if it does not exist
            if ( exist(bbox_detection_results_folder, 'dir') ~= 7 )
                % make directory
                mkdir(bbox_detection_results_folder);
            end
            % set the display flag to 1
            display_flag = 1;
            % Call the functionality to construct bounding-boxes for the detected changes
            [status, detected_bboxes] = construct_detected_changes_bboxes(detected_change_mask, original_img, bbox_min_area, frame_counter,  bbox_detection_results_folder, display_flag);
            % check the excution status
            if ( status ~= 1 )
                % display a message
                fprintf(1, '-------------------------------------------------------\n');
                fprintf(1, 'Error: construct_detected_changes_bboxes(...) FAILED!\n');
                fprintf(1, 'Returning with execution status = %d\n', status);
                fprintf(1, '-------------------------------------------------------\n');
                % return
                return;
            else
                % display a message
                fprintf(1, 'construct_detected_changes_bboxes(...) completed successfully!\n');
                fprintf(1, 'The number of detected change b-boxes = %d\n', size(detected_bboxes, 1));
            end
               
            %==============================================================
            % Step 6: Save the final change detection bounding-boxes:
            %==============================================================
            fprintf(1, '===================================================\n');
            fprintf(1, 'Step 6: Save the final change detection bounding-boxes:\n');
            fprintf(1, '===================================================\n');
            %--------------------------------------------------------------
            % create an output sub-folder to store the detection results
            %--------------------------------------------------------------
            all_detected_bboxes_results_folder = [output_folder 'all-detected-bboxes--background-method-' num2str(background_estimation_method) '--change-method-' num2str(change_detection_method)  '\'];
            % create the directory if it does not exist
            if ( exist(all_detected_bboxes_results_folder, 'dir') ~= 7 )
                % create the directory
                mkdir(all_detected_bboxes_results_folder);
            end
            % create a new figure axes
            h10 = figure(10);
            % display current frame image (foreground-frame)
            imshow(original_img);
            % hold on
            hold on
            % iterate over all the bounding-boxes and overlay them on the image
            for bbox_counter = 1: size(detected_bboxes, 1)
                fprintf('Overlaying bbox #: %d of %d on original image\n', bbox_counter, size(detected_bboxes, 1))
                %----------------------------------------------------------
                % bbox coordinates
                %----------------------------------------------------------
                % format: bbox = [x1,y1,w, h]
                %----------------------------------------------------------
                % get the next change detection bbox
                bbox = detected_bboxes(bbox_counter, :);
                
                %------------------------------------------------------------------
                % make sure all bbox coordinates stay within the image
                %------------------------------------------------------------------
                % - Also add buffer around the bbox
                % - buffer added around the detectedd bbox
                %    bbox_buffer = 5;
                %------------------------------------------------------------------
                % x-min
                xmin = floor(min(max(bbox(1) - bbox_buffer, 1), ncols));
                % y-min
                ymin = floor(min(max(bbox(2) - bbox_buffer, 1), nrows));
                % x-max
                xmax = floor(min(max(xmin + bbox(3) + bbox_buffer, 1), ncols));
                % y-max
                ymax = floor(min(max(ymin + bbox(4) + bbox_buffer, 1), nrows));

                %------------------------------------------------------------------
                % Compute the adjusted bbox height and width:
                %------------------------------------------------------------------
                % bbox-width
                bbox_width = xmax - xmin;
                % bbox-height
                bbox_height = ymax - ymin;

                %------------------------------------------------------------------
                % draw the bbox on the current frame
                %------------------------------------------------------------------
                rectangle('Position',[xmin, ymin, bbox_width, bbox_height],'EdgeColor','y', 'LineWidth',3);
            end
            fprintf('The number of overlaid change detection bboxes - BEFORE filtering = %d\n', size(detected_bboxes, 1))
            %--------------------------------------------------------------
            % save the image with bounding-boxes overlay if there are detections
            %--------------------------------------------------------------
            if ( size(detected_bboxes, 1) > 0 && display_flag == 1 )
                % overlay the detectiuons on the image image file-name
                fname = [all_detected_bboxes_results_folder 'detections_frame_' num2str(frame_counter) '.jpg'];
                % save the results if needed
                saveas(h10, fname );
                % hold off
                hold off
                % close all figures
                close('all');
            end

            %==============================================================
            %  Step 7: Filter and save the final change detection
            %  bounding-boxes:
            %==============================================================
            fprintf(1, '===================================================\n');
            fprintf(1, 'Step 7: Filter and save the final change detection bounding-boxes:\n');
            fprintf(1, '===================================================\n');
            % create an output sub-folder to store the detection results
            %--------------------------------------------------------------
            filtered_detected_bboxes_results_folder = [output_folder 'filtered-detected-bboxes--background-method-' num2str(background_estimation_method) '--change-method-' num2str(change_detection_method) '\'];
            % create the directory if it does not exist
            if ( exist(filtered_detected_bboxes_results_folder, 'dir') ~= 7 )
                % create the directory
                mkdir(filtered_detected_bboxes_results_folder);
            end
            % create a new figure axes
            h20 = figure(20);
            % hold on
            hold on
            % display current frame image (foreground-frame)
            imshow(original_img);
            % the number of filtered bboxes
            num_filtered_bboxes = 0;
            % iterate over all the bounding-boxes and overlay them on the image
            for bbox_counter = 1: size(detected_bboxes, 1)
                %----------------------------------------------------------
                % bbox coordinates
                %----------------------------------------------------------
                % format: bbox = [x1,y1,w, h]
                %----------------------------------------------------------
                % get the next bbox
                bbox = detected_bboxes(bbox_counter, :);
                % bbox-width
                bbox_width = bbox(3);
                % bbox-height
                bbox_height = bbox(4);
                % bbox-area
                bbox_area = bbox_width * bbox_height;
                % bbox aspect-ratio
                bbox_aspect_ratio = (1.0 * bbox_height ) / bbox_width;

                %----------------------------------------------------------
                % Filter the detected bboxes to make sure they satify 
                % the following requirements:
                %----------------------------------------------------------
                %  - These requirements filter out small changes that may
                %  be due to noise.
                %----------------------------------------------------------
                %    minimum bbox height
                %    bbox_min_height = 25;
                %    % minimum bbox width
                %    bbox_min_width = 25;
                %    % minimum bbox area
                %    bbox_min_area = 625;
                %    % minium aspect ratio
                %    min_aspect_ratio = 1.25
                %----------------------------------------------------------
                % check if the above criteria are met
                %----------------------------------------------------------
                % - if they are not met, then ignore this change
                %----------------------------------------------------------
                if ( bbox_width < bbox_min_width || bbox_height < bbox_min_height || bbox_area < bbox_min_area || bbox_aspect_ratio < min_aspect_ratio )
                    % ignore this bbox
                    continue;
                end
                
                % Update the number of filtered bboxes
                num_filtered_bboxes =  num_filtered_bboxes  + 1;
                fprintf('Overlaying bbox #: %d on original image\n', num_filtered_bboxes)

                %----------------------------------------------------------
                % Make sure all bbox coordinates stay within the image
                %----------------------------------------------------------
                % - Also a buffer around the bbox
                % - A buffer added around the detectedd bbox
                %    bbox_buffer = 5;
                %----------------------------------------------------------
                % x-min
                xmin = floor(min(max(bbox(1) - bbox_buffer, 1), ncols));
                % y-min
                ymin = floor(min(max(bbox(2) - bbox_buffer, 1), nrows));
                % x-max
                xmax = floor(min(max(xmin + bbox(3) + bbox_buffer, 1), ncols));
                % y-max
                ymax = floor(min(max(ymin + bbox(4) + bbox_buffer, 1), nrows));

                %----------------------------------------------------------
                % Compute the adjusted bbox height and width:
                %----------------------------------------------------------
                % bbox-width
                bbox_width = xmax - xmin;
                % bbox-height
                bbox_height = ymax - ymin;

                %----------------------------------------------------------
                % Draw the bbox on the current frame
                %----------------------------------------------------------
                rectangle('Position',[xmin, ymin, bbox_width, bbox_height],'EdgeColor','g', 'LineWidth',3)
            end
            fprintf('The number of overlaid change detection bboxes - AFTER filtering = %d\n', num_filtered_bboxes)
            %==============================================================
            %  Step 8: Update the background frame for background-frame
            %  for estimation methods # 2 and 3.
            %==============================================================
            fprintf(1, '===================================================\n');
            fprintf(1, 'Step 8: Update the background frame for background-frame for estimation methods # 2 and 3:\n');
            fprintf(1, '===================================================\n');
            %--------------------------------------------------------------
            % If there are significant detected changes in this frame:
            %--------------------------------------------------------------
            % - Save the image with bounding-boxes overlay
            %--------------------------------------------------------------
            if ( num_filtered_bboxes > 0 )
                %----------------------------------------------------------
                % Save the image with bounding-boxes overlay if there are 
                % detections
                %----------------------------------------------------------
                if (  display_flag == 1 )
                    % overlay the detectiuons on the image image file-name
                    fname = [filtered_detected_bboxes_results_folder 'detections_frame_' num2str(frame_counter) '.jpg'];
                    % save the results if needed
                    saveas(h20, fname );
                    % hold off
                    hold off;
                    % close all figures
                    close('all');
                end
            %--------------------------------------------------------------
            % If there are no significant detected changes in this frame:
            %--------------------------------------------------------------
            % - Update the background frame for the following 
            %   bakground-estimation methods:
            %--------------------------------------------------------------
            else
                %----------------------------------------------------------
                % - Update the estimated-bakground frame
                %----------------------------------------------------------
                % - Method-02: B(t) = The last frame, with no detected 
                %                     changes, acquired prior time t.
                %----------------------------------------------------------
                % the last change-free free
                last_change_free_background_frame = foreground_frame;
                %----------------------------------------------------------
                % - Method-03: B(t)= Average all the frames, with no 
                %                    detected changes, acquired prior 
                %                    time t.
                %----------------------------------------------------------
                % the average of change-free frames
                average_change_free_frames_background_frame = num_change_free_frames * average_change_free_frames_background_frame + foreground_frame;
                
                % increment the number of change-free frames
                num_change_free_frames = num_change_free_frames + 1;
                
                % update average_of_change_free_frames_background_frame
                average_change_free_frames_background_frame = average_change_free_frames_background_frame / num_change_free_frames;
            end
        end
    end
end
% clear all figures;
close('all');
% close all files
fclose('all');
% clear all variables
clear all;
% set ststus to success
status = 1;

% return success
return;

end



