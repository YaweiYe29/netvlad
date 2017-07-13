close all
clear all

%% Add path
addpath(genpath('~/catkin_ws/src/netvlad'))
addpath(genpath('~/Data'))

%% Parameters initialization
sequenceIdx = { ...
    '2015-08-12-15-04-18', '2014-07-14-14-49-50', '2014-11-28-12-07-13', ...
    '2015-02-10-11-58-05', '2015-02-13-09-16-26', '2015-05-19-14-06-38', ...
    '2015-08-13-16-02-58', '2014-12-09-13-21-02', '2014-12-12-10-45-15', ...
    '2015-10-30-13-52-14', '2015-05-22-11-14-30'}';

% Changed timestamps of '2015-02-13-09-16-26', '2015-08-13-16-02-58', 
% '2014-12-12-10-45-15', '2015-05-22-11-14-30' for a fair comparision
% between NetVLAD and structure descriptor, since NetVLAD samples triplets
% from database so that they have at least one month away from each other.
sequenceTimeStamps = [ ...
    201508, 201407, 201411, 201502, 201503, 201505, ...
    201509, 201412, 201401, 201510, 201506]';

whichSet = {'train', 'val', 'test'}; % 'train', 'val', 'test'
posDisThr = 25;
nonTrivPosDistThr = 100;
dbRatio = 0.98;

eastThr = 620105;
northThr = 5735800;

%% Parse dataset
for i = 1:length(whichSet)
    dataset = oxfordRobotCarParser(sequenceIdx, sequenceTimeStamps, posDisThr, ...
        nonTrivPosDistThr, whichSet{i}, eastThr, northThr, dbRatio);
    
    % Generate database
    dbStruct.whichSet = dataset.whichSet;
    dbStruct.dbImageFns = dataset.dbImageFns;
    dbStruct.utmDb = dataset.utmDb(:, 1:2)';
    dbStruct.dbTimeStamp = dataset.dbTimeStamp;
    dbStruct.qImageFns = dataset.qImageFns;
    dbStruct.utmQ = dataset.utmQ(:, 1:2)';
    dbStruct.qTimeStamp = dataset.qTimeStamp;
    dbStruct.numImages = dataset.numImages;
    dbStruct.numQueries = dataset.numQueries;
    dbStruct.posDistThr = dataset.posDistThr;
    dbStruct.posDistSqThr = dataset.posDistSqThr;
    dbStruct.nonTrivPosDistSqThr = dataset.nonTrivPosDistSqThr;
    
    save(['~/Data/netvlad/datasets/robotCar_' dbStruct.whichSet '_dbRatio' num2str(dbRatio) '.mat'], 'dbStruct');
end
%% plots
% plot image positions
figure(1);
plotPositions2D(dataset.utm(dataset.seqNum == 1, 1:2));
axis equal;

% Testing set: Easting > eastThr
figure(2);
plotPositions2D(dataset.utm(dataset.seqNum == 1 & ...
    dataset.utm(:, 2) > eastThr, 1:2));
axis equal;

% Validation set: Easting < eastThr && Northing > 573600
% figure(3);
hold on;
plotPositions2D(dataset.utm(dataset.seqNum == 1 & ...
    dataset.utm(:, 2) < eastThr ...
    & dataset.utm(:, 1) > northThr, 1:2));
axis equal;

% Training set: Easting < eastThr && Northing > 573600
% figure(4);
hold on;
plotPositions2D(dataset.utm(dataset.seqNum == 1 & ...
    dataset.utm(:, 2) < eastThr & dataset.utm(:, 1) < northThr, 1:2));
axis equal;

%%
% Load datasets
train = load('robotCar_train.mat');
val = load('robotCar_val.mat');
test = load('robotCar_test.mat');

%% plots
figure(3)
plotPositions2D(train.dbStruct.utmDb')
hold on;
plotPositions2D(train.dbStruct.utmQ')
hold on;
plotPositions2D(val.dbStruct.utmDb')
hold on;
plotPositions2D(val.dbStruct.utmQ')
hold on;
plotPositions2D(test.dbStruct.utmDb')
hold on;
plotPositions2D(test.dbStruct.utmQ')
hold on;
axis equal;
