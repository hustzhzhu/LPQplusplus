%----Function: Retrieve the raw low-level descriptor dataset and extract the sample information
%----Input:
% dataPath - the root folder of the raw low-level descriptor samples
%----Output:
% database - a structure of the sample dataset
%                                       .imgNum - the number of images
%                                       .imgName - the image names
%                                       .className - the class names
%                                       .classNum - the number of classes
%                                       .imgLabel - the sample labels
%                                       .pathLabel - the folder labels
%                                       .path - the root folder path of samples corresponding to each class
%----AUTHOR:
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07

function [database] = retr_database(dataPath)

disp('dir the low-level descriptor database....');

database = [ ];
database.imgNum = 0;
database.imgName = { };
database.className = { };
database.classNum = 0;
database.imgLabel = [ ];
database.pathLabel = [ ];
database.path = { };

subfolders = dir(dataPath);
for ii = 1:length(subfolders)
    subname = subfolders(ii).name;
    tmpName = { };
    
    if ~strcmp(subname, '.') && ~strcmp(subname, '..')
        database.classNum = database.classNum + 1;
        database.className{database.classNum} = subname;
        
        frames = dir(fullfile(dataPath, subname, '*.mat'));
        
        for jj = 1:length(frames)
            datafileName = frames(jj).name;
            idx = strfind(datafileName, '_');   
            imgName = datafileName(1:idx(end-1)-1);
            tmpName = [tmpName, imgName];
        end
        database.imgName = [database.imgName, unique(tmpName)];
        database.imgNum = database.imgNum + length(unique(tmpName));
        database.imgLabel = [database.imgLabel; ones(length(unique(tmpName)), 1) * database.classNum];
        database.pathLabel = [database.pathLabel, database.classNum];
        database.path = [database.path; [dataPath, '/', subname]];
    end
end

database.imgName = (database.imgName)';
database.className = (database.className)';
database.pathLabel = (database.pathLabel)';










