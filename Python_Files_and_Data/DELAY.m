currentFile = 'MattTri_triathlon.csv';
wFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data';
outFolder = 'processed';
inFolder = 'raw';

PvsGTfile = strcat('PvsGT_', currentFile);
PvsGRPattern = char(fullfile(wFolder, PvsGTfile));


grFile=strcat(C(1),'_gr.csv');
grPattern = char(fullfile(wFolder,grFile));



GR = readtable(grPattern);
PvsGR = readtable(PvsGRPattern);


for i=1:size(GR,1)
    startTime = GR{i,2};
    
    
end


