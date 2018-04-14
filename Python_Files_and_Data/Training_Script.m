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
activities = {'bike', 'run', 'swim', 'transition'}; %, 'transition'
for x = 1: length(activities)
    fileregex = strcat('*',activities(x),'.csv');
    filePattern = char(fullfile(inFolder, fileregex)); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    theFiles = fliplr(theFiles);
    fv=[];
    for k = 1 : length(theFiles)
        
            
            thisfile=char(fullfile(theFiles(k).folder,theFiles(k).name));
            disp(thisfile);
            f = readtable(thisfile);
            f1 = sortrows(f,1);
            %f1 = normalize(f2{:,'scale','std');   

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
            %magAccel = (magAccel - mean(magAccel)) ./ std(magAccel);

            gx=f1{:,5};
            gy=f1{:,6};
            gz=f1{:,7};

            sgx = smooth(gx,5, 'lowess');
            sgy = smooth(gy,5, 'lowess');
            sgz = smooth(gz,5, 'lowess');

            magGyro = sqrt(sgx.^2 + sgy.^2 + sgz.^2);
            %magGyro = (magGyro - mean(magGyro)) ./ std(magGyro);
            
            window=90;
            for i=1:30:size(magAccel,1)-window
               currentA = magAccel(i:i+window );
               currentG = magGyro(i:i+window);
               thisTime = [time(i) time(i+window)];
               fv = [fv; features(x,currentA, currentG)]; % meanPDistA stdPDistA stdPAmpA meanPAmpA rmsAmpA
               if(size(fv,1)>=200)
                    break;
               end
            end
    %print to file
           
        
    end
    %set nan to 0
    
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



function X = features(x,currentA,currentG)
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
   
   GE = entropy(currentG);
   AE = entropy(currentA);

   X = [x meanPDistG stdPDistG stdPAmpG meanPAmpG rmsAmpG meanPDistA stdPDistA stdPAmpA meanPAmpA rmsAmpA freqPSDA freqPSDG]; % meanPDistA stdPDistA stdPAmpA meanPAmpA rmsAmpA
   X(isnan(X))=0;
 end