% LPQ++: A Discriminative Blur-insensitive Textural Descriptor with Spatial-channel Interaction
% Written by Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07
%% ---------------------------------------------------------------------------------------------------------------
clear; 
close all; clc;

%% Parameter setting
descPara.feaType = {'lpq++'};           % feature filter for image classification
descPara.nBins = [2];                  % SPM structure ：Spatial Pyramid Matching空间金字塔匹配模型
descPara.PatchSize = [16];             % multi-scale patch sizes for low-level feature extraction
descPara.nStride = 8;                  % stride step for dense sample feature extraction
descPara.winSize = 13;                 % local neighboring window size for STFT computation
descPara.freqestim = 1;                % STFT neighboring window mode (1 - uniform window)
descPara.nAngles = 8;                  % number of quantized local phase orientation
descPara.alpha = 9;                    % parameter for local phase orientation assignment
descPara.normModel = 2;                % normalization model (1 - l1; 2 - l2; 3 - column normalization)
descPara.maxImSize = 200;              % the maximum image size

blurPara.model = 1;                    % blurring model (0 - no blurring; 1 - Gaussian; 2 - motion; 3 - cirrular)
blurPara.gaussian.hsize = [3 3];       % Gaussian blurring parameter
blurPara.gaussian.sigma = 3;           % Gaussian blurring parameter
blurPara.motion.len = 9;               % motion blurring parameter
blurPara.motion.theta = 0;             % motion blurring parameter
blurPara.cirrular.radius = 2;          % cirrular blurring parameter

pcaPara.flagPCA = 0;                   % indicate whether PCA is executed (0 - no; 1 - yes) 
pcaPara.pca_num = [40, 40, 10];        % number of chosen eigenvectors in pca for multi-view features
pcaPara.rPCA = 0.16;                   % the ratio for feature dimensionality in PCA
pcaPara.rSamPCA = 0.5;                 % the data sampling ratio（比率） in PCA

fvPara.flagGMM = 1;                    % indicate whether GMM is generated or loaded (0 - load; 1 - generate)
fvPara.rSamGMM = 1;                    % the data sampling ratio in GMM generation
fvPara.nGMM = 50;                      % the number of Gaussian components for Fisher Vector encoding  

nRounds = 5;                                             % number of random test on the dataset
tr_num  = 20;                                            % number of training examples per category
ts_num  = 40;                                            % number of test examples per category
normFlag = 0;                                            % indicate whether execute normalization per dim besides normalization in FV (0 - no; 1 - yes)

splitGenFlag = 0;                                        % indicate whether generate sample split online or load the existing ones (0 - load; 1 - generate)
samSplit.tr_split = cell(nRounds, 1);                    % training sample index（索引） for all experiment rounds
samSplit.tr_label = cell(nRounds, 1);                    % training sample lables for all experiment rounds
samSplit.ts_split = cell(nRounds, 1);                    % test sample index for all experiment round
samSplit.ts_label = cell(nRounds, 1);                    % test sample labels for all experiment rounds

cc = power(2, 0);                                        % regularization parameter for SVM
mem_block = 3000;                                        % maxmum number of testing features loaded each time

%% Path setting
addpath('Libsvm/matlab');                   % Libsvm package

