%----FUNCTION:
% descriptor normalization
%----INPUT:
% LPQplusplus_arr -the LPQ++ descriptor array
% model - normalization mode
%----OUTPUT:
% LPQplusplus_arr - the normalized LPQ++ descriptor array
%----AUTHOR:
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07

function [LPQplusplus_arr] = sp_normalize_LPQplusplus(LPQplusplus_arr, model)
%%
if model == 1   % l1 normlization
    LPQpluspluslen = sum(LPQplusplus_arr, 2);
    LPQplusplus_arr = LPQplusplus_arr ./ repmat(LPQpluspluslen, [1, size(LPQplusplus_arr, 2)]);
elseif model == 2   % l2 normalization
    % normalize LPQ+ descriptors
    LPQpluspluslen = sqrt(sum(LPQplusplus_arr.^2, 2));
    LPQplusplus_arr = LPQplusplus_arr ./ repmat(LPQpluspluslen, [1, size(LPQplusplus_arr, 2)]);
    % suppress the large components
    LPQplusplus_arr(LPQplusplus_arr > 0.3) = 0.3;    
    % renormolize
    LPQpluspluslen = sqrt(sum(LPQplusplus_arr.^2, 2));
    LPQplusplus_arr = LPQplusplus_arr ./ repmat(LPQpluspluslen, [1, size(LPQplusplus_arr, 2)]);
elseif model == 3   % column normalization
    f_min = min(LPQplusplus_arr);    f_max = max(LPQplusplus_arr);    f_tmp = f_max-f_min;
    r = 1./ (f_max - f_min);    r(f_tmp < 1e-10) = 1;
    LPQplusplus_arr = (LPQplusplus_arr - repmat(f_min,size(LPQplusplus_arr,1),1)).*repmat(r,size(LPQplusplus_arr,1),1);
end
