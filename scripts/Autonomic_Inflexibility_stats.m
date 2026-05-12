% 1. Extract the Standard Deviations for Alcohol and Social
alc_stds = all_std(strcmp(all_choiceTypes, 'Alcohol'));
soc_stds = all_std(strcmp(all_choiceTypes, 'Social'));

alc_cvs = all_cv(strcmp(all_choiceTypes, 'Alcohol'));
soc_cvs = all_cv(strcmp(all_choiceTypes, 'Social'));

alc_mean = all_means(strcmp(all_choiceTypes, 'Alcohol'));
soc_mean = all_means(strcmp(all_choiceTypes, 'Social'));

% Note: A paired t-test requires both arrays to be the exact same length. 
% This means you can only include rats that actually made AT LEAST ONE 
% of both choices (Alcohol and Social) in the sessions you are analyzing.

% Manual Paired t-test
differences = alc_stds - soc_stds;
n = length(differences);
mean_diff = mean(differences);
std_diff = std(differences);
SE_diff = std_diff / sqrt(n);
t_stat = mean_diff / SE_diff;
df = n - 1;

fprintf('t-statistic: %.4f\n', t_stat);
fprintf('Degrees of freedom: %d\n', df);

% The critical t-value for alpha = 0.05 (two-tailed) with df ~ 22 is approx 2.074
if abs(t_stat) > 2.074
    disp('Result: SIGNIFICANT difference (p < 0.05)');
else
    disp('Result: NOT significantly different');
end