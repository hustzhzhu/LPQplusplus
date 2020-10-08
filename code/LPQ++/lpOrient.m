%----FUNCTION:
% compute the local phase quantized orientation
%----INPUT:
% img - the input image
% descPara - parameters for LPQ+ extraction
%----OUTPUT:
% lpOrientArr - the 2D local phase quantized orientation arrays
%----AUTHOR:
% Zihao Zhu @ SCHOOL OF ARTIFICIAL INTELLIGENCE AND AUTOMATION, HUST (zihaozhu@hust.edu.cn)
% Created on 2020.10.07
% Last modified on 2020.10.07

function [lpOrientArr] = lpOrient(img, descPara)

winSize = descPara.winSize;
freqestim = descPara.freqestim;
nAngles = descPara.nAngles;
alpha = descPara.alpha;
STFTalpha=1/winSize;  % alpha in STFT approaches (for Gaussian derivative alpha=1) 
convMode = 'same';
sigma_edge=0.9;

%% initialize
img = double(img); % Convert image to double
r = (winSize-1)/2; % Get radius from window size
x = -r:r; % Form spatial coordinates in window

%% Form 1-D filters
if freqestim == 1 % STFT uniform window
    % Basic STFT filters
    w0 = (x*0+1);
    w1 = exp(complex(0,-2*pi*x*STFTalpha)); 
    w2 = conj(w1); 
end

