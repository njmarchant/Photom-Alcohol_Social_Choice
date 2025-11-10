%% Nathan Marchant July 2024
% Collate zmean scores of multiple sessions into a single file per rat  
% Written for the conflict phase of the experiment

fclose all;
clear all;
close all;

%% define where the stuff is
tankfolder = 'C:\Photometry\Social_045 Photom\ChoicePun_(-20_+20)\zMean_241001';
Rat = {'R1','R2','R5','R6','R8','R9','R11','R12','R15','R16','R18','R19','R21','R22','R23', 'R24','R27','R30','R31', 'R32','R33','R34','R35'};
choice_early = {'C1','C2'};
choice_late = {'C5','C6','C7','C8'};
pun_ALL = {'P1','P2','P3','P4'};
pun_early = {'P1','P2'};
pun_late = {'P3','P4'};

%% variables to save
alldat.zmean_labels.alc_labels = {};
alldat.zmean_data.alc = [];
alldat.zmean_labels.soc_labels = {};
alldat.zmean_data.soc = [];
% alldat.zmean_labels.omit_labels = {};
% alldat.zmean_data.omit = [];

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
            if any(strcmp(ses,pun_ALL))
                % Collate values for ALCOHOL CHOICE trials
                if ~isempty(sesdat.zmean.collated_alc_labels)
                    alldat.zmean_labels.alc_labels = [alldat.zmean_labels.alc_labels; sesdat.zmean.collated_alc_labels];
                end
                if ~isempty(sesdat.zmean.collated_alc)
                    alldat.zmean_data.alc = [alldat.zmean_data.alc; sesdat.zmean.collated_alc];
                end
                % Collate values for SOCIAL CHOICE trials
                if ~isempty(sesdat.zmean.collated_soc_labels)
                    alldat.zmean_labels.soc_labels = [alldat.zmean_labels.soc_labels; sesdat.zmean.collated_soc_labels];
                end
                if ~isempty(sesdat.zmean.collated_soc)
                    alldat.zmean_data.soc = [alldat.zmean_data.soc; sesdat.zmean.collated_soc];
                end
                % Collate values for NO CHOICE - OMISSION trials
                % if ~isempty(sesdat.zmean.collated_omit_labels)
                %     alldat.zmean_labels.omit_labels = [alldat.zmean_labels.omit_labels; sesdat.zmean.collated_omit_labels];
                % end
                % if ~isempty(sesdat.zmean.collated_omit)
                %     alldat.zmean_data.omit = [alldat.zmean_data.omit; sesdat.zmean.collated_omit];
                % end
            end
        end
    end


    %% ___________Put it all together_______________________________________
    alldat.zmean_data.alcmean = mean(alldat.zmean_data.alc,1);
    alldat.zmean_data.socmean = mean(alldat.zmean_data.soc,1);
    % alldat.zmean_data.omitmean = mean(alldat.zmean_data.omit,1);
  
    
    %% ___________SAVE FILE_______________________________________

    folderName = strcat(tankfolder,'\pun_ALL');
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
    % alldat.zmean_labels.omit_labels = {};
    % alldat.zmean_data.omit = [];

end
 
   
