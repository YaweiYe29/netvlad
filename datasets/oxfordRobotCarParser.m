classdef oxfordRobotCarParser < handle
    
    properties
        imageFns;
        imageUnixTimeStamp;
        utm;
        imageTimeStamp;
        
        dbImageFns;
        numImages;
        utmDb;
        dbTimeStamp;
        
        qImageFns;
        numQueries;
        utmQ;
        qTimeStamp;
        
        dbRatio;
        eastThr;
        northThr;
        nonTrivPosDistSqThr;
        posDistThr;
        posDistSqThr;
        seqNum;
        sequenceIdx;
        whichSet;
    end
    
    methods
        function obj= oxfordRobotCarParser(sequenceIdx, sequenceTimeStamps, ...
                posDistThr, nonTrivPosDistSqThr, whichSet, eastThr, northThr, dbRatio)
            
            % whichSet is one of: train, val, test
            assert( ismember(whichSet, {'train', 'val', 'test'}) );
            obj.whichSet = whichSet;
            
            obj.dbRatio = dbRatio;
            obj.posDistThr= posDistThr;
            obj.posDistSqThr = posDistThr^2;
            obj.nonTrivPosDistSqThr= nonTrivPosDistSqThr;
            
            obj.eastThr = eastThr;
            obj.northThr = northThr;
            
            paths= localPaths();
            datasetRoot= paths.dsetRootRobotCar;
            
            datasetPathList = cell(size(sequenceIdx));
            for i = 1:length(sequenceIdx)
                datasetPathList{i} = {[datasetRoot sequenceIdx{i} ...
                    '/stereo/centre/undistort_images_crop/']};
            end
            
            imageFnsAllSeq = [];
            seqNum = [];
            imageTimeStampsSingleSeq = [];
            imageTimeStampsAllSeq = [];

            parfor j = 1:length(datasetPathList)
                imageSingleSeq = dir(char(fullfile(datasetPathList{j},'*.jpg')));
                
                imageFoldersSingleSeq = char(imageSingleSeq.folder);
                imageNamesSingleSeq = char(imageSingleSeq.name);
                imageFnsSingleSeq = cellstr(strcat(string(...
                    imageFoldersSingleSeq(:,44:end)), ...
                    '/', string(imageNamesSingleSeq)));
                imageFnsAllSeq = [imageFnsAllSeq; imageFnsSingleSeq];
                
                imageTimeStampsSingleSeq = repmat(sequenceTimeStamps(j), ...
                    [1, length(imageFnsSingleSeq)]);
                imageTimeStampsAllSeq = [imageTimeStampsAllSeq ...
                    imageTimeStampsSingleSeq];
                
                seqNum = [seqNum; j*ones(length(imageFnsSingleSeq), 1)];
            end
            
            obj.imageFns = imageFnsAllSeq;
            obj.imageTimeStamp = imageTimeStampsAllSeq;
            obj.imageUnixTimeStamp = cellfun(@(x) str2double(x(end-23:end-8)), ...
                imageFnsAllSeq);
            
            obj.seqNum = seqNum;
            obj.sequenceIdx = sequenceIdx;
            
            obj.loadUTMPosition();
            obj.removeImagesWithBadGPS();
            obj.dataSplitter();
        end
        
        function loadUTMPosition(obj)
            % Estimate image positions by applying linear interpolation on GPS
            % measurements based on image timestamps
            paths = localPaths;
            imageGPSPositions = [];
            gpsDataRoot = paths.gpsDataRootRobotCar;
            
            parfor i = 1:length(obj.sequenceIdx)
                % Load GPS+INS measurements.
                ins_file = [gpsDataRoot obj.sequenceIdx{i} '/gps/ins.csv'];
                
                imageTimeSingleSeq = obj.imageUnixTimeStamp(obj.seqNum == i);
                imageGPSPositionsSingleSeq = ...
                    getUTMPosition(ins_file, imageTimeSingleSeq);
                imageGPSPositions  = ...
                    [imageGPSPositions; imageGPSPositionsSingleSeq];
            end
            
            % Store keyframe position estimate from GPS+INS measurements
            obj.utm = imageGPSPositions;
        end
        
        function removeImagesWithBadGPS(obj)
            validGPSMeasurements = ~isnan(obj.utm(:,1));
            
            obj.imageFns = obj.imageFns(validGPSMeasurements);
            obj.imageUnixTimeStamp = obj.imageUnixTimeStamp(validGPSMeasurements);
            obj.seqNum = obj.seqNum(validGPSMeasurements);
            obj.imageTimeStamp = obj.imageTimeStamp(validGPSMeasurements);
            obj.utm = obj.utm(validGPSMeasurements, :);
        end
        
        function dataSplitter(obj)
            switch obj.whichSet
                case 'train'
                    subsetIdx = find(obj.utm(:, 2) > obj.eastThr);
                    isDatabase = rand(length(subsetIdx), 1) < obj.dbRatio;
                    
                case 'val'
                    subsetIdx = find(obj.utm(:, 2) < obj.eastThr ...
                        & obj.utm(:, 1) > obj.northThr);
                    isDatabase = rand(length(subsetIdx), 1) < obj.dbRatio;
                    
                case 'test'
                    subsetIdx = find(obj.utm(:, 2) < obj.eastThr ...
                        & obj.utm(:, 1) < obj.northThr);
                    isDatabase = rand(length(subsetIdx), 1) < obj.dbRatio;
                    
                otherwise
                    disp('Unknown dataset type!');
                    assert(false);
            end
            
            dbIdx = subsetIdx(isDatabase);
            qIdx = subsetIdx(~isDatabase);
            
            obj.dbImageFns = obj.imageFns(dbIdx);
            obj.dbTimeStamp = obj.imageTimeStamp(dbIdx);
            obj.utmDb = obj.utm(dbIdx, :);
            obj.numImages = length(dbIdx);
            
            obj.qImageFns = obj.imageFns(qIdx);
            obj.qTimeStamp = obj.imageTimeStamp(qIdx);
            obj.utmQ = obj.utm(qIdx, :);
            obj.numQueries = length(qIdx);
        end
    end
end