%% Run filters to compute the frequency response in the four points. Store local phase orientation separately
% Run first filter
filterResp=conv2(conv2(img,w0.',convMode),w1,convMode); 

% Initilize local phase orientation array
xlpTheta = cell(1,4);
ylpTheta = cell(1,4);
lpTheta_real = cell(1,4);
lpTheta_imag = cell(1,4);
lp_mag = cell(1,4);
I_C = cell(1,8);
I_X = cell(1,8);
I_Y = cell(1,8);
I_theta = cell(1,24);


for ii = 1:length(xlpTheta)
    xlpTheta{ii} = zeros(size(filterResp,1),size(filterResp,2)); 
    ylpTheta{ii} = zeros(size(filterResp,1),size(filterResp,2));           
end

% Store local phase orientation
lpTheta_real{1} = real(filterResp);
lpTheta_imag{1} = imag(filterResp);
lp_mag{1} = (lpTheta_real{1}.^2 + lpTheta_imag{1}.^2).^0.5;
lpTheta_real{1} = real(filterResp)./lp_mag{1};
lpTheta_imag{1} = imag(filterResp)./lp_mag{1};


[G_X,G_Y]=gen_dgauss(sigma_edge);
I_X{1} = filter2(G_X, lpTheta_real{1}, 'same');
I_Y{1} = filter2(G_Y, lpTheta_real{1}, 'same'); 
I_X{2} = filter2(G_X, lpTheta_imag{1}, 'same'); 
I_Y{2} = filter2(G_Y, lpTheta_imag{1}, 'same'); 


% Repeat the procedure for other frequencies
filterResp=conv2(conv2(img,w1.',convMode),w0,convMode);

lpTheta_real{2} = real(filterResp);
lpTheta_imag{2} = imag(filterResp);
lp_mag{2} = (lpTheta_real{2}.^2 + lpTheta_imag{2}.^2).^0.5;

lpTheta_real{2} = real(filterResp)./lp_mag{2};
lpTheta_imag{2} = imag(filterResp)./lp_mag{2};

I_X{3} = filter2(G_X, lpTheta_real{2}, 'same'); 
I_Y{3} = filter2(G_Y, lpTheta_real{2}, 'same'); 
I_X{4} = filter2(G_X, lpTheta_imag{2}, 'same'); 
I_Y{4} = filter2(G_Y, lpTheta_imag{2}, 'same'); 


% Repeat the procedure for other frequencies
filterResp=conv2(conv2(img,w1.',convMode),w1,convMode);

lpTheta_real{3} = real(filterResp);
lpTheta_imag{3} = imag(filterResp);
lp_mag{3} = (lpTheta_real{3}.^2 + lpTheta_imag{3}.^2).^0.5;
lpTheta_real{3} = real(filterResp)./lp_mag{3};
lpTheta_imag{3} = imag(filterResp)./lp_mag{3};


I_X{5} = filter2(G_X, lpTheta_real{3}, 'same'); 
I_Y{5} = filter2(G_Y, lpTheta_real{3}, 'same'); 
I_X{6} = filter2(G_X, lpTheta_imag{3}, 'same');
I_Y{6} = filter2(G_Y, lpTheta_imag{3}, 'same');


% Repeat the procedure for other frequencies
filterResp=conv2(conv2(img,w1.',convMode),w2,convMode);

lpTheta_real{4} = real(filterResp);
lpTheta_imag{4} = imag(filterResp);
lp_mag{4} = (lpTheta_real{4}.^2 + lpTheta_imag{4}.^2).^0.5;
lpTheta_real{4} = real(filterResp)./lp_mag{4};
lpTheta_imag{4} = imag(filterResp)./lp_mag{4};


I_X{7} = filter2(G_X, lpTheta_real{4}, 'same');
I_Y{7} = filter2(G_Y, lpTheta_real{4}, 'same'); 
I_X{8} = filter2(G_X, lpTheta_imag{4}, 'same'); 
I_Y{8} = filter2(G_Y, lpTheta_imag{4}, 'same'); 

I_C{1}=((lpTheta_real{1}-lpTheta_real{2})+(lpTheta_real{1}-lpTheta_real{3})+(lpTheta_real{1}-lpTheta_real{4}))./3;
I_C{2}=((lpTheta_real{2}-lpTheta_real{1})+(lpTheta_real{2}-lpTheta_real{3})+(lpTheta_real{2}-lpTheta_real{4}))./3;
I_C{3}=((lpTheta_real{3}-lpTheta_real{1})+(lpTheta_real{3}-lpTheta_real{2})+(lpTheta_real{3}-lpTheta_real{4}))./3;
I_C{4}=((lpTheta_real{4}-lpTheta_real{1})+(lpTheta_real{4}-lpTheta_real{2})+(lpTheta_real{4}-lpTheta_real{3}))./3;
I_C{5}=((lpTheta_imag{1}-lpTheta_imag{2})+(lpTheta_imag{1}-lpTheta_imag{3})+(lpTheta_imag{1}-lpTheta_imag{4}))./3;
I_C{6}=((lpTheta_imag{2}-lpTheta_imag{1})+(lpTheta_imag{2}-lpTheta_imag{3})+(lpTheta_imag{2}-lpTheta_imag{4}))./3;
I_C{7}=((lpTheta_imag{3}-lpTheta_imag{1})+(lpTheta_imag{3}-lpTheta_imag{2})+(lpTheta_imag{3}-lpTheta_imag{4}))./3;
I_C{8}=((lpTheta_imag{4}-lpTheta_imag{1})+(lpTheta_imag{4}-lpTheta_imag{2})+(lpTheta_imag{4}-lpTheta_imag{3}))./3;

I_theta{1}=atan2(I_Y{1},I_X{1});
I_theta{1}(isnan(I_theta{1})) = 0;
I_theta{2}=atan2(I_Y{2},I_X{2});
I_theta{2}(isnan(I_theta{2})) = 0;
I_theta{3}=atan2(I_Y{3},I_X{3});
I_theta{3}(isnan(I_theta{3})) = 0;
I_theta{4}=atan2(I_Y{4},I_X{4});
I_theta{4}(isnan(I_theta{4})) = 0;
I_theta{5}=atan2(I_Y{5},I_X{5});
I_theta{5}(isnan(I_theta{5})) = 0;
I_theta{6}=atan2(I_Y{6},I_X{6});
I_theta{6}(isnan(I_theta{6})) = 0;
I_theta{7}=atan2(I_Y{7},I_X{7});
I_theta{7}(isnan(I_theta{7})) = 0;
I_theta{8}=atan2(I_Y{8},I_X{8});
I_theta{8}(isnan(I_theta{8})) = 0;
I_theta{9}=atan2(I_Y{1},I_C{1});
I_theta{9}(isnan(I_theta{9})) = 0;
I_theta{10}=atan2(I_Y{2},I_C{2});
I_theta{10}(isnan(I_theta{10})) = 0;
I_theta{11}=atan2(I_Y{3},I_C{3});
I_theta{11}(isnan(I_theta{11})) = 0;
I_theta{12}=atan2(I_Y{4},I_C{4});
I_theta{12}(isnan(I_theta{12})) = 0;
I_theta{13}=atan2(I_Y{5},I_C{5});
I_theta{13}(isnan(I_theta{13})) = 0;
I_theta{14}=atan2(I_Y{6},I_C{6});
I_theta{14}(isnan(I_theta{14})) = 0;
I_theta{15}=atan2(I_Y{7},I_C{7});
I_theta{15}(isnan(I_theta{15})) = 0;
I_theta{16}=atan2(I_Y{8},I_C{8});
I_theta{16}(isnan(I_theta{16})) = 0;
I_theta{17}=atan2(I_X{1},I_C{1});
I_theta{17}(isnan(I_theta{17})) = 0;
I_theta{18}=atan2(I_X{2},I_C{2});
I_theta{18}(isnan(I_theta{18})) = 0;
I_theta{19}=atan2(I_X{3},I_C{3});
I_theta{19}(isnan(I_theta{19})) = 0;
I_theta{20}=atan2(I_X{4},I_C{4});
I_theta{20}(isnan(I_theta{20})) = 0;
I_theta{21}=atan2(I_X{5},I_C{5});
I_theta{21}(isnan(I_theta{21})) = 0;
I_theta{22}=atan2(I_X{6},I_C{6});
I_theta{22}(isnan(I_theta{22})) = 0;
I_theta{23}=atan2(I_X{7},I_C{7});
I_theta{23}(isnan(I_theta{23})) = 0;
I_theta{24}=atan2(I_X{8},I_C{8});
I_theta{24}(isnan(I_theta{24})) = 0;

%% Calculate the quantized local phase orientation
angle_step = 2 * pi / nAngles;
angles = 0:angle_step:2*pi;
angles(nAngles+1) = []; % bin centers

% Initialize and store the quantized local phase orientation array 
lpOrientArr = cell(1,length(I_theta));
for ii = 1:length(lpOrientArr)
    lpOrientArr{ii} = zeros(size(filterResp,1),size(filterResp,2), nAngles);
    
    for jj = 1:nAngles
        tmp = cos(I_theta{ii} - angles(jj)).^alpha;
         lpOrientArr{ii}(:,:,jj) = tmp;
    end
end

