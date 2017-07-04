clear all

%% Parameters initialization
sequenceIdx = { ...
    '2015-08-12-15-04-18', '2014-07-14-14-49-50', '2014-11-28-12-07-13', ...
    '2015-02-10-11-58-05', '2015-02-13-09-16-26', '2015-05-19-14-06-38', ...
    '2015-08-13-16-02-58', '2014-12-09-13-21-02', '2014-12-12-10-45-15', ...
    '2015-10-30-13-52-14', '2015-05-22-11-14-30'}';

posDisThr = 25;
nonTrivPosDistThr = 100;

%% Parse dataset
dataset = oxfordRobotCarParser(sequenceIdx, posDisThr, nonTrivPosDistThr);

%% plot image positions
figure(1);
plotPositions2D(dataset.utm(dataset.seqIdx == 1, 1:2));
axis equal;

%% Testing set: Easting > 620105
figure(2);
plotPositions2D(dataset.utm(dataset.seqIdx == 1 & ...
    dataset.utm(:, 2) > 620105, 1:2));
axis equal;

%% Validation set: Easting < 620105 && Northing > 573600
% figure(3);
hold on;
plotPositions2D(dataset.utm(dataset.seqIdx == 1 & ...
    dataset.utm(:, 2) < 620105 ...
    & dataset.utm(:, 1) > 5735800, 1:2));
axis equal;

%% Training set: Easting < 620105 && Northing > 573600
% figure(4);
hold on;
plotPositions2D(dataset.utm(dataset.seqIdx == 1 & ...
    dataset.utm(:, 2) < 620105 & dataset.utm(:, 1) < 5735800, 1:2));
axis equal;