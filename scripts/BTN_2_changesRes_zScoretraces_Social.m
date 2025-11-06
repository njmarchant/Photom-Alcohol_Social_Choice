%% Nathan Marchant September 2025
% Written for the SOCIAL CHOICE task
% A script to make changes in traces, combine them, or add extra info
% zScoring of the traces is also added at the end of this script
clear all
close all

%% define where the stuff is

tankfolder = 'C:\Photometry\Social_045 Photom\2025_R1\Both_(-20_+20)';

%% define timestamps you wanna work with
%!!!! REMEMBER TO CHECK THE NAMES OF THE VARIABBLES ON SESDAT
var1 = {'LTA','LDA','RTA','RDA'}; %Alcohol reward, all boxes
var2 = {'LTS','LDS','RTS','RDS'}; %Social reward, all boxes
var3 = {'LTT','LDT','RTT','RDT'}; %Trial start, all boxes
var4 = {'LTI','LDI','RTI','RDI'}; %Inactive press, all boxes



%% load individual session data
filePath = fullfile(tankfolder);
files = dir(fullfile(filePath));
files(ismember({files.name}, {'.', '..'})) = [];
files = files(~[files.isdir]);
for i = 1:length(files) %iterate through experiment folder
%     if strfind(files(i).name, r)
    if isfile(fullfile(filePath,  [files(i).name]))
        load(fullfile(filePath,  [files(i).name]))

    names = strsplit(files(i).name, {'-' , '_', ' ', '.'}); %divide the file name into separte character vectors
    r = sesdat.rat;
% Added the section below to define value in the second column of each trace 
% This is to make sure that alc=1, soc=2, trial=3, inact=4
    v1 = [];
    v1A = [];
    v1S = [];
    v1T = [];
    v1I = [];
    for j = 1:length(var1)
        if any(contains(sesdat.traces(:,1), var1(j)))
            v1A = cell2mat(sesdat.traces(contains(sesdat.traces(:,1), var1), 2));
            v1A(:,2) = 1;
        end
    end
    
    for j = 1:length(var2)
        if any(contains(sesdat.traces(:,1), var2(j)))
            v1S = cell2mat(sesdat.traces(contains(sesdat.traces(:,1), var2),2));
            v1S(:,2) = 2;
        end
    end
    
    for j = 1:length(var3)
        if any(contains(sesdat.traces(:,1), var3(j)))
            v1T = cell2mat(sesdat.traces(contains(sesdat.traces(:,1), var3),2));
            v1T(:,2) = 3;
        end
    end
    
    for j = 1:length(var4)
        if any(contains(sesdat.traces(:,1), var4(j)))
            v1I = cell2mat(sesdat.traces(contains(sesdat.traces(:,1), var4),2));
            v1I(:,2) = 4;
        end
    end
    
    arrays = {v1A,v1S,v1T,v1I};
    for j = 1:length(arrays)
        if ~isempty(arrays{j})
            if isempty(v1)
                v1= arrays{j};
            else
                v1 = cat(1, v1, arrays{j});
            end
        end
    end

       
if ~isempty(v1)
for k = 1:length(v1(:,1))-1
        if v1(k, 2) == 3 && v1(k+1,1) < v1(k, 1)+15
                v1(k+ 1,3) = 1;
        elseif v1(k, 2) ~=3 && v1(k+1, 1) < v1(k, 1)+5
            v1(k+1,3) = 2;
        else
            continue
        end
end
end      

%_______________________Code the trials with the eventual outcome_______________  
% column3 = (Alcohol chosen = 1, Social chosen = 2, Trial omit = 0)
tmp = [];
tmp = v1(v1(:,2) == 1 | v1(:,2) == 2,:);  %put the RESPONSE times in a tmp array
for j = 1:size(v1,1)
    for k = 1:size(tmp)
                TrialStart = v1(j,1);
                Choice_Time = tmp(k);
                if Choice_Time-TrialStart > 10 && Choice_Time-TrialStart < 122
                    if tmp(k,2) == 1
                        v1(j,4) = 1;
                        v1(j,3) = Choice_Time-TrialStart-10;
                    elseif tmp(k,2) == 2
                    v1(j,4) = 2;
                    v1(j,3) = Choice_Time-TrialStart-10;
                else
                v1(j,3) = 0;
            end
        end
    end