imgPath = 'image/KTH_TIPS';                 % directory of the image database                             
dataPath =  'data/KTH_TIPS/1';          % directory of the raw multi-view low-level descriptors
feaPath = 'feature/KTH_TIPS/1';         % directory of the final image features
gmmPath = 'gmm/KTH_TIPS/1';                   % directory of the GMM components
splitPath = 'sample_split/KTH_TIPS';        % directory of the sample split for train and test
resPath = 'result/KTH_TIPS/1';                % directory of the classification result
%% Delete the feature database of the previous experiment
for ii = 1:length(feaPath)
    subfolders = dir(feaPath);
    
    for jj = 1:length(subfolders)
        if (subfolders(jj).isdir && ~strcmp(subfolders(jj).name, '.') && ~strcmp(subfolders(jj).name, '..'))
            folderPath = fullfile(feaPath, ['\' subfolders(jj).name]);
            rmdir(folderPath, 's');
        end
    end
end

%% Retrieve the image dataset
imgDatabase = retr_img_database(imgPath);

%% Train and test
for ii = 1:nRounds
    samSplit.tr_split{ii} = { };     samSplit.ts_split{ii} = { };
    samSplit.tr_label{ii} = [ ];    samSplit.ts_label{ii} = [ ];
end
clabel = unique(imgDatabase.imgLabel);
nclass = imgDatabase.classNum;
accuracy = zeros(nRounds, 1);
predLabel = cell(nRounds, 1);
gndLabel = cell(nRounds, 1);

for ii = 1:nRounds
    fprintf('\n Testing round %d \n', ii);
    tr_idx = [ ];   ts_idx = [ ];
    pcaMatrix = { };
    
    if splitGenFlag
        % generate the sample split for train and test
        for jj = 1:nclass
            idx_label = find(imgDatabase.imgLabel == clabel(jj));
            num = length(idx_label);
            
            idx_rand = randperm(num);
            
            tr_idx = [tr_idx; idx_label(idx_rand(1:tr_num))];
            ts_idx = [ts_idx; idx_label(idx_rand(tr_num+1:tr_num+ts_num))];
            
            samSplit.tr_label{ii} = [samSplit.tr_label{ii}; repmat(jj, [tr_num, 1])];
            samSplit.ts_label{ii} = [samSplit.ts_label{ii}; repmat(jj, [ts_num, 1])];
        end
        samSplit.tr_split{ii} = [samSplit.tr_split{ii}, imgDatabase.imgName{tr_idx}]';
        samSplit.ts_split{ii} = [samSplit.ts_split{ii}, imgDatabase.imgName{ts_idx}]';
    else
        splitName = ['trainSample_' num2str(tr_num) '.mat'];
        splitFilePath = fullfile(splitPath, splitName);
        load(splitFilePath);
    end
    
    % Clean the low-level descriptor database of the previous experiment
    for jj = 1:length(dataPath)
        subfolders = dir(dataPath); 
        
        for kk = 1:length(subfolders)
            if (subfolders(kk).isdir && ~strcmp(subfolders(kk).name, '.') && ~strcmp(subfolders(kk).name, '..'))
                folderPath = fullfile(dataPath, ['\' subfolders(kk).name]);
                rmdir(folderPath, 's');
            end
        end
    end
    
    % extract the low-level descriptor
    extr_lowLevl_denseDesc(imgDatabase, blurPara, descPara, samSplit, ii, dataPath);
    
    % Retrieve the raw low-level descriptor dataset
    database = retr_database(dataPath);
    
    if pcaPara.flagPCA      % generate the PCA transfer matrix
        [pcaMatrix] = pca_transMatrix(database, samSplit, ii, descPara, pcaPara);
    end
    
    % acquire the GMM components for FV   (mean,covariances,prior)
    [gmmComp] = gmm_acquistion(database, tr_num, gmmPath, samSplit, ii, descPara, pcaPara, pcaMatrix, fvPara);
    
    % generate the training and testing samples via FV
    [trSample, tsSample] = sample_generate(database, samSplit, ii, descPara, pcaMatrix, gmmComp);
    
    if normFlag    % feature normalization on the training samples
        f_min = min(trSample.feaArr);    f_max = max(trSample.feaArr);    f_tmp = f_max-f_min;
        r = 1./ (f_max - f_min);    r(f_tmp < 1e-10) = 1;
        trSample.feaArr = (trSample.feaArr - repmat(f_min,size(trSample.feaArr,1),1)).*repmat(r,size(trSample.feaArr,1),1);
    end
    
    % train SVM
    c_chosen = 1;
    options = [ '-s 0 -t 0 ' '-g ' num2str(power(2, -7)) ' -c ' num2str(cc(c_chosen)) ' -b 1'];      % Libsvm parameter setting (linear SVM is used)
    model = svmtrain(double(trSample.labelArr), sparse(trSample.feaArr), options);                                  % svm train
    clear trSample;
    
    if normFlag     % feature normalization on the test samples
        tsSample.feaArr = (tsSample.feaArr - repmat(f_min,size(tsSample.feaArr,1),1)).*repmat(r,size(tsSample.feaArr,1),1);
    end
    
    % Prediction
    [C, Acc, d2p] = svmpredict(double(tsSample.labelArr), sparse(tsSample.feaArr), model);
    
    % normalize the classification accuracy by averaging over different classes
    acc = zeros(nclass, 1);
    
    for jj = 1 : nclass,
        c = clabel(jj);
        idx = find(tsSample.labelArr == c);
        curr_pred_label = C(idx);
        curr_gnd_label = tsSample.labelArr(idx);
        acc(jj) = length(find(curr_pred_label == curr_gnd_label))/length(idx);
    end
    
    predLabel{ii} = C;
    gndLabel{ii} = tsSample.labelArr;
    accuracy(ii) = mean(acc);  
end

Ravg = mean(accuracy);                  % average recognition rate
Rstd = std(accuracy);                   % standard deviation of the recognition rate
fprintf('Average accuracy: %.2f, Standard deviation: %.2f \n', Ravg*100, Rstd*100);

% save the sample split
if ~isdir(splitPath)
    mkdir(splitPath);
end
splitName = ['trainSample_' num2str(tr_num) '.mat'];
splitFilePath = fullfile(splitPath, splitName);
save(splitFilePath, 'samSplit');

% save the classification result
folderName = ['trainSample_' num2str(tr_num) '\'];
folderPath = fullfile(resPath, folderName);
if ~isdir(folderPath)
    mkdir(folderPath);
end
fileName = [ ];
for ii = 1:length(descPara.feaType)
    fileName = [fileName descPara.feaType{ii} '_'];
end
for jj = 1:length(descPara.PatchSize)
    if jj ~= length(descPara.PatchSize)
        fileName = [fileName num2str(descPara.PatchSize(jj)) '_'];
    else
        fileName = [fileName num2str(descPara.PatchSize(jj))];
    end
end
filePath = fullfile(folderPath, [fileName '.mat']);
save(filePath, 'accuracy', 'predLabel', 'gndLabel', 'database');
        
