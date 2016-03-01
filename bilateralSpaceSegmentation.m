% Bilateral Space Video Segmentation
% CVPR 2016
% Nicolas Maerki, Oliver Wang, Federico Perazzi, Alexander Sorkine-Hornung
% 
% This is a personal reimplementation of the method described in the above paper.
% The code is released for research purposes only. If you use this software you must
% cite the above paper!
%
% Read the README.txt before proceeding. 
%
% This is a simplified, unoptimized version of our paper. It only performs
% one task, which is to propagate a mask over a video. 

%%
function segmentation = bilateralSpaceSegmentation(vid,mask,maskFrames,gridSize,dimensionWeights,unaryWeight,pairwiseWeight)
[h,w,~,f] = size(vid);


%% Lifting (3.1)
bilateralData = lift(vid,gridSize);
bilateralMask = lift(vid(:,:,:,maskFrames),gridSize,maskFrames);
maskValues = cat(2,mask(:)~=0.,mask(:)==0);
[nPoints,~] = size(bilateralData);

%% Splatting (3.2)
tic;
splattedMask = nlinearSplat2(bilateralMask, maskValues, gridSize);
splattedData = nlinearSplat2(bilateralData, ones(size(nPoints,1)), gridSize);

occupiedVertices = find(splattedData);
splattedData = splattedData(occupiedVertices);
%clear bilateralData;
%clear bilateralMask;
%% Graph Cut (3.3)
labels = graphcut(occupiedVertices, splattedData, splattedMask, gridSize, dimensionWeights, unaryWeight, pairwiseWeight);

%% Splicing (3.4)
sliced = slice2(labels,bilateralData,gridSize);

%% reshape output
segmentation = reshape(sliced,[h,w,f]);

toc;

%% second
tic;
[occupiedVertices, splattedData, vidWeights, vidIndices, splattedMask] = splat(bilateralData,bilateralMask,maskValues,gridSize);
labels = graphcut(occupiedVertices, splattedData, splattedMask, gridSize, dimensionWeights, unaryWeight, pairwiseWeight);
sliced = slice(labels,vidIndices,vidWeights);
segmentation2 = reshape(sliced,[h,w,f]);
toc;

disp('done');