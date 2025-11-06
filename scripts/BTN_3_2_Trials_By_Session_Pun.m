%% Isis Alonso-Lozares 16-06-21 script to combine data from different animals
% NM updated (with Gemini) for social reward experiment 02-09-25
clear all;
close all; % Good practice to close any open figures

% --- 1. Setup ---
tankfolder = 'C:\Photometry\Social_045 Photom\2025_R1\Both_(-10_+30)';

% Pre-initialize matrices to hold the aggregated data from ALL files.
% It's good practice to initialize them, even if they start empty.
Late_Choice_Alcohol = [];
Late_Choice_Social  = [];
Late_Choice_Omit    = [];
Pun_Choice_Alcohol = [];
Pun_Choice_Social  = [];
Pun_Choice_Omit    = [];

% Define the session identifiers
early = {'C1', 'C2'};
late  = {'P1', 'P2'};
pun = {'P3','P4'};%, 'P2', 'P3','P4'};

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
    % ses_last = sesdat.ses_last;

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
    if isLateSession
        Late_Choice_Alcohol = [Late_Choice_Alcohol; traces(valid_trials & is_alcohol, 5:323)];
        Late_Choice_Social  = [Late_Choice_Social;  traces(valid_trials & is_social, 5:323)];
        Late_Choice_Omit    = [Late_Choice_Omit;    traces(valid_trials & is_omit, 5:323)];

    elseif isPunSession
        Pun_Choice_Alcohol = [Pun_Choice_Alcohol; traces(valid_trials & is_alcohol, 5:323)];
        Pun_Choice_Social  = [Pun_Choice_Social;  traces(valid_trials & is_social, 5:323)];
        Pun_Choice_Omit    = [Pun_Choice_Omit;    traces(valid_trials & is_omit, 5:323)];
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
time_vector = linspace(-10, 10, size(Late_Choice_Social, 2));

% Define statistical parameters
p_value_threshold = 0.01; % p-value for permutation test significance
consecutive_points_threshold = 8; % Min number of consecutive points for significance

% --- 2. Generate the Four Comparison Plots ---

fprintf('Generating comparison plots...\n');

% Plot 1: Social Choice (Pun vs. Late)
createComparisonPlot(Late_Choice_Social, Pun_Choice_Social, ...
    'Late Social', 'Pun Social', ...
    colors.social_early, colors.social_late, colors.black, ...
    'Social Choice: Late vs. Pun Sessions', time_vector, ...
    p_value_threshold, consecutive_points_threshold);

% Plot 2: Alcohol Choice (Late vs. Pun)
createComparisonPlot(Late_Choice_Alcohol, Pun_Choice_Alcohol, ...
    'Late Alcohol', 'Pun Alcohol', ...
    colors.alcohol_early, colors.alcohol_late, colors.black, ...
    'Alcohol Choice: Late vs. Pun Sessions', time_vector, ...
    p_value_threshold, consecutive_points_threshold);

% Plot 3: Late Sessions (Social vs. Alcohol)
createComparisonPlot(Late_Choice_Social, Late_Choice_Alcohol, ...
    'Late Social', 'Late Alcohol', ...
    colors.social_early, colors.alcohol_early, colors.black, ...
    'Late Sessions: Social vs. Alcohol Choice', time_vector, ...
    p_value_threshold, consecutive_points_threshold);

% Plot 4: Late Sessions (Social vs. Alcohol)
createComparisonPlot(Pun_Choice_Social, Pun_Choice_Alcohol, ...
    'Punish Social', 'Punish Alcohol', ...
    colors.social_late, colors.alcohol_late, colors.black, ...
    'Punish Sessions: Social vs. Alcohol Choice', time_vector, ...
    p_value_threshold, consecutive_points_threshold);

fprintf('✅ All plots generated.\n');


