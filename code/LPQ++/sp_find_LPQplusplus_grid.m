%----FUNCTION:
% extract the normalized dense sample LPQ++ 
%----INPUT:
% I - the input image
% grid_x, grid_y - the input mesh
% patch_size - the patch size of sub-window
% descPara - the low-level descriptor extraction parameters
%----OUTPUT:
% LPQplusplus_arr - the LPQ++ descriptor array
%----AUTHOR:
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07


function LPQplusplus_arr = sp_find_LPQplusplus_grid(I, grid_x, grid_y, patch_size, descPara)
%% parameters
num_angles = descPara.nAngles;
num_bins = descPara.nBins;  
normModel = descPara.normModel;
alpha = descPara.alpha;
num_samples = num_bins.^2;

%% calculate the local phase quantized orientation(����)
lpOrientArr = lpOrient(I,descPara);    %LPQ++: channel interaction and spatial interaction
%% extract the dense sample LPQ++
[hgt wid] = size(I);
num_patches = numel(grid_x);

dim_lookup = zeros(1,length(num_bins));    
for ii = 1:length(num_bins)
    dim_lookup(ii) = sum(length(lpOrientArr) * num_angles * num_samples(1:ii));
end

% make default grid of samples (centered at zero, width 2)
interval = cell(1,length(num_bins)); 
for ii = 1:length(num_bins)
    interval{ii} = 2/num_bins(ii):2/num_bins(ii):2;
    interval{ii} = interval{ii} - (1/num_bins(ii) + 1);
end

sample_x = cell(1,length(num_bins));
sample_y = cell(1,length(num_bins));
for ii = 1:length(num_bins)
    [sample_x{ii} sample_y{ii}] = meshgrid(interval{ii}, interval{ii});
    sample_x{ii} = reshape(sample_x{ii}, [1 num_samples(ii)]);
    sample_y{ii} = reshape(sample_y{ii}, [1 num_samples(ii)]);  
end

LPQplusplus_arr = zeros(num_patches, length(lpOrientArr)*sum(num_samples)*num_angles);

% for all patches
for ii=1:num_patches
    r = patch_size/2;
    cx = grid_x(ii) + r - 0.5;
    cy = grid_y(ii) + r - 0.5;
    
    for jj = 1:length(num_bins)
        % find coordinates of sample points (bin centers)
        sample_x_t = sample_x{jj} * r + cx;
        sample_y_t = sample_y{jj} * r + cy;
        if length(sample_y_t) == 1
            sample_res = patch_size;
        else
            sample_res = sample_y_t(2) - sample_y_t(1);
        end
        
        % find window of pixels that contributes to this descriptor
        x_lo = grid_x(ii);
        x_hi = grid_x(ii) + patch_size - 1;
        y_lo = grid_y(ii);
        y_hi = grid_y(ii) + patch_size - 1;
        
        % find coordinates of pixels
        [sample_px, sample_py] = meshgrid(x_lo:x_hi,y_lo:y_hi); 
        num_pix = numel(sample_px); 
        sample_px = reshape(sample_px, [num_pix 1]);
        sample_py = reshape(sample_py, [num_pix 1]);
        
        % find (horiz, vert) distance between each pixel and each grid sample
        dist_px = abs(repmat(sample_px, [1 num_samples(jj)]) - repmat(sample_x_t, [num_pix 1]));
        dist_py = abs(repmat(sample_py, [1 num_samples(jj)]) - repmat(sample_y_t, [num_pix 1]));
        
        % find weight of contribution of each pixel to each bin
        weights_x = dist_px/sample_res;
        weights_x = (1 - weights_x) .* (weights_x <= 1);
        weights_y = dist_py/sample_res;
        weights_y = (1 - weights_y) .* (weights_y <= 1);
        weights = weights_x .* weights_y; 
        
        % extract LPQ++
        curr_LPQplusplus = zeros(1, length(lpOrientArr) * num_angles * num_samples(jj)); 
        tmp_LPQplusplus = zeros(num_angles, num_samples(jj));
        for kk = 1:length(lpOrientArr)
            for ll = 1:num_angles
                tmp = reshape(lpOrientArr{kk}(y_lo:y_hi,x_lo:x_hi,ll),[num_pix 1]);
                tmp = repmat(tmp, [1 num_samples(jj)]);
                tmp_LPQplusplus(ll, :) = sum(tmp .* weights); 
            end
            
            curr_LPQplusplus((kk-1) * num_angles * num_samples(jj)+1 : kk * num_angles * num_samples(jj)) = ...
                reshape(tmp_LPQplusplus, [1 num_angles * num_samples(jj)]);
        end
        
        if jj == 1;
            LPQplusplus_arr(ii, 1:dim_lookup(jj)) = curr_LPQplusplus; 
        else
            LPQplusplus_arr(ii, dim_lookup(jj-1)+1:dim_lookup(jj)) = curr_LPQplusplus;
        end
        
    end
end

%% normalize the extracted LPQ++
tmpIdx = 1;
for ii = 1:length(num_bins)    
    for jj = 1:length(lpOrientArr)
        LPQplusplus_arr(:,tmpIdx:tmpIdx+num_angles*num_samples(ii)-1) = ...
            sp_normalize_LPQplusplus(LPQplusplus_arr(:,tmpIdx:tmpIdx+num_angles*num_samples(ii)-1), normModel) / power(max(num_bins)/num_bins(ii), 1.5);
        
        tmpIdx = tmpIdx + num_angles * num_samples(ii);
    end    
end
