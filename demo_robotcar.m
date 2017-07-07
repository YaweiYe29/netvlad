clear all
close all

%% ---------- Full train and test example: RobotCar
% Set the MATLAB paths
setup;

% Train: RobotCar, Test: RobotCar

% Set up the train/val datasets
dbTrain= dbOxfordRobotCar('train');
dbVal= dbOxfordRobotCar('val');
lr= 0.0001;

% --- Train the VGG-16 network + NetVLAD, tuning down to conv5_1
sessionID= trainWeakly(dbTrain, dbVal, ...
    'netID', 'vd16', 'layerName', 'conv5_3', 'backPropToLayer', 'conv5_1', ...
    'method', 'vlad_preL2_intra', 'learningRate', lr, ...
    'doDraw', true);

% Get the best network
% This can be done even if training is not finished, it will find the best
% network so far
[~, bestNet]= pickBestNet(sessionID);

% Either use the above network as the image representation extractor
% (do: finalNet= bestNet), or do whitening (recommended):
finalNet= addPCA(bestNet, dbTrain, 'doWhite', true, 'pcaDim', 4096);

% --- Test

% Set up the test dataset
% dbTest= dbTokyo247();
dbTest= dbOxfordRobotCar('test');

% Set the output filenames for the database/query image representations
paths= localPaths();
dbFeatFn= sprintf('%s%s_ep%06d_%s_db.bin', paths.outPrefix, ...
    finalNet.meta.sessionID, finalNet.meta.epoch, dbTest.name);
qFeatFn = sprintf('%s%s_ep%06d_%s_q.bin', paths.outPrefix, ...
    finalNet.meta.sessionID, finalNet.meta.epoch, dbTest.name);

% Compute db/query image representations
% adjust batchSize depending on your GPU / network size
serialAllFeats(finalNet, dbTest.dbPath, dbTest.dbImageFns, dbFeatFn, ...
    'batchSize', 30);
serialAllFeats(finalNet, dbTest.qPath, dbTest.qImageFns, qFeatFn, ...
    'batchSize', 30);

% Measure recall@N
[recall, ~, ~, opts]= testFromFn(dbTest, dbFeatFn, qFeatFn);
plot(opts.recallNs, recall, 'ro-'); grid on; xlabel('N'); ylabel('Recall@N');

% --- Test smaller dimensionalities:

% All that needs to be done (only valid for NetVLAD+whitening networks!)
% to reduce the dimensionality of the NetVLAD representation below 4096 to D
% is to keep the first D dimensions and L2-normalize.
% This is done automatically in `testFromFn` using the `cropToDim` option:

cropToDims= [64, 128, 256, 512, 1024, 2048, 4096];
recalls= [];
plotN= 5;
figure;

for iCropToDim= 1:length(cropToDims)
    cropToDim= cropToDims(iCropToDim);
    relja_display('D= %d', cropToDim);
    [recall, ~, ~, opts]= testFromFn(dbTest, dbFeatFn, qFeatFn, [], ...
        'cropToDim', cropToDim);
    
    whichRecall= find(opts.recallNs==plotN);
    recalls= [recalls, recall(whichRecall)];
    hold off;
    semilogx( cropToDims(1:iCropToDim), recalls, 'bo-');
    set(gca, 'XTick', cropToDims(1:iCropToDim));
    xlabel('Number of dimensions'); ylabel(sprintf('Recall@%d', plotN));
    grid on;
    drawnow;
end

