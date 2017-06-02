clear;
close all;
clc;


datasets = {'tsukuba', 'venus', 'teddy', 'cones'};
factors = [16,8,4,4];
d = 4;
dataset = datasets{d};
[L, R, GT, ALL, DISC, NONOCC, mindisp, maxdisp] = load_middlebury(dataset);
figure; imshow(L); title('Left Image')

%%
r1 = 2;  
cost_thr=10;
layers1=11;
sigma1=17; 
sigma1b=5; 
offset=6;

if offset > 0
    L = mirror_image(L, offset);
    R = mirror_image(R, offset);
end

[CostL, CostR] = compute_cost(L, R, maxdisp, mindisp, cost_thr);
[h w displayers] = size(CostL);
if r1 > 0
    CostL = fast_average(CostL, r1);
end

tic
[CostLa] = cross_wavelet(single(CostL), single(L), layers1, sigma1, sigma1b);
toc
%
[DispL, ConfL] = wta_simple(single(CostLa), mindisp);

%
if offset > 0
    DispL = DispL(offset+1:end-offset, offset+1:end-offset, :);
end
%clear CostLa;
clear mex

DL = uint8(round(DispL*factors(d)));
DLx = single(DL)/factors(d);
BAD = abs(GT-DLx) > 1;        
BAD_nonocc = 0.01*round(10000*sum(BAD(:).*NONOCC(:))/sum(NONOCC(:)));
BAD_all = 0.01*round(10000*sum(BAD(:).*ALL(:))/sum(ALL(:)));
BAD_disc = 0.1*round(1000*sum(BAD(:).*DISC(:))/sum(DISC(:)));
        
figure; imshow(DispL, [mindisp maxdisp]); title([dataset, ':   nonocc:', num2str(BAD_nonocc), '; all:', num2str(BAD_all), '; disc:', num2str(BAD_disc)]);

%%
[CostRa] = cross_wavelet(single(CostR), single(R), layers, sigma);
[DispR, ~] = wta_simple(single(CostRa), mindisp);
clear CostRa;
[OcclL, ~] = ltr_check(DispL, DispR, 1);
DispLa = DispL;
OcclL(ConfL<0.1) = 0;
ConfL = ConfL.*single(OcclL);
DispLa(~OcclL) = nan;

% Disparity Refinement
layers = 12;
sigma = 1;

Cost = zeros([h w displayers], 'single');
for d=1:displayers
    disp = d + mindisp;
    Cost(:,:,d) = min(2.5, (DispL-disp).^2);
end
Cost = Cost.*repmat(single(ConfL), [1 1 displayers]);
[CostLa] = cross_wavelet(single(Cost), single(L), layers, sigma);
[DispL2, ~] = wta_simple(single(CostLa), mindisp);
figure; imshow(DispL2, [mindisp maxdisp]); title('Final Disparity Estimate');
BAD = abs(int32(GT)-int32(DispL2)) > 1;
BAD = 100 * sum(BAD(:))/numel(BAD);
figure; imshow(abs(int32(GT)-int32(DispL2)) <= 1, []); title(['Final Error = ', num2str(BAD)]);

