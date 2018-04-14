format long;
currentFile = 'MattTri_triathlon.csv';
wFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data';
traininSetFolder = 'processed\200_TrainingSet';
activityFolder = 'Activity_Definitions'
inFolder = 'raw';

DefFile = strcat('Activity_Definitions_300_150_4predictions_', currentFile);
DefPattern = char(fullfile(wFolder,traininSetFolder,activityFolder, DefFile));

C = strsplit(inFile, '_');
grFile=strcat(C(1),'_gr.csv');
grPattern = char(fullfile(wFolder,grFile));



GR = readtable(grPattern);
Def = readtable(DefPattern, 'ReadVariableNames',false);

delay = [];

for i = 1: size(GR,1)
    startDelay = -99999;
    stopDelay = -99999;
    label = char(GR{i,1});
    jars = size(Def,1);
    if(i <= size(Def,1))
        predicted = char(Def{i,1});
        if (strcmp(label, predicted))
            startDelay = Def{i,2} - GR{i,2};
            stopDelay = Def{i,3} - GR{i,3};
            delay = [delay; label num2cell(startDelay) num2cell(stopDelay)];
        else
            delay = [delay; label num2cell(startDelay) num2cell(stopDelay)];
        end
    else
        delay = [delay; label num2cell(startDelay) num2cell(stopDelay)]; 
    end
end

outFile = strcat('DELAY_', inFile);
outDELAYPattern = char(fullfile(wFolder, traininSetFolder, outFile )); % Change to whatever pattern you need.
cell2csv(outDELAYPattern,delay);