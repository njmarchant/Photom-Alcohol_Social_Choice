%% Extract Trial-by-Trial Variance and Run Mixed-Effects Model
% This script loads the zMean data, calculates variance/CV per rat, 
% and runs an LMM to test the 'Autonomic Inflexibility' hypothesis.

clear all; close all;

% Define where the processed files are
tankfolder = 'C:\Photometry\Social_045\Both_(-10_+30)';
filesAndFolders = dir(fullfile(tankfolder, '*.mat')); % Only get .mat files

% Initialize arrays to hold all the aggregated data
all_ratIDs = [];
all_sex = {};
all_choiceTypes = {};
all_std = [];  % Standard Deviation
all_cv = [];   % Coefficient of Variation
all_means = []; % Mean cue activity

% We need to aggregate all trials across all sessions FOR EACH RAT first
% Creating a struct to dynamically hold trials per rat
ratData = struct();

for i = 1:length(filesAndFolders)
    load(fullfile(tankfolder, filesAndFolders(i).name), 'sesdat');
    
    % Check if zmean data exists
    if isfield(sesdat, 'NOT_zmean')
        
        %% Extract ALCOHOL trials for this session
        if ~isempty(sesdat.NOT_zmean.collated_alc)
            alc_labels = sesdat.NOT_zmean.collated_alc_labels; % {rat, sex, hemi, ses}
            alc_cue_data = sesdat.NOT_zmean.collated_alc(:, 5); % Col 5 is the 10s cue limit (lims4)
            
            for t = 1:length(alc_cue_data)
                rID = ['Rat_', num2str(alc_labels{t,1})];
                sex = alc_labels{t,2};
                
                if ~isfield(ratData, rID)
                    ratData.(rID).alc_trials = [];
                    ratData.(rID).soc_trials = [];
                    ratData.(rID).sex = sex;
                end
                ratData.(rID).alc_trials = [ratData.(rID).alc_trials; alc_cue_data(t)];
            end
        end
        
        %% Extract SOCIAL trials for this session
        if ~isempty(sesdat.NOT_zmean.collated_soc)
            soc_labels = sesdat.NOT_zmean.collated_soc_labels; % {rat, sex, hemi, ses}
            soc_cue_data = sesdat.NOT_zmean.collated_soc(:, 5); % Col 5 is the 10s cue limit (lims4)
            
            for t = 1:length(soc_cue_data)
                rID = ['Rat_', num2str(soc_labels{t,1})];
                sex = soc_labels{t,2};
                
                if ~isfield(ratData, rID)
                    ratData.(rID).alc_trials = [];
                    ratData.(rID).soc_trials = [];
                    ratData.(rID).sex = sex;
                end
                ratData.(rID).soc_trials = [ratData.(rID).soc_trials; soc_cue_data(t)];
            end
        end
    end
end

%% Calculate Variance/CV per Rat and Format for LMM
ratNames = fieldnames(ratData);

for r = 1:length(ratNames)
    rID = ratNames{r};
    sex = ratData.(rID).sex;
    
    % --- ALCOHOL DATA ---
    alc_trials = ratData.(rID).alc_trials;
    if length(alc_trials) > 3 % Ensure enough trials to calculate variance
        alc_std = std(alc_trials);
        alc_mean = mean(alc_trials);
        alc_cv = alc_std / alc_mean; % Note: Only valid if mean > 0
        
        % Append to master lists
        all_ratIDs = [all_ratIDs; string(rID)];
        all_sex = [all_sex; {sex}];
        all_choiceTypes = [all_choiceTypes; {'Alcohol'}];
        all_std = [all_std; alc_std];
        all_cv = [all_cv; alc_cv];
        all_means = [all_means; alc_mean];
    end
    
    % --- SOCIAL DATA ---
    soc_trials = ratData.(rID).soc_trials;
    if length(soc_trials) > 3 % Ensure enough trials to calculate variance
        soc_std = std(soc_trials);
        soc_mean = mean(soc_trials);
        soc_cv = soc_std / soc_mean; % Note: Only valid if mean > 0
        
        % Append to master lists
        all_ratIDs = [all_ratIDs; string(rID)];
        all_sex = [all_sex; {sex}];
        all_choiceTypes = [all_choiceTypes; {'Social'}];
        all_std = [all_std; soc_std];
        all_cv = [all_cv; soc_cv];
        all_means = [all_means; soc_mean];
    end
end

%% Create Table and Run Mixed Effects Model
% Create a table for statistical testing
tbl = table(all_ratIDs, categorical(all_sex), categorical(all_choiceTypes), all_std, all_cv, all_means, ...
    'VariableNames', {'RatID', 'Sex', 'Choice', 'StdDev', 'CV', 'MeanCue'});

% Set reference level for Choice so the model compares Alcohol against Social
tbl.Choice = reordercats(tbl.Choice, {'Social', 'Alcohol'}); 

disp('--- LMM: Testing Inflexibility (Standard Deviation) ---')
% The hypothesis: Alcohol choices have significantly LOWER variance (StdDev) than Social choices
lme_std = fitlme(tbl, 'StdDev ~ 1 + Choice + Sex + (1|RatID)');
disp(lme_std);

%% Simple Visualization: Boxplot of Variance
figure;
boxplot(tbl.StdDev, tbl.Choice);
ylabel('Trial-by-Trial Standard Deviation (aIC \DeltaF/F)');
title('Visceromotor Inflexibility: Alcohol vs Social Priors');
set(gca, 'FontSize', 12);