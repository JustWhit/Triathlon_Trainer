format long;
% inFile = 'MattTri_triathlon.csv';
inFile = 'justin_combo_brb.csv';
% inFile = 'John_combo_rB.csv';
% inFile = 'Matt_combo_bR.csv'; 
% inFile = 'Radlyn_combo_rb.csv';
wFolder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data';
outFolder = 'processed';
inFolder = 'raw';

disp(inFile);
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
%f1 = normalize(f2,'scale','std'); 

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
GTruth = [];
ise = evalin( 'base', 'exist(''PvsGR'',''var'') == 1' );
if ~ise
    PvsGR = [];
end

ise = evalin( 'base', 'exist(''count300'',''var'') == 1' );
if ~ise
    count300 = 0;
end

ise = evalin( 'base', 'exist(''count150'',''var'') == 1' );
if ~ise
    count150 = 0;
end

ise = evalin( 'base', 'exist(''count90'',''var'') == 1' );
if ~ise
    count90 = 0;
end
        
activities = { 'bike', 'run', 'swim', 'transition'};
window=300;
for i=1:30:size(magAccel,1)-window
   currentA = magAccel(i:i+window);
   currentG = magGyro(i:i+window);
   currentSax = sax(i:i+window);
   currentSay = say(i:i+window);
   thisTime = [time(i) time(i+window)];
   
   
   
   fv = features(currentA,currentG,currentSax, currentSay);
   
        
   
   [label,score] = predict(BaggedTree300_4_15f.ClassificationEnsemble,fv);
   count300 = count300 + 1;
   
 %  for d = 1: length(score)
%        if(d ~= label)
%            temp = abs((score(label) - score(d))/((score(label)+score(d))/2)) * 100;
   %Conf = score(label)/sum(score);
   x = (score-min(score))/(max(score)-min(score));
   
   Conf = x(label)/sum(x);
%        end
 %  end
   
   
   if(Conf < 0.5)
       currentA = currentA(1:window/2);
       currentG = currentG(1:window/2);
       currentSax = sax(1:window/2);
       currentSay = say(1:window/2);
       fA = features(currentA, currentG,currentSax, currentSay);
       thisTime = [time(i) time(i+(window/2))];
     [label,score] = predict(BaggedTree150_4_15f.ClassificationEnsemble, fA);
     count150=count150+1;
   end
%    
%   x = (score-min(score))/(max(score)-min(score));
%    Conf = x(label)/sum(x);
%    if(Conf < 0.5)
%        currentA = currentA(1:90);
%        currentG = currentG(1:90);
%        currentSax = sax(1:90);
%        currentSay = say(1:90);
%        fA = features(currentA, currentG, currentSax, currentSay);
%        thisTime = [time(i) time(i+90)];
%      [label,score] = predict(CubicSVM150_4_OR.ClassificationSVM, fA);
%      count90 = count90 + 1;
%    end
   
   
   
   maybe = activities(4);
   for k=1:size(GR,1)
       if( thisTime(1) > GR{k,2} && thisTime(2) < GR{k,3})
          maybe = GR{k,1};
       end
       
   end
   
%    if(Conf < 0.6)
%        Plabel = activities(4);
%    elseif(score(label) < 0.3)
%        Plabel = activities(4);
%    else
       Plabel = activities(label);
%    end
   
   
   
   Presult = [Plabel thisTime(1) thisTime(2)];
   
   predicted = [predicted; Presult];
   
   GTruth = [GTruth; maybe];
   
   pvsgr = [Plabel maybe score];
   
   PvsGR = [PvsGR; pvsgr];
   
    
   
   
   
end
 
outFile = strcat('predictions_', inFile);
outPredictedPattern = char(fullfile(wFolder, outFolder, outFile )); % Change to whatever pattern you need.
GTfile = strcat('GT_', inFile);
grFilePattern = char(fullfile(wFolder,outFolder,GTfile));
PvsGTfile = strcat('PvsGT_', inFile);
PvsGRPattern = char(fullfile(wFolder,outFolder, PvsGTfile));
cell2csv(outPredictedPattern,predicted);
cell2csv(grFilePattern,GTruth);
cell2csv(PvsGRPattern,PvsGR);

 function X = features(currentA,currentG,sax,say)
    [apks,alocs] = findpeaks(currentA,'MinPeakProminence',1);
   [gpks,glocs] = findpeaks(currentG,'MinPeakProminence',0.5);
   if(isempty(glocs))
        glocs = zeros(5,1);
        gpks = zeros(5,1);

   end
   [PSDA,Aw] = pwelch(currentA);
   [PSDG, Gw] = pwelch(currentG);
   
   [maxPSDA, Ai] = max(PSDA);
   [maxPSDG, Gi] = max(PSDG);
   freqPSDA = Aw(Ai);
   freqPSDG = Gw(Gi);
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
   
   maxAmpA = max(currentA);
   maxAmpG = max(currentG);
   or = rad2deg(mean(atan(sax./say)));
   GE = entropy(currentG);
   AE = entropy(currentA);

   X = [meanPDistG stdPDistG stdPAmpG meanPAmpG rmsAmpG meanPDistA stdPDistA stdPAmpA meanPAmpA rmsAmpA maxPSDA maxPSDG or GE AE]; % meanPDistA stdPDistA stdPAmpA meanPAmpA rmsAmpA
   X(isnan(X))=0;
 end
 
 
 