end


%%
% Count the alcohol and social responses and calculate the preference score
% for that session
tot_alc = sum(v1(:,2) == 1);
tot_soc = sum(v1(:,2) == 2);
pref = (tot_soc-tot_alc)/(tot_soc+tot_alc);

%%
% code the sex into sesdat
M = {'R1','R2','R5','R6','R8','R9','R21','R22','R23','R24','R26','R27'};
found = any(strcmp(r, M));

% Check if the value was found and code the sex
if found
    sesdat.sex = 'Male';
else
    sesdat.sex = 'Female';
end
 
%%
sesdat.pref = pref;
sesdat.traces_updated = v1;

sesdat.hemi = names{4};
sesdat.rat = names{7};

%% code the session details
C1 = {'230515','230816'};
C2 = {'230516','230817'};
C3 = {'230517','230818'};
C4 = {'230519','230821'};
C5 = {'230522','230822'};
C6 = {'230523','230823'};
C7 = '230824';
C8 = '230825';
P1 = {'230524','230828'};
P2 = {'230525','230829'};
P3 = {'230526','230830'};
P4 = {'230530','230831'};

ses = names{5};

if any(strcmp(ses,C1))
    sesdat.ses = 'C1';
elseif any(strcmp(ses,C2))
    sesdat.ses = 'C2';
elseif any(strcmp(ses,C3))
    sesdat.ses = 'C3';
elseif any(strcmp(ses,C4))
    sesdat.ses = 'C4';
elseif any(strcmp(ses,C5))
    if strcmp(ses,'230522')
        sesdat.ses = {'C5','L1'};
    else
        sesdat.ses = 'C5';
        
    end
elseif any(strcmp(ses,C6))
    if strcmp(ses,'230523')
        sesdat.ses = {'C6','L2'};
    else
        sesdat.ses = 'C6';
    end
elseif strcmp(ses,C7)
    sesdat.ses = {'C7','L1'};
elseif strcmp(ses,C8)
    sesdat.ses = {'C8','L2'};
elseif any(strcmp(ses,P1))
    sesdat.ses = 'P1';
elseif any(strcmp(ses,P2))
    sesdat.ses = 'P2';
elseif any(strcmp(ses,P3))
    sesdat.ses = 'P3';
elseif any(strcmp(ses,P4))
    sesdat.ses = 'P4';
else
    sesdat.ses = 'null';
end



%% 
% Here we perform z-score calulations of the traces. 
% Trace data is taken from 'sesdat.traces_updated' and after conversion
% this data is saved in 'sesdat.traces_z';

% variables to save
    sesdat.traces_z = [];
% get variables
    data = sesdat.traces_updated(:, 5:end);
    times = sesdat.traces_updated(:, 1:4);
    % dat.rat = r;
    % dat.sesdat = sesdat;
       
%define time, baseline
% Ensure that this matches what is extracted in the first script!
    time = linspace(-20, 20, size(data, 2)); %time vector the size of trace
    base = (time >= -20) & (time <= -15); %This is the time period of the trace for which the baseline is calculated
     
% zscore standardisation on df/f
    zdata = zeros(size(data));
    zbase = zeros(size(data));
    tmp = 0;
        for m = 1:size(data, 1)
            zb = mean(data(m, base));
            zsd = std(data(m,base));
            for j = 1:size(data,2)
                tmp = tmp+1;
                zbase(m, tmp) = (data(m,j) -zb);
                zdata(m,tmp) = (data(m,j) - zb)/zsd;
            end
            tmp = 0;
        end
    traces_z = [times, zdata];  
    sesdat.traces_z = [sesdat.traces_z;traces_z];

% save file (overwrites previous file, so be careful not to change
% anything)
    save([filePath '\' files(i).name(1:end-4) '.mat'], 'sesdat')

    end
end