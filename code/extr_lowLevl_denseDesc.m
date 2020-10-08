%----FUNCTION:
% extract and save dense sampled low-level descriptors (LPQ++)
%----INPUT:
% database - the image database information
% blurPara - the structure that contains the image blurring information
%                                                      .gaussian - structure that contains the Gaussian blurring parameters
%                                                      .motion - structure that contains the motion blurring parameters
%                                                      .cirrular - structure that contains the cirrular blurring parameters
% descPara - the structure that contains the low-level descriptor extraction information
%                                                      .PatchSize - multi-scale patch sizes for low-level feature extraction
%                                                      .nStride - stride step for dense sample feature extraction
%                                                      .maxImSize - the maximum image size for descriptor extraction
% samSplit - the structure that contains the sample split inforation for training and test
% idxRound - experiment round index
% dataPath - the path where the raw low-level descriptors are saved
%----OUTPUT:
% NULL
%----AUTHOR:
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07

function extr_lowLevl_denseDesc(database, blurPara, descPara, samSplit, idxRound, dataPath)

addpath('LPQ++');

nPatchType = length(descPara.PatchSize);
nClass = database.classNum;
trSam = samSplit.tr_split{idxRound};    trLabel = samSplit.tr_label{idxRound};
tsSam = samSplit.ts_split{idxRound};    tsLabel = samSplit.ts_label{idxRound};
pathLabel = database.pathLabel;

disp('Extracting low-level descriptors...');

for ii = 1:nClass
    idxTrSam = find(trLabel == ii);
    idxTsSam = find(tsLabel == ii);
    idxTrPath = find(pathLabel == ii);
    idxTsPath = find(pathLabel == ii);
    className = database.className{ii};
    
    for jj = 1:length(idxTrSam)     % extract the low-level descriptors of the training samples  jj=1:20
        filePath = fullfile(database.path{idxTrPath(1)}, trSam{idxTrSam(jj)});
        [pdir, fname] = fileparts(trSam{idxTrSam(jj)});
        fullFileName = trSam{idxTrSam(jj)};
        I = imread(filePath);
        
        if ndims(I) == 3,
            I_color = I;
            I = double(rgb2gray(I));
        else
            I = double(I);
        end;
     
        [im_h, im_w] = size(I);
        
        if max(im_h, im_w) > descPara.maxImSize,
            I = floor(imresize(I, descPara.maxImSize/max(im_h, im_w), 'bicubic'));
        end;
        
        [im_h, im_w] = size(I);
        
        for kk = 1:nPatchType
            
            patchSize = descPara.PatchSize(kk);
            
            % make grid sampling LPQ+ descriptors
            remX = mod(im_w-patchSize,descPara.nStride);
            offsetX = floor(remX/2)+1;
            remY = mod(im_h-patchSize,descPara.nStride);
            offsetY = floor(remY/2)+1;
            [gridX,gridY] = meshgrid(offsetX:descPara.nStride:im_w-patchSize+1, offsetY:descPara.nStride:im_h-patchSize+1);   
            fprintf('Processing %s: wid %d, hgt %d, patch size: %d x %d, grid size: %d x %d, %d patches\n', ...
                fullFileName, im_w, im_h, descPara.PatchSize(kk), descPara.PatchSize(kk), size(gridX, 2), size(gridX, 1), numel(gridX));
            
            % extract and save dense sampled LPQ+
            if sum(strcmp('lpq++', descPara.feaType)) ~= 0  
                LPQplusArr = sp_find_LPQplusplus_grid(I, gridX, gridY, patchSize, descPara);
                feaSet.feaArr = LPQplusArr;
                feaSet.x = gridX(:) + patchSize/2 - 0.5;    feaSet.y = gridY(:) + patchSize/2 - 0.5;
                feaSet.width = im_w;    feaSet.height = im_h;
                folderPath = fullfile(dataPath, className);
                if ~isdir(folderPath) 
                    mkdir(folderPath);
                end
                fpath = fullfile(folderPath, [fname, '_', num2str(descPara.PatchSize(kk)), '_lpq++']);
                save(fpath, 'feaSet');
            end          
        end
    end
    
    for jj = 1:length(idxTsSam)
        filePath = fullfile(database.path{idxTsPath(1)}, tsSam{idxTsSam(jj)});
        [pdir, fname] = fileparts(tsSam{idxTsSam(jj)});
        fullFileName = tsSam{idxTsSam(jj)};
        I = imread(filePath);
        
        if ndims(I) == 3,
            I_color = I;
            I = double(rgb2gray(I));
        else
            I = double(I);
        end;
        
         % execute image blurring
         if blurPara.model ~= 0
             I = img_blurring(I, blurPara);
         end
        
        [im_h, im_w] = size(I);
        
        if max(im_h, im_w) > descPara.maxImSize,
            I = floor(imresize(I, descPara.maxImSize/max(im_h, im_w), 'bicubic'));
        end;
        
        [im_h, im_w] = size(I);
        
        for kk = 1:nPatchType
            
            patchSize = descPara.PatchSize(kk);
            
            % make grid sampling LPQ+ descriptors
            remX = mod(im_w-patchSize,descPara.nStride);
            offsetX = floor(remX/2)+1;
            remY = mod(im_h-patchSize,descPara.nStride);
            offsetY = floor(remY/2)+1;
            
            [gridX,gridY] = meshgrid(offsetX:descPara.nStride:im_w-patchSize+1, offsetY:descPara.nStride:im_h-patchSize+1);
            
            fprintf('Processing %s: wid %d, hgt %d, patch size: %d x %d, grid size: %d x %d, %d patches\n', ...
                fullFileName, im_w, im_h, descPara.PatchSize(kk), descPara.PatchSize(kk), size(gridX, 2), size(gridX, 1), numel(gridX));
            
            % extract and save dense sampled LPQ+
            if sum(strcmp('lpq++', descPara.feaType)) ~= 0  
                LPQplusArr = sp_find_LPQplusplus_grid(I, gridX, gridY, patchSize, descPara);
                feaSet.feaArr = LPQplusArr;
                feaSet.x = gridX(:) + patchSize/2 - 0.5;    feaSet.y = gridY(:) + patchSize/2 - 0.5;
                feaSet.width = im_w;    feaSet.height = im_h;
                folderPath = fullfile(dataPath, className);
                if ~isdir(folderPath)
                    mkdir(folderPath);
                end
                fpath = fullfile(folderPath, [fname, '_', num2str(descPara.PatchSize(kk)), '_lpq++']);
                save(fpath, 'feaSet');
            end
        end
    end
end


