format long;
inFile = 'MattTri_triathlon.csv';
% inFile = 'justin_combo_brb.csv';
% inFile = 'John_combo_rB.csv';
% inFile = 'Matt_combo_bR.csv'; 
% inFile = 'Radlyn_combo_rb.csv';
workFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data';
procFolder = 'processed\200_TrainingSet\PredVSGT';
rawFolder = 'raw';

PvsGTfile = strcat('300_150_4PvsGT_', inFile);
PvsGRPattern = char(fullfile(wFolder, procFolder, PvsGTfile));

%PvsGR = readtable(PvsGRPattern);

swimTruePos=0;
swimFalsePos=0;
swimTrueNeg=0;
runTruePos=0;
runFalsePos=0;
runTrueNeg=0;
bikeTruePos=0;
bikeFalsePos=0;
bikeTrueNeg=0;
tranTruePos=0;
tranFalsePos=0;
tranTrueNeg=0;
overallAcc = 0;
group = PvsGR(:,1);
grouphat = PvsGR(:,2);
NumRows = size(PvsGR,1);
NumCorrect = 0;
for i=1:NumRows
    if(strcmp(PvsGR{i,1},PvsGR{i,2}))
        NumCorrect = NumCorrect + 1;
    end
end

overallAcc = NumCorrect / NumRows;
disp(overallAcc);
[CM, order] = confusionmat(group,grouphat,'Order',{'transition', 'bike', 'run', 'swim'});

disp(CM);
figure;
plotConfMat(CM, order);

