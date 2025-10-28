%% Isis Alonso-Lozares 16-06-21 script to combine data from different animals
% NM updated (with Gemini) for social reward experiment 02-09-25

clear all;
% close all; % Good practice to close any open figures

% --- 1. Setup ---
tankfolder = 'C:\Photometry\Social_045 Photom\2025_R1\Both_(-20_+20)';

% Pre-initialize matrices to hold the aggregated data from ALL files.
% It's good practice to initialize them, even if they start empty.
L_Choice_Alcohol = [];
L_Choice_Social  = [];
R_Choice_Alcohol = [];
R_Choice_Social  = [];

% Define the session identifiers
early = {'C1', 'C2'};
late  = {'L1', 'L2'};
pun = {'P1', 'P2', 'P3','P4'};

% Get a list of only the .mat files in the folder. This is cleaner
% than getting all files and then removing the '.' and '..' directories.
files = dir(fullfile(tankfolder, '*.mat'));

% --- 2. Main Loop: Iterate Through Each File ---
for i = 1:length(files)
    fprintf('Processing file %d of %d: %s\n', i, length(files), files(i).name);

    % Load the data from the current file.
    % Specifying 'sesdat' can make loading faster if files are large.
    load(fullfile(files(i).folder, files(i).name), 'sesdat');

    % Extract variables for clarity
    traces = sesdat.traces_z;
    sex = sesdat.sex;
    ses = sesdat.ses;
    hemi = sesdat.hemi;

    % Determine if sex is 'Male' or 'Female' once per file
    isLeft = any(strcmp(hemi, 'Left'));
    isRight = any(strcmp(hemi, 'Right'));
    
    % Determine if this session is 'early' or 'late' once per file
    isEarlySession = any(ismember(ses, early));
    isLateSession = any(ismember(ses, late));
    isPunSession = any(ismember(ses, pun));

    % --- 3. Vectorized Data Extraction (replaces the inner 'j' loop) ---
    
    % Create logical masks to find all rows meeting the criteria at once
    is_alcohol   = traces(:, 2) == 1;
    is_social    = traces(:, 2) == 2;
    
    % Use the masks to extract the data for the CURRENT file and append
    % the entire block of new rows to the main matrices.
    if isLeft && isLateSession
        L_Choice_Alcohol = [L_Choice_Alcohol; traces(is_alcohol, 5:end)];
        L_Choice_Social  = [L_Choice_Social;  traces(is_social, 5:end)];
        
    elseif isRight && isLateSession
        R_Choice_Alcohol = [R_Choice_Alcohol; traces(is_alcohol, 5:end)];
        R_Choice_Social  = [R_Choice_Social;  traces(is_social, 5:end)];
    end
end

fprintf('✅ Data processing complete.\n');


 %% 

% =========================================================================
% Main Analysis and Plotting Script
% =========================================================================
% This script assumes that the data from the previous step has been loaded
% and the following matrices are available in the workspace:
% S1_Choice_Alcohol, S1_Choice_Social
% S2_Choice_Alcohol, S2_Choice_Social
%
% NOTE: This script requires your custom helper functions to be on the
% MATLAB path:
%   - bootstrap_data.m
%   - CIadjust.m
%   - permTest_array.m
%   - consec_idx.m
%   - jbfill.m
% =========================================================================

% --- 1. Plotting Configuration ---

% Define a color palette to use for the plots
colors.social_left = [1, 0.34, 0.13];   % Orange
colors.social_right = [0.8, 0.0, 0.0];    % Dark Red
colors.alcohol_left = [0.01, 0.66, 0.96]; % Light Blue
colors.alcohol_right = [0.0, 0.2, 0.7];    % Dark Blue
colors.black        = [0.25, 0.25, 0.25]; % For permutation markers

% Define time vector for the x-axis (-10s to +10s)
% This assumes all data matrices have the same number of columns.
time_vector = linspace(-20, 20, size(L_Choice_Social, 2));

% Define statistical parameters
p_value_threshold = 0.01; % p-value for permutation test significance
consecutive_points_threshold = 8; % Min number of consecutive points for significance

% --- 2. Generate the Four Comparison Plots ---

fprintf('Generating comparison plots...\n');
y_axis_range = [-2, 8]; % Define the desired range [min, max]

% Plot 1: Social Choice (L vs. R)
[social_sig_windows] = createComparisonPlot(L_Choice_Social, R_Choice_Social, ...
    'L Social', 'R Social', ...
    colors.social_left, colors.social_right, colors.black, ...
    'Social Choice: L vs. R', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Plot 2: Alcohol Choice (L vs. R)
[alcohol_sig_windows] = createComparisonPlot(L_Choice_Alcohol, R_Choice_Alcohol, ...
    'Left Alcohol', 'Right Alcohol', ...
    colors.alcohol_left, colors.alcohol_right, colors.black, ...
    'Alcohol Choice: L vs. R', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Plot 3: Left Sessions (Social vs. Alcohol)
[left_sig_windows] = createComparisonPlot(L_Choice_Social, L_Choice_Alcohol, ...
    'Left Social', 'Left Alcohol', ...
    colors.social_left, colors.alcohol_left, colors.black, ...
    'Left: Social vs. Alcohol Choice', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Plot 4: Right Sessions (Social vs. Alcohol)
[right_sig_windows] = createComparisonPlot(R_Choice_Social, R_Choice_Alcohol, ...
    'Right Social', 'Right Alcohol', ...
    colors.social_right, colors.alcohol_right, colors.black, ...
    'Right: Social vs. Right Choice', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

fprintf('✅ All plots generated.\n');
