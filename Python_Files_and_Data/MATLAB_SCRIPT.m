%Folder name
Folder = 'Z:\GitRepositories\Triathlon_Trainer\Python_Files_and_Data\';
%check if folder exists
if ~isdir(Folder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end


% Get a list of all files in the folder with the desired file name pattern.
activities = ["bike","run","swim","transition"];
for x = 1: length(activities)
    filePattern = fullfile(myFolder, '*bike.csv'); % Change to whatever pattern you need.
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


%% SVM
