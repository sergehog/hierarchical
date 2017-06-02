function  [L, R, GT, ALL, DISC, NONOCC, mindisp, maxdisp] = load_middlebury(dataset)

path2data = 'C:\Work\stereo\middlebury\';

L = imread([path2data,dataset,'\imL.png']);
R = imread([path2data,dataset,'\imR.png']);   
GT = single(imread([path2data,dataset,'\disp.pgm'])); 
ALL = imread([path2data,dataset,'\all.png']);
DISC = imread([path2data,dataset,'\disc.png']);
NONOCC = imread([path2data,dataset,'\nonocc.png']);
ALL = (ALL==max(ALL(:)));
DISC = (DISC==max(DISC(:)));
NONOCC = (NONOCC==max(NONOCC(:)));


if strcmp(dataset, 'cones') == 1
    GT = GT/4; 
    mindisp = 0;
    maxdisp = 59;
elseif strcmp(dataset, 'teddy') == 1   
    GT = GT/4;    
    mindisp = 0;
    maxdisp = 59;
elseif strcmp(dataset, 'venus') == 1
    GT = GT/8;
    mindisp = 0;
    maxdisp = 19;    
elseif strcmp(dataset, 'tsukuba') == 1 
    GT = GT/16; 
    mindisp = 0;
    maxdisp = 15;
else
    error(['Wrong dataset: "',dataset,'" !']);
end