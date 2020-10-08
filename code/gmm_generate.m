%----FUNCTION:
% generate the GMM components for the different descriptors
%----INPUT:
% database - the structure that contains the raw low-level descriptor database information
% nTrainSam - the number of training samples per class
% gmmPath - the path for saving the GMM components
% samSplit - the structure that contains the sample split inforation for training and test
% idxRound - experiment round index
% descPara - the low-level descriptor extraction parameters
% pcaPara - the PCA parameters
% fvPara - the Fisher Vector parameters
% pcaMatrix - PCA transfermation matrix for different descriptors
%----OUTPUT:
% gmmComp - the GMM components for FV
%----AUTHOR:
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07

function [gmmComp] = gmm_generate(database, nTrainSam, gmmPath, samSplit, idxRound, descPara, pcaPara, pcaMatrix, fvPara)

disp('-----------------------------------------');
disp('Generate the GMM components...');
disp('-----------------------------------------');

nDescType = length(descPara.feaType);
nPatchSize = length(descPara.PatchSize);
gmmComp = cell(nDescType*nPatchSize, 1);
nClass = database.classNum;
trSam = samSplit.tr_split{idxRound};    trLabel = samSplit.tr_label{idxRound};
pathLabel = database.pathLabel;

for ii = 1:nDescType
    descName = descPara.feaType{ii};
    
    for jj = 1:nPatchSize
        samGMM = [ ];
        currPatchSize = num2str(descPara.PatchSize(jj));
        
        for kk = 1:nClass    %nClass=2
            idxTrSam = find(trLabel == kk);
            idxTrPath = find(pathLabel == kk);
            tmpIdx = (ii-1) * nPatchSize + jj;
            
            for ll = 1:length(idxTrSam)  %idxTrSam=20
                [pdir, fname] = fileparts(trSam{idxTrSam(ll)});
                filePath = fullfile(database.path{idxTrPath(1)}, [fname '_' currPatchSize '_' descName '.mat']);
                load(filePath);     % load the low-level descriptor
                dataDesc = feaSet.feaArr;
                [nSam, dFea] = size(dataDesc);
                if nSam == 0
                    continue;
                end
                idxRand = randperm(nSam);    % 返回一行包含从1到nSam的整数 顺序随机
                nGMMSam = floor(nSam * fvPara.rSamGMM);
                if nGMMSam < 1
                    nGMMSam = 1;
                end
                idxGMM = idxRand(1:nGMMSam);
                dataGMM = dataDesc(idxGMM,:);                        % the raw data samples for GMM
                
                if pcaPara.flagPCA
                    dataGMM = dataGMM * pcaMatrix{tmpIdx};
                end
                samGMM = [samGMM; dataGMM];      % the data samples for GMM  samGMM 23040(2*20*576)*128
            end
        end
        
         % generate the GMM components均值128*50、协方差128*50、先验50*1
        [gmmComp{tmpIdx}.mean, gmmComp{tmpIdx}.covariances, gmmComp{tmpIdx}.priors] = vl_gmm(samGMM', fvPara.nGMM);   
    end
end

% save the GMM component
folderName = ['trainSample_' num2str(nTrainSam) '\'];
for ii = 1:length(descPara.feaType)
    folderName = [folderName descPara.feaType{ii} '_'];   %foldername=trainSample_20\lpq+_
end
for jj = 1:length(descPara.PatchSize)
    if jj ~= length(descPara.PatchSize)
        folderName = [folderName num2str(descPara.PatchSize(jj)) '_'];    %foldername=trainSample_20\lpq+_16
    else
        folderName = [folderName num2str(descPara.PatchSize(jj))];
    end
end
folderPath = fullfile(gmmPath, folderName);    %folderPath=gmm\KTH_TIPS\trainSample_20\lpq+_16
if ~isdir(folderPath)
    mkdir(folderPath);
end
filePath = fullfile(folderPath, [num2str(idxRound) '.mat']);     %filepath=gmm\KTH_TIPS\trainSample_20\lpq+_16\1.mat
save(filePath, 'gmmComp');










