%% Nathan Marchant July 2024
% Collate zmean scores of multiple sessions into a single file per rat  
% Written for the conflict phase of the experiment

fclose all;
clear all;
close all;

%% define where the stuff is
tankfolder = 'C:\Photometry\Social_045 Photom\SA_Extracted_Data_230930_(-5_+10)\240924_zMean';
Rat = {'R1','R2','R5','R6','R8','R9','R11','R12','R15','R16','R18','R19','R21','R22','R23', 'R24','R27','R30','R31', 'R32','R33','R34','R35'};


%% variables to save
alldat.zmean_labels.alc_labels = {};
alldat.zmean_data.alc = [];
alldat.zmean_labels.soc_labels = {};
alldat.zmean_data.soc = [];


%% load invidivual session sesdata
filePath = fullfile(tankfolder);
filesAndFolders = dir(fullfile(filePath));
files = filesAndFolders(~[filesAndFolders.isdir]); 
files(ismember({files.name}, {'.', '..'})) = [];
for j = 1:length(Rat) %iterate through experiment folder
    for i = 1:length(files) %iterate through experiment folder
        names = strsplit(files(i).name, {'-' , '_', ' ', '.'}); %divide the file name into separte character vectors
        r = Rat{j};
        openrat = names{7};
        if strcmp(r,openrat)
            load(fullfile(filePath, [files(i).name]))
            ses = sesdat.ses;
            if strcmp(ses,'Alc')
                % Collate values for ALCOHOL SA
                if ~isempty(sesdat.zmean.collated_alc_labels)
                    alldat.zmean_labels.alc_labels = [alldat.zmean_labels.alc_labels; sesdat.zmean.collated_alc_labels];
                end
                if ~isempty(sesdat.zmean.collated_alc)
                    alldat.zmean_data.alc = [alldat.zmean_data.alc; sesdat.zmean.collated_alc];
                end
            elseif strcmp(ses,'Soc')
                % Collate values for SOCIAL SA
                if ~isempty(sesdat.zmean.collated_soc_labels) || ~exist(sesdat.zmean.collated_soc_labels)
                    alldat.zmean_labels.soc_labels = [alldat.zmean_labels.soc_labels; sesdat.zmean.collated_soc_labels];
                end
                if ~isempty(sesdat.zmean.collated_soc)
                    alldat.zmean_data.soc = [alldat.zmean_data.soc; sesdat.zmean.collated_soc];
                end
            end
        end
    end


    %% ___________Put it all together_______________________________________
    alldat.zmean_data.alcmean = mean(alldat.zmean_data.alc,1);
    alldat.zmean_data.socmean = mean(alldat.zmean_data.soc,1);
    
  
    
    %% ___________SAVE FILE_______________________________________
    folderName = strcat(tankfolder,'\SA');
    r = char(Rat(j));
    
    if ~isfolder(folderName)  % Check if the folder does not exist
        mkdir(folderName);  % Create the folder
        save([folderName '\Social 045 zmean combined ', r '.mat'], 'alldat');
    else
        save([folderName '\Social 045 zmean combined ', r '.mat'], 'alldat');
    end
    %% variables to reset between rats
    alldat.zmean_labels.alc_labels = {};
    alldat.zmean_data.alc = [];
    alldat.zmean_labels.soc_labels = {};
    alldat.zmean_data.soc = [];
    alldat.zmean_labels.omit_labels = {};
    alldat.zmean_data.omit = [];

end
 
   
