format long;
% currentFile = 'MattTri_triathlon.csv';
% currentFile = 'justin_combo_brb.csv';
% currentFile = 'John_combo_rB.csv';
% currentFile = 'Matt_combo_bR.csv'; 
% currentFile = 'Radlyn_combo_rb.csv';
wFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data';
traininSetFolder = 'processed\400_TrainingSet15APR';
activityFolder = 'Activity_Definitions1'
inFolder = 'raw';

DefFile = strcat('Activity_Definitions_300_4_11fpredictions_', currentFile);
DefPattern = char(fullfile(wFolder,traininSetFolder,activityFolder, DefFile));

C = strsplit(currentFile, '_');
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

outFile = strcat('DELAY_', currentFile);
outDELAYPattern = char(fullfile(wFolder, traininSetFolder, outFile )); % Change to whatever pattern you need.
cell2csv(outDELAYPattern,delay);



%% delay graph

Folder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\processed\400_TrainingSet15APR\Delay';

fileregex = strcat('*','.csv');
    filePattern = char(fullfile(Folder, fileregex)); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    theFiles = fliplr(theFiles);
   bikestart=[];
   bikestop=[];
   runstart=[];
   runstop=[];
   swimstart=[];
   swimstop=[];
   bike=0;
   run=0;
   swim=0;
    activities = {'bike', 'run', 'swim'};
     
   for k = 1 : length(theFiles)
       thisfile=char(fullfile(theFiles(k).folder,theFiles(k).name));
       disp(thisfile);
       f = readtable(thisfile);
       f=table2cell(f);
       for i=1: size(f,1)
          
           if (strcmp(activities(1), f(i,1)))
               bikestart = [bikestart; f{i,2}];
               bikestop = [bikestop; f{i,3}];
               bike = bike +1;
           end
           if (strcmp(activities(2), f(i,1)))
               runstart = [runstart; f{i,2}];
               runstop = [runstop; f{i,3}];
               run = run+1;
           end
           if (strcmp(activities(3), f(i,1)))
               swimstart = [swimstart; f{i,2}];
               swimstop = [swimstop; f{i,3}];
               swim = swim+1;
           end
                   
       end
   end

  
%   x=[bikeD; runD; swimD];
%   g = [zeros(length(bikeD),1); ones(length(runD),1); 2*ones(length(swimD),1)];
 
  

y = [mean(bikestart(:,1)) mean(bikestop(:,1)); mean(runstart(:,1)) mean(runstop(:,1)); mean(swimstart(:,1)) mean(swimstop(:,1))];
b = [std(bikestart(:,1)) std(bikestop(:,1)); std(runstart(:,1)) std(runstop(:,1)); std(swimstart(:,1)) std(swimstop(:,1))];

figure;
hold on;
box on;


x = 1:3;
 bar(x,y);

%barwitherr(b,y);
labels = {'Bike' 'Run' 'Swim'};
XTick= 1:3;
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', labels);





% ctrs = 1:3;
% data = y;
% hBar = bar(ctrs,data);
% for k1 = 1:3
%     ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
%     ydt(k1,:) = hBar(k1).YData;
% end
% 
% errorbar(ctr, ydt, b, '.r')
% errorbar(y,std_dev ,'.')
  
% boxplot(x,g,'Labels',activities);%,'Whisker',1
   
% outfile = char(fullfile(Folder, 'Total_Delay.csv'));
% %x = cell2mat(x);
% dlm(outfile, x);

% trace1 = struct(...
%   'x', { {'Bike' 'Run' 'Swim'} }, ...
%   'y', [mean(bikestart(:,1)),mean(runstart(:,1)),mean(swimstart(:,1))], ...
%   'name', 'START', ...
%   'error_y', struct(...
%     'type', 'data', ...
%     'array',[std(bikestart(:,1)),std(runstart(:,1)),std(swimstart(:,1))] , ...
%     'visible', true), ...
%   'type', 'bar');
% trace2 = struct(...
%   'x', { {'Bike' 'Run' 'Swim'} }, ...
%   'y', [mean(bikestop(:,1)),mean(runstop(:,1)),mean(swimstop(:,1))], ...
%   'name', 'STOP', ...
%   'error_y', struct(...
%     'type', 'data', ...
%     'array', [std(bikestop(:,1)),std(runstop(:,1)),std(swimstop(:,1))], ...
%     'visible', true), ...
%   'type', 'bar');
% data = {trace1, trace2};
% layout = struct('barmode', 'group');
% barplot(data, struct('layout', layout, 'filename', 'error-bar-bar', 'fileopt', 'overwrite'));








