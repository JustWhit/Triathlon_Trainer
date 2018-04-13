currentFile = 'MattTri_triathlon.csv';
wFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data';
outFolder = 'processed';
inFolder = 'raw';

DefFile = strcat('Activity_Definitions_predictions_', currentFile);
DefPattern = char(fullfile(wFolder, DefFile));


grFile=strcat(C(1),'_gr.csv');
grPattern = char(fullfile(wFolder,grFile));



GR = readtable(grPattern);
Def = readtable(DefPattern);

delay = [];

for i = 1: size(GR,1)
    if (GR{i,1} == Def{i,1})
end


