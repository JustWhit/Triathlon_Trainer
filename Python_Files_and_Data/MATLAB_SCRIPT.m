
%% SVM
%Folder name
inFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\raw\';
trainFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\training_data\';
%check if folder exists
if ~isdir(inFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', inFolder);
  uiwait(warndlg(errorMessage));
  return;
end
if ~isdir(trainFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', outFolder);
  uiwait(warndlg(errorMessage));
  return;
end


% Get a list of all files in the folder with the desired file name pattern.
activities = {'bike', 'run', 'swim', 'transition'};
for x = 1: length(activities)
    fileregex = strcat(activities(x),'.csv');
    filePattern = char(fullfile(inFolder, fileregex)); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    for k = 1 : length(theFiles)
      baseFileName = theFiles(k).name;
      fullFileName = fullfile(myFolder, baseFileName);
      fprintf(1, 'Now reading %s\n', fullFileName);
      % Now do whatever you want with this file name,
      % such as reading it in as an image array with imread()
      imageArray = imread(fullFileName);
      imshow(imageArray);  % Display image.
      drawnow; % Force display to update immediately.
    end
end


%% confusion matrix
Folder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\';
%check if folder exists
if ~isdir(Folder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end

filename='Gt_versus_P_justin_combo_brb.csv';
Vfile = strcat(Folder,filename);
V=readtable(Vfile);

%order = {'transition','bike','run','swim'};
grouphat = V{:,1};
group = V{:,2};
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





%% training data
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


% Get a list of all files in the folder with the desired file name pattern.
activities = {'bike', 'run', 'swim', 'transition'};
for x = 1: length(activities)
    fileregex = strcat('*',activities(x),'.csv');
    filePattern = char(fullfile(inFolder, fileregex)); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    fv = [];
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

        fv=[];
        window=90;
        for i=1:30:size(magAccel,1)-window
           currentA = magAccel(i:i+window );
           currentG = magGyro(i:i+window);
           thisTime = [time(i) time(i+window)];
%            [apks,alocs] = findpeaks(currentA,'MinPeakProminence',1);
           [gpks,glocs] = findpeaks(currentG,'MinPeakProminence',0.5);
           if(isempty(glocs))
                glocs = zeros(5,1);
                gpks = zeros(5,1);

           end
           
%           meanPDistA = mean(diff(alocs)); %mean of the Distance between peaks for Accel magnitude
%           stdPDistA = std(diff(alocs));% standard deviation of the Distance between peaks for Accel magnitude
            meanPDistG = mean(diff(glocs)); % mean of the distance between peraks for Gyro magnitude
            stdPDistG = std(diff(glocs)); % standard deviation for the distance between peaks for Gyro magnitude
           
           

%            stdPAmpA = std(apks); %standard deviation of the amplitude of the peaks for Accel magnitude
%            meanPAmpA = mean(apks); %mean of the amplitude of the peaks for Accel magnitude
           stdPAmpG = std(gpks); % standard deviation of the amplitude of the peaks for Gyro magnitude
           meanPAmpG = mean(gpks);
%            rmsAmpA = rms(currentA); % RMS of the amplitude for Accel magnitude
           rmsAmpG = rms(currentG); % RMS of the amplitude for Gyro magnitude
           
           fv = [fv; meanPDistG stdPDistG stdPAmpG meanPAmpG rmsAmpG];
        end
%print to file
        fv = [fv; fv];
        
    end
    %set nan to 0
    fv(isnan(fv))=0;
    
    afile = strcat(activities(x),'.csv');
    outfile = char(strcat(outFolder,afile));
    csvwrite(outfile,fv);
    figure; hold on;
    plot(fv);
    title(activities(x));
end


%% activityProcessing
format long;
inFile = 'Matt_triathlon.csv';
inFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\raw';
outFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\processed';
%check if folder exists
if ~isdir(inFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', inFolder);
  uiwait(warndlg(errorMessage));
  return;
end

filePattern = char(fullfile(inFolder, inFile)); % Change to whatever pattern you need.

f = readtable(filePattern);
f1 = sortrows(f,1);
time = f1{:,1};


        
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

fv=[];
window=90;
for i=1:30:size(magAccel,1)-window
   currentA = magAccel(i:i+window );
   currentG = magGyro(i:i+window);
   thisTime = [time(i) time(i+window)];
%            [apks,alocs] = findpeaks(currentA,'MinPeakProminence',1);
   [gpks,glocs] = findpeaks(currentG,'MinPeakProminence',0.5);
   if(isempty(glocs))
        glocs = zeros(5,1);
        gpks = zeros(5,1);

   end

%           meanPDistA = mean(diff(alocs)); %mean of the Distance between peaks for Accel magnitude
%           stdPDistA = std(diff(alocs));% standard deviation of the Distance between peaks for Accel magnitude
    meanPDistG = mean(diff(glocs)); % mean of the distance between peraks for Gyro magnitude
    stdPDistG = std(diff(glocs)); % standard deviation for the distance between peaks for Gyro magnitude



%            stdPAmpA = std(apks); %standard deviation of the amplitude of the peaks for Accel magnitude
%            meanPAmpA = mean(apks); %mean of the amplitude of the peaks for Accel magnitude
   stdPAmpG = std(gpks); % standard deviation of the amplitude of the peaks for Gyro magnitude
   meanPAmpG = mean(gpks);
%            rmsAmpA = rms(currentA); % RMS of the amplitude for Accel magnitude
   rmsAmpG = rms(currentG); % RMS of the amplitude for Gyro magnitude

   fv = [fv; thisTime meanPDistG stdPDistG stdPAmpG meanPAmpG rmsAmpG];
end


fv(isnan(fv))=0;
    
afile = strcat('processed_',inFile);
outfile = char(fullfile(outFolder,afile));

dlmwrite(outfile,fv,'delimiter',',','precision',15);
figure; hold on;








