%% Nathan Marchant July 2024
% Written for the conflict task
% This script will calculate the zMean for a given period, defined below

close all
clear all
close all

% define where the stuff is
tankfolder = 'C:\Photometry\Social_045 Photom\SA_Extracted_Data_230930_(-5_+10)\240924_zMean';

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
    time = linspace(-5, 10, size(data, 2)); %time vector the size of trace
    base = (time >= -5) & (time <= -3); %This is the time period of the trace for which the baseline is calculated
    lims1 = (time >= -3) & (time <= 0); %baseline - pre lever press
    lims2 = (time >= 0) & (time <= 2); %limits - first 5s cues
    lims3 = (time >= 0) & (time <= 3); %limits - second 5s cues
    lims4 = (time >= 0) & (time <= 4); %limits - 10s period
    
    
    zdata = [];
    zdata = [times, data];  


%calculate mean in ALCOHOL SA
if strcmp(s1,'Alc')
    cdat = zdata(zdata(:,2) == 1, 5:end); 
    temp.zmean.alc_pre = mean(cdat(:, lims1), 2);
    temp.zmean.alc_five = mean(cdat(:, lims2), 2);
    temp.zmean.alc_ten = mean(cdat(:, lims3), 2);
    temp.zmean.alc_all = mean(cdat(:, lims4), 2);
    % add rat, sec, hemi, to the respective values
        alc_r_col = [repmat({r}, size(cdat, 1),1)];
        alc_h_col = [repmat({h}, size(cdat, 1),1)];
        alc_s_col = [repmat({sex}, size(cdat, 1),1)];
        alc_ses_col = [repmat({s1}, size(cdat, 1),1)];

    temp2.zmean.collated_alc_labels = [alc_r_col, alc_s_col, alc_h_col, alc_ses_col];
    temp2.zmean.collated_alc = [temp.zmean.alc_pre, temp.zmean.alc_five, temp.zmean.alc_ten, temp.zmean.alc_all];
    sesdat.zmean = [];
    sesdat.zmean = [sesdat.zmean, temp2.zmean];
      
    save([filePath '\' files(i).name(1:end-4) '.mat'], 'sesdat')
 
 % calculate mean in cue period from trials where SOCIAL is chosen
elseif strcmp(s1,'Soc')
    cdat =zdata(zdata(:,2) == 2, 5:end);
    
    temp.zmean.soc_pre = mean(cdat(:, lims1), 2);
    temp.zmean.soc_five = mean(cdat(:, lims2), 2);
    temp.zmean.soc_ten = mean(cdat(:, lims3), 2);
    temp.zmean.soc_all = mean(cdat(:, lims4), 2);
        % add rat, sec, hemi, to the respective values
        soc_r_col = [repmat({r}, size(cdat, 1),1)];
        soc_h_col = [repmat({h}, size(cdat, 1),1)];
        soc_s_col = [repmat({sex}, size(cdat, 1),1)];
        soc_ses_col = [repmat({s1}, size(cdat, 1),1)];

    temp2.zmean.collated_soc_labels = [soc_r_col, soc_s_col, soc_h_col, soc_ses_col];
    temp2.zmean.collated_soc = [temp.zmean.soc_pre, temp.zmean.soc_five, temp.zmean.soc_ten, temp.zmean.soc_all];
        sesdat.zmean = [];
    sesdat.zmean = [sesdat.zmean, temp2.zmean];
   
    
    save([filePath '\' files(i).name(1:end-4) '.mat'], 'sesdat')
end
    temp.zmean = [];
    temp2.zmean = [];

end
