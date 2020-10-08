%----FUNCTION:
% execute image blurring on the image
%----INPUT:
% I - the original image
% blurPara - image blurring parameters
%----OUTPUT:
% I_blur - the blurred image
%----AUTHOR:
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07

function [I_blur] = img_blurring(I, blurPara)

% generate the PSF  fspecial
if blurPara.model == 1  % Gaussian blurring
    psf = fspecial('gaussian', blurPara.gaussian.hsize, blurPara.gaussian.sigma); 
elseif blurPara.model == 2  % motion blurring
    psf = fspecial('motion', blurPara.motion.len, blurPara.motion.theta); 
elseif blurPara.model == 3  % circular blurring
    psf = fspecial('disk', blurPara.cirrular.radius);
end

% impose blurring
I_blur = imfilter(I, psf, 'circular');
