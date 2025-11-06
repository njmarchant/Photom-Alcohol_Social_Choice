%% Isis Alonso-Lozares 16-06-21 script to combine data from different animals
% NM updated (with Gemini) for social reward experiment 02-09-25
clear all;
close all; % Good practice to close any open figures

% --- 1. Setup ---
tankfolder = 'C:\Photometry\Social_045 Photom\2025_R1\Both_(-20_+20)';

% Pre-initialize matrices to hold the aggregated data from ALL files.
% It's good practice to initialize them, even if they start empty.
A_Choice_Alcohol = [];
A_Choice_Social  = [];
S_Choice_Alcohol = [];
S_Choice_Social  = [];

Alc_Pref = -0.5;
Soc_Pref = 0.5;

% Define the session identifiers
early = {'C3', 'C4'};
late  = {'L1', 'L2'};
choice = {'C1', 'C2','C3', 'C4','C5', 'C6','C7', 'C8'};

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
    ses = sesdat.ses;
    pref = sesdat.pref;

    % Determine if this session is 'early' or 'late' once per file
    isEarlySession = any(ismember(ses, early));
    isLateSession = any(ismember(ses, late));
    isChoiceSession = any(ismember(ses, choice));

    % Determine if this session is 'alc pref' or 'soc pref' once per file
    isAlcSession = (pref < Alc_Pref);
    isSocSession = (pref > Soc_Pref);
    
     % --- 3. Vectorized Data Extraction (replaces the inner 'j' loop) ---
    
    % Create logical masks to find all rows meeting the criteria at once
    is_alcohol   = traces(:, 2) == 1;
    is_social    = traces(:, 2) == 2;
    

    % Use the masks to extract the data for the CURRENT file and append
    % the entire block of new rows to the main matrices.
    if isAlcSession && isChoiceSession
        A_Choice_Alcohol = [A_Choice_Alcohol; traces(is_alcohol, 5:end)];
        A_Choice_Social  = [A_Choice_Social;  traces(is_social, 5:end)];
        
    elseif isSocSession && isChoiceSession
        S_Choice_Alcohol = [S_Choice_Alcohol; traces(is_alcohol, 5:end)];
        S_Choice_Social  = [S_Choice_Social;  traces(is_social, 5:end)];
        
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
colors.social_early = [1, 0.34, 0.13];   % Orange
colors.social_late  = [0.8, 0.0, 0.0];    % Dark Red
colors.alcohol_early= [0.01, 0.66, 0.96]; % Light Blue
colors.alcohol_late = [0.0, 0.2, 0.7];    % Dark Blue
colors.black        = [0.25, 0.25, 0.25]; % For permutation markers

% Define time vector for the x-axis (-10s to +10s)
% This assumes all data matrices have the same number of columns.
time_vector = linspace(-20, 20, size(A_Choice_Social, 2));

% Define statistical parameters
p_value_threshold = 0.01; % p-value for permutation test significance
consecutive_points_threshold = 8; % Min number of consecutive points for significance

% --- 2. Generate the Four Comparison Plots ---

fprintf('Generating comparison plots...\n');
y_axis_range = [-2, 8]; % Define the desired range [min, max]

% Plot 1: Social Choice (Alc Pref session vs. Soc Pref session)
[social_sig_windows] = createComparisonPlot(A_Choice_Social, S_Choice_Social, ...
    'Social (Alc Preferring)', 'Social (Soc Preferring)', ...
    colors.social_early, colors.social_late, colors.black, ...
    'Social Choice: Alc Pref session vs. Soc Pref session', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Plot 2: Alcohol Choice (Alc Pref session vs. Soc Pref session)
[alcohol_sig_windows] = createComparisonPlot(A_Choice_Alcohol, S_Choice_Alcohol, ...
    'Alcohol (Alc Preferring)', 'Alcohol (Soc Preferring)', ...
    colors.alcohol_early, colors.alcohol_late, colors.black, ...
    'Alcohol Choice: Alc Pref session vs. Soc Pref session', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Plot 3: Alc Pref session (Social vs. Alcohol)
[Alc_Pref_sig_windows] = createComparisonPlot(A_Choice_Social, A_Choice_Alcohol, ...
    'Social', 'Alcohol', ...
    colors.social_early, colors.alcohol_early, colors.black, ...
    'Alc Pref session: Social vs. Alcohol Choice', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

% Plot 4: Soc Pref session (Social vs. Alcohol)
[Soc_Pref_sig_windows] = createComparisonPlot(S_Choice_Social, S_Choice_Alcohol, ...
    'Social', 'Alcohol', ...
    colors.social_late, colors.alcohol_late, colors.black, ...
    'Soc Pref session: Social vs. Alcohol Choice', time_vector, ...
    p_value_threshold, consecutive_points_threshold, y_axis_range);

fprintf('✅ All plots generated.\n');

