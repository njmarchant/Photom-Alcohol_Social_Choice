%% Collate zmean scores of multiple sessions into a single file per rat 

fclose all;
clear all;
close all;

%% define where the stuff is
tankfolder = 'C:\Photometry\Social_045 Photom\ChoicePun_(-20_+20)\zMean_241001\';
phase = 'pun_ALL';

%% find files
filePath = fullfile(tankfolder,phase);
filesAndFolders = dir(fullfile(filePath));
files = filesAndFolders(~[filesAndFolders.isdir]); 
files(ismember({files.name}, {'.', '..'})) = [];
numfiles = length(files);

%% variables to save

collated.all.alc_labels = [];
collated.all.alc = [];
collated.all.soc_labels = [];
collated.all.soc = [];
% collated.all.omit_labels = [];
% collated.all.omit = [];

collated.mean.labels = cell(numfiles,3);
collated.mean.alc = zeros(numfiles,5);
collated.mean.soc = zeros(numfiles,5);
% collated.mean.omit = zeros(numfiles,5);

% Loop through files to collate data
for i = 1:numfiles
    load(fullfile(filePath, files(i).name));
    collated.all.alc_labels = [collated.all.alc_labels; alldat.zmean_labels.alc_labels];
    collated.all.alc = [collated.all.alc; alldat.zmean_data.alc];
    
    collated.all.soc_labels = [collated.all.soc_labels; alldat.zmean_labels.soc_labels];
    collated.all.soc = [collated.all.soc; alldat.zmean_data.soc];
    
    % collated.all.omit_labels = [collated.all.omit_labels; alldat.zmean_labels.omit_labels];
    % collated.all.omit = [collated.all.omit; alldat.zmean_data.omit];
    

    if ~isempty(alldat.zmean_labels.soc_labels)
        collated.mean.labels{i,1} = alldat.zmean_labels.soc_labels{1,1};
        collated.mean.labels{i,2} = alldat.zmean_labels.soc_labels{1,2};
        collated.mean.labels{i,3} = phase;
        
    end
    % Check if the alcohol means are NaN and if not add it to the array
    if ~isnan(alldat.zmean_data.alcmean) 
         collated.mean.alc(i, :) = alldat.zmean_data.alcmean;
    end
      
    % Check if the social means are NaN and if not add it to the array
    if ~isnan(alldat.zmean_data.socmean) 
         collated.mean.soc(i, :) = alldat.zmean_data.socmean;
    end
    
    % Check if the omission means are NaN and if not add it to the array
    % if ~isnan(alldat.zmean_data.omitmean) 
    %      collated.mean.omit(i, :) = alldat.zmean_data.omitmean;
    % end
    
end
   p = char(phase);
    folderName = strcat(tankfolder,phase);
        save([folderName '\Social 045 ' p ' zMean all rats.mat'], 'collated')