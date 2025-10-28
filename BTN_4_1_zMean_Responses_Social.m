%% Nathan Marchant July 2024
% Written for the conflict task
% This script will calculate the zMean for a given period, defined below

close all
clear all
close all

% define where the stuff is
tankfolder = 'C:\Photometry\Social_045 Photom\ChoicePun_(-20_+20)\zMean_241001';

% load invidivual session data
filePath = fullfile(tankfolder);
filesAndFolders = dir(fullfile(filePath));
files = filesAndFolders(~[filesAndFolders.isdir]); 
files(ismember({files.name}, {'.', '..'})) = [];
for i = 1:length(files) %iterate through experiment folder
    load(fullfile(filePath,  [files(i).name]))
    names = strsplit(files(i).name, {'-' , '_', ' ', '.'}); %divide the file name into separte character vectors
    
    temp.zmean = [];
    temp2.zmean = [];

% get variables
    data = sesdat.traces_z(:, 5:end);
    times = sesdat.traces_z(:, 1:4);
    condition = sesdat.phase;
    r = sesdat.rat;
    sex = sesdat.sex;
    s1 = sesdat.ses;
    h = sesdat.hemi;
 

%define time, baseline etc
    time = linspace(-20, 20, size(data, 2)); %time vector the size of trace
    
    lims1 = (time >= -10) & (time <= 0); %limits - pre lever press
    lims2 = (time >= 0) & (time <= 2); %limits - first 2s 
    lims3 = (time >= 2) & (time <= 4); %limits - second 2s
    lims4 = (time >= 0) & (time <= 3); %limits - first 10s 
    lims5 = (time >= 0) & (time <= 4); %limits - second 10s
    
    zdata = [];
    zdata = [times, data];  


%calculate mean in cue period from ALCOHOL responses
    cdat = zdata(zdata(:,2) == 1, 5:end); 
    % temp.zmean.alc_lat = zdata(zdata(:,2) == 3 & zdata(:,4) == 1 & zdata(:,3), 3);
    
    temp.zmean.alc_BL = mean(cdat(:, lims1), 2);
    temp.zmean.alc_five = mean(cdat(:, lims2), 2);
    temp.zmean.alc_ten = mean(cdat(:, lims3), 2);
    temp.zmean.alc_cue = mean(cdat(:, lims4), 2);
    temp.zmean.alc_lever = mean(cdat(:, lims5), 2);
    % add rat, sec, hemi, to the respective values
        alc_r_col = [repmat({r}, size(cdat, 1),1)];
        alc_h_col = [repmat({h}, size(cdat, 1),1)];
        alc_s_col = [repmat({sex}, size(cdat, 1),1)];
        alc_ses_col = [repmat({s1}, size(cdat, 1),1)];


%% calculate mean in cue period from SOCIAL responses
    cdat =zdata(zdata(:,2) == 2, 5:end);
    % temp.zmean.soc_lat = zdata(zdata(:,2) == 3 & zdata(:,4) == 2, 3);
    
    temp.zmean.soc_BL = mean(cdat(:, lims1), 2);
    temp.zmean.soc_five = mean(cdat(:, lims2), 2);
    temp.zmean.soc_ten = mean(cdat(:, lims3), 2);
    temp.zmean.soc_cue = mean(cdat(:, lims4), 2);
    temp.zmean.soc_lever = mean(cdat(:, lims5), 2);
        % add rat, sec, hemi, to the respective values
        soc_r_col = [repmat({r}, size(cdat, 1),1)];
        soc_h_col = [repmat({h}, size(cdat, 1),1)];
        soc_s_col = [repmat({sex}, size(cdat, 1),1)];
        soc_ses_col = [repmat({s1}, size(cdat, 1),1)];
 
   
% %% calculate auc and mean in cue period from OMITTED trials 
%     cdat =zdata(zdata(:,2) == 3 & zdata(:,4) == 0, 5:end);
% 
%     temp.zmean.omit_BL = mean(cdat(:, lims1), 2);
%     temp.zmean.omit_five = mean(cdat(:, lims2), 2);
%     temp.zmean.omit_ten = mean(cdat(:, lims3), 2);
%     temp.zmean.omit_cue = mean(cdat(:, lims4), 2);
%     temp.zmean.omit_lever = mean(cdat(:, lims5), 2);
%         % add rat, sec, hemi, to the respective values
%         omit_r_col = [repmat({r}, size(cdat, 1),1)];
%         omit_h_col = [repmat({h}, size(cdat, 1),1)];
%         omit_s_col = [repmat({sex}, size(cdat, 1),1)];
%         omit_ses_col = [repmat({s1}, size(cdat, 1),1)];

    
%% save variables...
    temp2.zmean.collated_alc_labels = [alc_r_col, alc_s_col, alc_h_col, alc_ses_col];
    temp2.zmean.collated_alc = [temp.zmean.alc_BL, temp.zmean.alc_five, temp.zmean.alc_ten, temp.zmean.alc_cue, temp.zmean.alc_lever];
   
    temp2.zmean.collated_soc_labels = [soc_r_col, soc_s_col, soc_h_col, soc_ses_col];
    temp2.zmean.collated_soc = [temp.zmean.soc_BL, temp.zmean.soc_five, temp.zmean.soc_ten, temp.zmean.soc_cue, temp.zmean.soc_lever];
   
    % temp2.zmean.collated_omit_labels = [omit_r_col, omit_s_col, omit_h_col, omit_ses_col];
    % temp2.zmean.collated_omit = [temp.zmean.omit_BL, temp.zmean.omit_five, temp.zmean.omit_ten, temp.zmean.omit_cue, temp.zmean.omit_lever];


    sesdat.zmean = [];
    sesdat.zmean = [sesdat.zmean, temp2.zmean];
    
    save([filePath '\' files(i).name(1:end-4) '.mat'], 'sesdat')
 
    temp.zmean = [];
    temp2.zmean = [];

end
