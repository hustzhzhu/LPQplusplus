%----FUNCTION:
% generate the training and test samples via FV encoding
%----INPUT:
% database - the structure that contains the raw low-level descriptor database information
% samSplit - the structure that contains the sample split inforation for training or test
% idxRound - experiment round index
% descPara - the low-level descriptor extraction parameters
% pcaMatrix - PCA transfermation matrix for different descriptors
% gmmComp - the GMM components for FV
%----OUTPUT:
% trSample - the structure that contains the training samples
%                                   .feaArr - feature array
%                                   .labelArr - label array
% tsSample - the structure that contains the training samples
%                                   .feaArr - feature array
%                                   .labelArr - label array
%----AUTHOR:
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07

function [trSample, tsSample] = sample_generate(database, samSplit, idxRound, descPara, pcaMatrix, gmmComp)

nDescType = length(descPara.feaType);
dDesc = zeros(nDescType, 1);
nPatchSize = length(descPara.PatchSize);
nClass = database.classNum;
trSam = samSplit.tr_split{idxRound};    trLabel = samSplit.tr_label{idxRound};
tsSam = samSplit.ts_split{idxRound};   tsLabel = samSplit.ts_label{idxRound};
pathLabel = database.pathLabel;

% acquire the dimensionality of different descriptors
for ii = 1:nDescType
    descName = descPara.feaType{ii};
    currPatchSize = num2str(descPara.PatchSize(1));
    [pdir, fname] = fileparts(trSam{1});
    filePath = fullfile(database.path{1}, [fname '_' currPatchSize '_' descName '.mat']);
    load(filePath);     % load the low-level descriptor
    dDesc(ii) = size(feaSet.feaArr, 2);
end
dFV = sum(dDesc) * nPatchSize * 2 * size(gmmComp{1}.mean, 2);

%% Generate the training samples
disp('-----------------------------------------');
disp('Generate the training samples via FV...');
disp('-----------------------------------------');

if isempty(pcaMatrix) ~= 1 
dFV = size(pcaMatrix{1},2) * nPatchSize * 2 * size(gmmComp{1}.mean, 2);
trSample.feaArr = zeros(length(trSam), dFV);   
trSample.labelArr = zeros(length(trSam), 1);
else
trSample.feaArr = zeros(length(trSam), dFV);      
trSample.labelArr = zeros(length(trSam), 1);
end

nCount = 1;
for ii = 1:nClass
    idxTrSam = find(trLabel == ii);
    idxTrPath = find(pathLabel == ii);

    for jj = 1:length(idxTrSam)
        tmpFV = [ ];
        
        for kk = 1:nDescType
            descName = descPara.feaType{kk};
            
            for ll = 1:nPatchSize
                currPatchSize = num2str(descPara.PatchSize(ll));
                tmpIdx = (kk-1) * nPatchSize + ll;
                [pdir, fname] = fileparts(trSam{idxTrSam(jj)});
                filePath = fullfile(database.path{idxTrPath(1)}, [fname '_' currPatchSize '_' descName '.mat']);
                load(filePath);     % load the low-level descriptor
                dataDesc = feaSet.feaArr; 
                if isempty(pcaMatrix) ~= 1
                    dataDesc = dataDesc * pcaMatrix{tmpIdx};
                end
                currFV = vl_fisher(dataDesc', gmmComp{tmpIdx}.mean, gmmComp{tmpIdx}.covariances, gmmComp{tmpIdx}.priors);               
                % square-rooting normalization
                currFV = sign(currFV) .* sqrt(abs(currFV));   
                % l2 normalization
                L2Norm = sqrt(sum(power(currFV,2)));
                if L2Norm < 1e-10
                    currFV = currFV';
                else
                    currFV = (currFV / L2Norm)';
                end          
                tmpFV = [tmpFV, currFV];
            end
        end
        
        trSample.feaArr(nCount, :) = tmpFV;
        trSample.labelArr(nCount) = ii;
        nCount = nCount + 1;
        clear tmpFV;
        if ~mod(nCount, 5),
            fprintf('.');
        end
        if ~mod(nCount, 100),
            fprintf(' %d images processed\n', nCount);
        end
    end    
end
fprintf('\n');

%% Generate the test samples
disp('-----------------------------------------');
disp('Generate the test samples via FV...');
disp('-----------------------------------------');

if isempty(pcaMatrix) ~= 1 
dFV = size(pcaMatrix{1},2) * nPatchSize * 2 * size(gmmComp{1}.mean, 2);
tsSample.feaArr = zeros(length(trSam), dFV);   
tsSample.labelArr = zeros(length(trSam), 1);
else
tsSample.feaArr = zeros(length(trSam), dFV);      
tsSample.labelArr = zeros(length(trSam), 1);
end

nCount = 1;
for ii = 1:nClass
    idxtsSam = find(tsLabel == ii);
    idxtsPath = find(pathLabel == ii);

    for jj = 1:length(idxtsSam)
        tmpFV = [ ];
        
        for kk = 1:nDescType
            descName = descPara.feaType{kk};
            
            for ll = 1:nPatchSize
                currPatchSize = num2str(descPara.PatchSize(ll));
                tmpIdx = (kk-1) * nPatchSize + ll;       
                [pdir, fname] = fileparts(tsSam{idxtsSam(jj)});
                filePath = fullfile(database.path{idxtsPath(1)}, [fname '_' currPatchSize '_' descName '.mat']);
                load(filePath);     % load the low-level descriptor
                dataDesc = feaSet.feaArr;
                if isempty(pcaMatrix) ~= 1
                    dataDesc = dataDesc * pcaMatrix{tmpIdx};
                end
                currFV = vl_fisher(dataDesc', gmmComp{tmpIdx}.mean, gmmComp{tmpIdx}.covariances, gmmComp{tmpIdx}.priors);
                % square-rooting normalization
                currFV = sign(currFV) .* sqrt(abs(currFV));
                % l2 normalization
                L2Norm = sqrt(sum(power(currFV,2)));
                if L2Norm < 1e-10
                    currFV = currFV';
                else
                    currFV = (currFV / L2Norm)';
                end
                tmpFV = [tmpFV, currFV];
            end
        end
        
        tsSample.feaArr(nCount, :) = tmpFV;
        tsSample.labelArr(nCount) = ii;
        nCount = nCount + 1;
        clear tmpFV;
        if ~mod(nCount, 5),
            fprintf('.');
        end
        if ~mod(nCount, 100),
            fprintf(' %d images processed\n', nCount);
        end
    end      
end














