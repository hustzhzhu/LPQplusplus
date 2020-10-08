%----FUNCTION:
% generate gaussian templates in X and Y direction
%----INPUT:
% sigma - the standard deviation of gauusian
%----OUTPUT:
% GX - the gaussian template in X direction
% GY - the gaussian template in Y direction
%----AUTHOR:
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07
function [GX GY]=gen_dgauss(sigma)

if all(size(sigma)==[1, 1])
    % isotropic gaussian
	f_wid = 4 * ceil(sigma) + 1;
    G = fspecial('gaussian', f_wid, sigma);
else
    % anisotropic gaussian
    f_wid_x = 2 * ceil(sigma(1)) + 1;
    f_wid_y = 2 * ceil(sigma(2)) + 1;
    G_x = normpdf(-f_wid_x:f_wid_x,0,sigma(1));
    G_y = normpdf(-f_wid_y:f_wid_y,0,sigma(2));
    G = G_y' * G_x;
end


[GX,GY] = gradient(G);

GX = GX * 2 ./ sum(sum(abs(GX)));
GY = GY * 2 ./ sum(sum(abs(GY)));
