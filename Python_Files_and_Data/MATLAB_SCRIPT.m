

%% junk

inFile = 'justin_combo_brb_features.csv';
inFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\processed';
wFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data';
outFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\SVM_pred';

%check if folder exists
if ~isdir(inFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', inFolder);
  uiwait(warndlg(errorMessage));
  return;
end
%check if folder exists
if ~isdir(outFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', outFolder);
  uiwait(warndlg(errorMessage));
  return;
end

AFPattern = char(fullfile(inFolder, inFile)); % Change to whatever pattern you need.
TLPattern = char(fullfile(wFolder, strcat('t_list_',inFile)));
ActualPattern = char(fullfile(wFolder, strcat('Actual_',inFile)));
GTPattern = char(fullfile(wFolder,strcat('Gt_',inFile)));

AF = readtable(AFPattern);
TL = readtable(TLPattern);
Actual = readtable(ActualPattern);
GT = readtable(GTPattern);


%% confusion matrix
% Folder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\';
% %check if folder exists
% if ~isdir(Folder)
%   errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
%   uiwait(warndlg(errorMessage));
%   return;
% end
% 
% filename='Gt_versus_P_justin_combo_brb.csv';
% Vfile = strcat(Folder,filename);
% V=readtable(Vfile);

%order = {'transition','bike','run','swim'};
grouphat = yfit % V{:,1};
group = GtJustinbrb % V{:,2};
% grouphat={1,length(p)};
% for item = 1: length(P)
%     for x = 1:length(order)
%        if p(item)==order(x)
%            grouphat(item) = x;
%        end
%     end
% end
% group={1,length(Gt)};
% for item = 1: length(Gt)
%     for x = 1:length(order)
%        if Gt(item)==order(x)
%            group(item) = x;
%        end
%     end
% end

[C,order] = confusionmat(group,grouphat,'Order',{'transition','bike','run','swim'});
disp(C);
disp(order);
%display_matrix(C,'title','Over sized Swim Tdata');
%plotconfusion(group,grouphat,'Justin_brb');





%% training data feature extraction
inFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\raw\';
outFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\training_data\';
%check if folder exists
if ~isdir(inFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', inFolder);
  uiwait(warndlg(errorMessage));
  return;
end
if ~isdir(outFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', outFolder);
  uiwait(warndlg(errorMessage));
  return;
end

super = [];
testaccel = [];
testgyro = [];

% Get a list of all files in the folder with the desired file name pattern.
activities = {'bike', 'run', 'swim', 'transition'};
for x = 1: length(activities)
    fileregex = strcat('*',activities(x),'.csv');
    filePattern = char(fullfile(inFolder, fileregex)); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    
    fv=[];
    for k = 1 : length(theFiles)
        
            
            thisfile=char(fullfile(theFiles(k).folder,theFiles(k).name));
            f = readtable(thisfile);
            f1 = sortrows(f,1);


            time = f1{:,1};
            %time = str2double(time);
            %tr=timeseries(,time)
            %tf = timeseries (smoothed,time);
            % figure;hold on;
            % plot(time,sax, 'r-');
            % plot(time,ax, 'b');
            % figure;hold on;
            % plot(time,say,'r-');
            % plot(time,ay,'b');
            % figure;hold on;
            % plot(time,saz,'r-');
            % plot(time,az,'b');



            ax=f1{:,2};
            ay=f1{:,3};
            az=f1{:,4};

            sax = smooth(ax,5, 'lowess');
            say = smooth(ay,5, 'lowess');
            saz = smooth(az,5, 'lowess');

            magAccel = sqrt(sax.^2 + say.^2 + saz.^2);

            gx=f1{:,5};
            gy=f1{:,6};
            gz=f1{:,7};

            sgx = smooth(gx,5, 'lowess');
            sgy = smooth(gy,5, 'lowess');
            sgz = smooth(gz,5, 'lowess');

            magGyro = sqrt(sgx.^2 + sgy.^2 + sgz.^2);

            
            window=150;
            for i=1:30:size(magAccel,1)-window
               currentA = magAccel(i:i+window );
               currentG = magGyro(i:i+window);
               thisTime = [time(i) time(i+window)];
                [apks,alocs] = findpeaks(currentA,'MinPeakProminence',1);
               [gpks,glocs] = findpeaks(currentG,'MinPeakProminence',0.5);
               if(isempty(glocs))
                    glocs = zeros(5,1);
                    gpks = zeros(5,1);

               end
               PSDA = pwelch(currentA);
               PSDG = pwelch(currentG);
              maxPSDA = max(PSDA);
              maxPSDG = max(PSDG);
              meanPDistA = mean(diff(alocs)); %mean of the Distance between peaks for Accel magnitude
              stdPDistA = std(diff(alocs));% standard deviation of the Distance between peaks for Accel magnitude
                meanPDistG = mean(diff(glocs)); % mean of the distance between peraks for Gyro magnitude
                stdPDistG = std(diff(glocs)); % standard deviation for the distance between peaks for Gyro magnitude



               stdPAmpA = std(apks); %standard deviation of the amplitude of the peaks for Accel magnitude
               meanPAmpA = mean(apks); %mean of the amplitude of the peaks for Accel magnitude
               stdPAmpG = std(gpks); % standard deviation of the amplitude of the peaks for Gyro magnitude
               meanPAmpG = mean(gpks);
               rmsAmpA = rms(currentA); % RMS of the amplitude for Accel magnitude
               rmsAmpG = rms(currentG); % RMS of the amplitude for Gyro magnitude

               fv = [fv; x meanPDistG stdPDistG stdPAmpG meanPAmpG rmsAmpG meanPDistA stdPDistA stdPAmpA meanPAmpA rmsAmpA maxPSDA maxPSDG]; % meanPDistA stdPDistA stdPAmpA meanPAmpA rmsAmpA
               if(size(fv,1)>=900)
                    break;
               end
            end
    %print to file
           
        
    end
    %set nan to 0
    fv(isnan(fv))=0;
    super = [super; fv];
    afile = strcat(activities(x),'.csv');
    outfile = char(strcat(outFolder,afile));
    dlmwrite(outfile,fv);
    figure; hold on;
    plot(fv);
    title(activities(x));
    
    if(x==1 || x==4)
       testaccel = [testaccel; magAccel];
       testgyro = [testgyro; magGyro];
        
    end
end


%% activity Feature extraction




format long;
inFile = 'justin_combo_brb.csv';
wFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data';
outFolder = 'processed';
inFolder = 'raw';
%check if folder exists
if ~isdir(wFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', inFolder);
  uiwait(warndlg(errorMessage));
  return;
end
C = strsplit(inFile, '_');
grFile=strcat(C(1),'_gr.csv');
filePattern = char(fullfile(wFolder, inFolder, inFile)); % Change to whatever pattern you need.
grPattern = char(fullfile(wFolder,grFile));

f = readtable(filePattern);
f1 = sortrows(f,1);
time = f1{:,1};
start = time(1);
for i=1:length(time)
   time(i)=time(i)-start; 
end

GR = readtable(grPattern);

%time = str2double(time);
%tr=timeseries(,time)
%tf = timeseries (smoothed,time);
% figure;hold on;
% plot(time,sax, 'r-');
% plot(time,ax, 'b');
% figure;hold on;
% plot(time,say,'r-');
% plot(time,ay,'b');
% figure;hold on;
% plot(time,saz,'r-');
% plot(time,az,'b');



ax=f1{:,2};
ay=f1{:,3};
az=f1{:,4};

sax = smooth(ax,5, 'lowess');
say = smooth(ay,5, 'lowess');
saz = smooth(az,5, 'lowess');

magAccel = sqrt(sax.^2 + say.^2 + saz.^2);

gx=f1{:,5};
gy=f1{:,6};
gz=f1{:,7};

sgx = smooth(gx,5, 'lowess');
sgy = smooth(gy,5, 'lowess');
sgz = smooth(gz,5, 'lowess');

magGyro = sqrt(sgx.^2 + sgy.^2 + sgz.^2);
predicted = [];
GR = [];
PvGR = [];
activities = [ 'bike' 'run' 'swim' 'transition'];
window=300;
for i=1:30:size(magAccel,1)-window
   currentA = magAccel(i:i+window);
   currentG = magGyro(i:i+window);
   thisTime = [time(i) time(i+window)];
   
   
   
   fv = features(currentA,currentG);
   
        
   
   [label,score] = predict(BaggedTree10.ClassificationEnsemble,fv);
   
   PDiff = [];
   for d = 1: 4
       if(d ~= label)
           temp = abs((score(label) - score(d))/((score(label)+score(d))/2)) * 100;
           PDiff = [PDiff temp];
       end
   end
   
   if(min(PDiff) < 40)
       currentA = currentA(1:window/2);
       currentG = currentG(1:window/2);
       fA = features(splitAA, splitGA);
       thisTime = [time(i) time(i+(window/2))];
     [label,score] = predict(BaggedTree5.ClassificationEnsemble, fA);
     
   end
   
   maybe = 'transition';
   for k=1:size(GR,1)
       if( thisTime(1) > GR{k,2} && thisTime(2) < GR{k,3})
          maybe = GR{k,1};
       end
       
   end
   
   Plabel = activities(label);
   
   Presult = [Plabel thisTime(1) thisTime(2)];
   
   predicted = [predicted; Presult];
   
   GR = [GR; maybe];
   
   pvsgr = [score(label) Plabel maybe];
   
   PvsGR = [PvsGR; pvsgr];
   

   
   
   
 end

 function X = features(currentA,currentG)
    [apks,alocs] = findpeaks(currentA,'MinPeakProminence',1);
   [gpks,glocs] = findpeaks(currentG,'MinPeakProminence',0.5);
   if(isempty(glocs))
        glocs = zeros(5,1);
        gpks = zeros(5,1);

   end
   PSDA = pwelch(currentA);
   PSDG = pwelch(currentG);
   maxPSDA = max(PSDA);
   maxPSDG = max(PSDG);
   meanPDistA = mean(diff(alocs)); %mean of the Distance between peaks for Accel magnitude
   stdPDistA = std(diff(alocs));% standard deviation of the Distance between peaks for Accel magnitude
   meanPDistG = mean(diff(glocs)); % mean of the distance between peraks for Gyro magnitude
   stdPDistG = std(diff(glocs)); % standard deviation for the distance between peaks for Gyro magnitude



   stdPAmpA = std(apks); %standard deviation of the amplitude of the peaks for Accel magnitude
   meanPAmpA = mean(apks); %mean of the amplitude of the peaks for Accel magnitude
   stdPAmpG = std(gpks); % standard deviation of the amplitude of the peaks for Gyro magnitude
   meanPAmpG = mean(gpks);
   rmsAmpA = rms(currentA); % RMS of the amplitude for Accel magnitude
   rmsAmpG = rms(currentG); % RMS of the amplitude for Gyro magnitude

   X = [meanPDistG stdPDistG stdPAmpG meanPAmpG rmsAmpG meanPDistA stdPDistA stdPAmpA meanPAmpA rmsAmpA maxPSDA maxPSDG]; % meanPDistA stdPDistA stdPAmpA meanPAmpA rmsAmpA
   X(isnan(X))=0;
 end
    





































