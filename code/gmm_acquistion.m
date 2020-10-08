%----FUNCTION:
% acquire the GMM components for the different descriptors
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

function [gmmComp] = gmm_acquistion(database, nTrainSam, gmmPath, samSplit, idxRound, descPara, pcaPara, pcaMatrix, fvPara)

if fvPara.flagGMM       % generate GMM   
    [gmmComp] = gmm_generate(database, nTrainSam, gmmPath, samSplit, idxRound, descPara, pcaPara, pcaMatrix, fvPara);
else    % load GMM
    folderName = ['trainSample_' num2str(nTrainSam) '\'];
    for ii = 1:length(descPara.feaType)
        folderName = [folderName descPara.feaType{ii} '_'];
    end
    for jj = 1:length(descPara.PatchSize)
        if jj ~= length(descPara.PatchSize)
            folderName = [folderName num2str(descPara.PatchSize(jj)) '_'];
        else
            folderName = [folderName num2str(descPara.PatchSize(jj))];
        end
    end
    folderPath = fullfile(gmmPath, folderName);
    filePath = fullfile(folderPath, [num2str(idxRound) '.mat']);
    load(filePath);
end