%% ========================================================================
%  HELPER FUNCTION FOR PLOTTING
%  Place this at the end of your script or save as a separate .m file
%  ========================================================================
function createComparisonPlot(data1, data2, label1, label2, color1, color2, perm_color, plotTitle, time, p_val, thres)
    % Creates a standardized plot comparing two datasets, including
    % bootstrapping and permutation test results.

    % --- 1. Prepare Labels and Stats ---
    
    % Create dynamic labels with trial counts (n)
    n1 = size(data1, 1);
    n2 = size(data2, 1);
    full_label1 = sprintf('%s (n=%d)', label1, n1);
    full_label2 = sprintf('%s (n=%d)', label2, n2);
    
    % Bootstrap confidence intervals for each dataset
    fprintf('Running stats for "%s"...\n', plotTitle);
    tmp = bootstrap_data(data1, 5000, 0.001);
    btsrp.d1 = CIadjust(tmp(1,:), tmp(2,:), tmp, n1, 2);
    tmp = bootstrap_data(data2, 5000, 0.001);
    btsrp.d2 = CIadjust(tmp(1,:), tmp(2,:), tmp, n2, 2);
    clear tmp;
    
    % Permutation test between the two datasets
    [perm.d1_vs_d2, ~] = permTest_array(data1, data2, 1000);

    % --- 2. Create the Plot ---
    
    figure('Name', plotTitle, 'NumberTitle', 'off'); % Create a new figure
    hold on;
    
    % Plot mean traces and shaded standard error of the mean (SEM)
    h1 = plot(time, mean(data1, 1), 'Color', color1, 'LineWidth', 1.5);
    jbfill(time, (mean(data1, 1) + std(data1, 0, 1) / sqrt(n1)), ...
                 (mean(data1, 1) - std(data1, 0, 1) / sqrt(n1)), ...
                 color1, 'none', 0, 0.2);
    
    h2 = plot(time, mean(data2, 1), 'Color', color2, 'LineWidth', 1.5);
    jbfill(time, (mean(data2, 1) + std(data2, 0, 1) / sqrt(n2)), ...
                 (mean(data2, 1) - std(data2, 0, 1) / sqrt(n2)), ...
                 color2, 'none', 0, 0.2);
             
    % --- 3. Add Significance Markers ---
    
    ax = gca;
    yLimits = ax.YLim;
    yMin = yLimits(1);
    
    % Define y-axis offsets for significance markers to prevent overlap
    % You may need to adjust these values based on your data's scale
    offsets.boot1_pos = -0.1;
    offsets.boot1_neg = -0.2;
    offsets.boot2_pos = -0.4;
    offsets.boot2_neg = -0.5;
    offsets.perm      = -0.8;
    
    % Plot Bootstrap Markers (signal vs. baseline)
    % For Data 1
    tmp_pos = find(btsrp.d1(1,:) > 0);
    id_pos = tmp_pos(consec_idx(tmp_pos, thres));
    plot(time(id_pos), (yMin + offsets.boot1_pos) * ones(1, length(id_pos)), 's', 'MarkerSize', 5, 'MarkerFaceColor', color1, 'Color', color1);
    
    tmp_neg = find(btsrp.d1(2,:) < 0);
    id_neg = tmp_neg(consec_idx(tmp_neg, thres));
    plot(time(id_neg), (yMin + offsets.boot1_neg) * ones(1, length(id_neg)), 's', 'MarkerSize', 5, 'MarkerFaceColor', color1, 'Color', color1);
    
    % For Data 2
    tmp_pos = find(btsrp.d2(1,:) > 0);
    id_pos = tmp_pos(consec_idx(tmp_pos, thres));
    plot(time(id_pos), (yMin + offsets.boot2_pos) * ones(1, length(id_pos)), 's', 'MarkerSize', 5, 'MarkerFaceColor', color2, 'Color', color2);
    
    tmp_neg = find(btsrp.d2(2,:) < 0);
    id_neg = tmp_neg(consec_idx(tmp_neg, thres));
    plot(time(id_neg), (yMin + offsets.boot2_neg) * ones(1, length(id_neg)), 's', 'MarkerSize', 5, 'MarkerFaceColor', color2, 'Color', color2);

    % Plot Permutation Test Markers (Data1 vs. Data2)
    tmp_perm = find(perm.d1_vs_d2(1, :) < p_val);
    id_perm = tmp_perm(consec_idx(tmp_perm, thres));
    plot(time(id_perm), (yMin + offsets.perm) * ones(1, length(id_perm)), 's', 'MarkerSize', 5, 'MarkerFaceColor', perm_color, 'Color', perm_color);
    
    % --- 4. Finalize Plot Aesthetics ---
    
    % Add reference lines at x=0 and y=0
    line([0, 0], yLimits, 'Color', [0.5 0.5 0.5], 'LineStyle', '--');
    line(ax.XLim, [0, 0], 'Color', [0.5 0.5 0.5], 'LineStyle', '--');
    
    % Add labels, title, and legend
    xlabel('Time from Choice (s)');
    ylabel('Z-Scored Fluorescence');
    title(plotTitle);
    legend([h1, h2], {full_label1, full_label2}, 'Location', 'northwest', 'Interpreter', 'none');
    
    set(gca, 'FontSize', 12); % Set font size for readability
    box off; % Remove box outline
    hold off;
end