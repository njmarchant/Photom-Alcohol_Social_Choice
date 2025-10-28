%% Isis Alonso-Lozares 16-06-21 script to combine data from different animals
% NM updated (with Gemini) for social reward experiment 02-09-25

clear all;
% close all; % Good practice to close any open figures

% --- 1. Setup ---
tankfolder = 'C:\Photometry\Social_045 Photom\2025_R1\Both_(-10_+30)';

% Pre-initialize matrices to hold the aggregated data from ALL files.
% It's good practice to initialize them, even if they start empty.
M_Choice_Alcohol = [];
M_Choice_Social  = [];
M_Choice_Omit    = [];
F_Choice_Alcohol = [];
F_Choice_Social  = [];
F_Choice_Omit    = [];

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


    % Determine if sex is 'Male' or 'Female' once per file
    isMale = any(strcmp(sex, 'Male'));
    isFemale = any(strcmp(sex, 'Female'));

    % Determine if this session is 'early' or 'late' once per file
    isEarlySession = any(ismember(ses, early));
    isLateSession = any(ismember(ses, late));
    isPunSession = any(ismember(ses, pun));

    % --- 3. Vectorized Data Extraction (replaces the inner 'j' loop) ---

    % Create logical masks to find all rows meeting the criteria at once
    valid_trials = (traces(:, 2) == 3) & ~isnan(traces(:, 5));
    is_alcohol   = traces(:, 4) == 1;
    is_social    = traces(:, 4) == 2;
    is_omit      = traces(:, 4) == 0;

    % Use the masks to extract the data for the CURRENT file and append
    % the entire block of new rows to the main matrices.
    if isMale && isPunSession
        M_Choice_Alcohol = [M_Choice_Alcohol; traces(valid_trials & is_alcohol, 5:323)];
        M_Choice_Social  = [M_Choice_Social;  traces(valid_trials & is_social, 5:323)];
        M_Choice_Omit    = [M_Choice_Omit;    traces(valid_trials & is_omit, 5:323)];

    elseif isFemale && isPunSession
        F_Choice_Alcohol = [F_Choice_Alcohol; traces(valid_trials & is_alcohol, 5:323)];
        F_Choice_Social  = [F_Choice_Social;  traces(valid_trials & is_social, 5:323)];
        F_Choice_Omit    = [F_Choice_Omit;    traces(valid_trials & is_omit, 5:323)];
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
colors.social_male = [1, 0.34, 0.13];   % Orange
colors.social_female  = [0.8, 0.0, 0.0];    % Dark Red
colors.alcohol_male= [0.01, 0.66, 0.96]; % Light Blue
colors.alcohol_female = [0.0, 0.2, 0.7];    % Dark Blue
colors.black        = [0.25, 0.25, 0.25]; % For permutation markers

% Define time vector for the x-axis (-10s to +10s)
% This assumes all data matrices have the same number of columns.
time_vector = linspace(-10, 10, size(M_Choice_Social, 2));

% Define statistical parameters
p_value_threshold = 0.01; % p-value for permutation test significance
consecutive_points_threshold = 8; % Min number of consecutive points for significance

% --- 2. Generate the Four Comparison Plots ---

fprintf('Generating comparison plots...\n');
y_axis_range = [-2, 4]; % Define the desired range [min, max]

% Plot 1: Social Choice (Male vs. Female)
[social_sig_windows] = createComparisonPlot(M_Choice_Social, F_Choice_Social, ...
    'Male Social', 'Female Social', ...
    colors.social_male, colors.social_female, colors.black, ...
    'Social Choice: Male vs. Female', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Display the significance table for the plot above
disp('--- Significance Windows for Social: Early vs. Late ---');
disp(social_sig_windows);

% Plot 2: Alcohol Choice (Male vs. Female)
[alcohol_sig_windows] = createComparisonPlot(M_Choice_Alcohol, F_Choice_Alcohol, ...
    'Male Alcohol', 'FemaleAlcohol', ...
    colors.alcohol_male, colors.alcohol_female, colors.black, ...
    'Alcohol Choice: Male vs. Female', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Display the significance table
disp('--- Significance Windows for Alcohol: Early vs. Late ---');
disp(alcohol_sig_windows);

% Plot 3: Male Sessions (Social vs. Alcohol)
[male_sig_windows] = createComparisonPlot(M_Choice_Social, M_Choice_Alcohol, ...
    'Male Social', 'Male Alcohol', ...
    colors.social_male, colors.alcohol_male, colors.black, ...
    'Male: Social vs. Alcohol Choice', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Display the significance table
disp('--- Significance Windows for Alcohol: Early vs. Late ---');
disp(male_sig_windows);

% Plot 4: Female Sessions (Social vs. Alcohol)
[female_sig_windows] = createComparisonPlot(F_Choice_Social, F_Choice_Alcohol, ...
    'Female Social', 'Female Alcohol', ...
    colors.social_female, colors.alcohol_female, colors.black, ...
    'Female: Social vs. Alcohol Choice', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Display the significance table
disp('--- Significance Windows for Alcohol: Early vs. Late ---');
disp(female_sig_windows);

fprintf('✅ All plots generated.\n');

