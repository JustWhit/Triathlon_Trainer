format long;
inFile = 'MattTri_triathlon.csv';
workFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data';
procFolder = 'processed';
rawFolder = 'raw';

% PvsGTfile = strcat('PvsGT_', inFile);
% PvsGRPattern = char(fullfile(wFolder, PvsGTfile));
% 
% PvsGR = readtable(PvsGRPattern);
truelabels = cellstr(PvsGT{:,2});
output = cellstr (PvsGT{:,1});
CP = classperf(truelabels, output);
