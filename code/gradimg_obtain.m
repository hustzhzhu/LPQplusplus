%----FUNCTION£º
% extract gradient magnitude image
%----INPUT£º
% I - the original image
% type_index - edge type (1 - Sobel; 2 - Prewitt)
%----OUTPUT:
% gradimg - gradient magnitude image
%----Author
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07

function [gradimg] = gradimg_obtain(I, type_index)

I = double(I);

if type_index == 1
    hy = fspecial('sobel');
    hx = hy';
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradimg = sqrt(Ix.^2 + Iy.^2);
elseif type_index == 2
    hy = fspecial('prewitt');
    hx = hy';
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradimg = sqrt(Ix.^2 + Iy.^2);
end