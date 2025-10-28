%% Isis Alonso-Lozares 16-06-21 script to combine data from different animals
%% NM updated for social reward experiment 15-05-23
%% define where the stuff is

clear all
tankfolder = 'C:\Photometry\Social_045 Photom\ChoicePun_(-10_+30)\2025_R1';
filePath = fullfile(tankfolder);
allDat = cell(1,1);
Choice_Alcohol = [];
Choice_Social = [];
Choice_Omit = [];
tmp = [];
  
filesAndFolders = dir(fullfile(filePath));
files = filesAndFolders(~[filesAndFolders.isdir]); 
files(ismember({files.name}, {'.', '..'})) = [];
for i = 1:length(files) %iterate through experiment folder

        load(fullfile(filePath,  [files(i).name]))
        names = strsplit(files(i).name, {'-' , '_', ' ', '.'}); %divide the file name into separte character vectors
        side = sesdat.hemi;
        ses = sesdat.ses;
        

for j = 1:size(sesdat.traces_z, 1)
 if isnan(sesdat.traces_z(j,5))
 elseif sesdat.traces_z(j, 2) == 3 && sesdat.traces_z(j, 4) == 1 
    Choice_Alcohol = [Choice_Alcohol; sesdat.traces_z(j, 5:323)];
 elseif sesdat.traces_z(j,2) == 3 && sesdat.traces_z(j, 4) == 2 
     Choice_Social = [Choice_Social; sesdat.traces_z(j, 5:323)];
 elseif sesdat.traces_z(j,2) == 3 && sesdat.traces_z(j, 4) == 0 
     Choice_Omit = [Choice_Omit; sesdat.traces_z(j, 5:323)];
 end
end
end


 %% 
 %___________ colours used for the plots (RGB values / 255)______________
    purp = [0.40,0.0,1.00];
    blu = [0.01,0.66,0.96];
    red = [1.0,0,0];
    orange = [1,0.34,0.13];
    green = [0.125,0.50,0.125];
    black1 = [0.75,0.75,0.75];
    black2 = [0.5,0.5,0.5];
    black3 = [0.25,0.25,0.25];

%___________ Dimensions and labels used for the plots ______________
 
    time = linspace(-10, 10, size(Choice_Social, 2));
    Alc_rewards = num2str(size(Choice_Alcohol,1));
    Soc_rewards = num2str(size(Choice_Social,1));
    Ch_omit_count = num2str(size(Choice_Omit,1));
    Alc_label = ['Alcohol (', Alc_rewards,')'];
    Soc_label = ['Social (', Soc_rewards,')'];
    Omit_label = ['Omissions (', Ch_omit_count,')'];


            %------CHOICE STATS: ALCOHOL v SOCIAL v OMISSION -----------------------------------------------------------------------

%bootstrap 
tmp = bootstrap_data(Choice_Alcohol, 5000, 0.001);
btsrp.alcCh = CIadjust(tmp(1,:),tmp(2,:),tmp,size(Choice_Alcohol, 1),2);
tmp = bootstrap_data(Choice_Social, 5000, 0.001);
btsrp.socCh = CIadjust(tmp(1,:),tmp(2,:),tmp,size(Choice_Social, 1),2);
tmp = bootstrap_data(Choice_Omit, 5000, 0.001);
btsrp.omitCh = CIadjust(tmp(1,:),tmp(2,:),tmp,size(Choice_Omit, 1),2);
clear tmp

%permutation tests
[perm.alc_soc, ~] = permTest_array(Choice_Alcohol, Choice_Social, 1000);
[perm.alc_omit, ~] = permTest_array(Choice_Alcohol, Choice_Omit, 1000);
[perm.soc_omit, ~] = permTest_array(Choice_Social, Choice_Omit, 1000);

%-----------------------------------------------------Plot Choice v2  -----------------------------------------------------------------------
 
%Statistical parameters
p = 0.01;
thres = 8;

figure
datasets = {Choice_Alcohol, Choice_Social, Choice_Omit};
labels = {Alc_label, Soc_label, Omit_label};
colors = {purp, red, black2};

boottests = {'alcCh', 'socCh', 'omitCh'};
offsetsboot = [0, -0.1, -0.4, -0.5, -0.8, -0.9];
permtests = {'alc_soc', 'alc_omit', 'soc_omit'};
offsetsperm = [-1.5, -1.75, -2.0];
markersperm = {black1, black2, black3};

handles = zeros(1, numel(datasets)*2); % Preallocate handles
for i = 1:length(colors)
    hold on
    handles(i) = plot(time, mean(datasets{i}, 1), 'Color', colors{i});
    jbfill(time, (mean(datasets{i}) - std(datasets{i}, 0, 1) / sqrt(size(datasets{i}, 1))), ...
        (std(datasets{i}, 0, 1) / sqrt(size(datasets{i}, 1)) + mean(datasets{i})), colors{i}, 'none', 0, 0.2);
    handles(i+3) = plot(NaN, NaN, 'Color', colors{i}); % Dummy handle for legend
end

legend(handles(1:length(labels)), labels, 'Location', 'northwest'); % Provide only the handles for mean lines
ax = gca;
yLimits = ax.YLim;
yMin = yLimits(1);

% Plotting markers for bootstrapping
for i = 1:2:length(boottests)*2
    tmp = find(btsrp.(boottests{(i+1)/2})(1,:) > 0);   % Find indices for values > 0 (i.e. signal higher than baseline)
    id = tmp(consec_idx(tmp, thres));
    plot(time(id), (yMin + offsetsboot(i) * ones(size(time(id), 2), 2)), 's', 'MarkerSize', 7, 'MarkerFaceColor', colors{(i+1)/2}, 'Color', colors{(i+1)/2}, 'HandleVisibility', 'off');
    
    clear tmp id
    tmp = find(btsrp.(boottests{(i+1)/2})(2,:) < 0); % Find indices for values < 0 (i.e. signal lower than baseline)
    id = tmp(consec_idx(tmp, thres));
    plot(time(id), (yMin + offsetsboot(i+1) * ones(size(time(id), 2), 2)), 's', 'MarkerSize', 7, 'MarkerFaceColor', colors{(i+1)/2}, 'Color', colors{(i+1)/2}, 'HandleVisibility', 'off');
end

% Plotting permutation tests
for i = 1:length(permtests)
    tmp = find(perm.(permtests{i})(1, :) < p);
    id = tmp(consec_idx(tmp, thres));
    plot(time(id), (yMin + offsetsperm(i)) * ones(size(time(id), 2), 2), 's', 'MarkerSize', 7, 'MarkerFaceColor', markersperm{i}, 'Color', markersperm{i}, 'HandleVisibility', 'off');
end

% Adding zero reference lines and title
line([ax.XLim(1), ax.XLim(2)], [0, 0], 'Color', 'black', 'HandleVisibility', 'off');
line([0, 0], [yLimits(1), yLimits(2)], 'Color', 'black', 'HandleVisibility', 'off');
title('Choice');  
