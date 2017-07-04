classdef oxfordRobotCarParser<handle
    
    properties
        imageFns;
        imageTimeStamp;
        utm;
        
        dbImageFns;
        numImages;
        utmDb;
        
        qImageFns;
        numQueries;
        utmQ;
        
        dbRatio;
        eastThr;
        northThr;
        nonTrivPosDistThr;
        posDisThr;
        seqIdx;
        seqTimeStamp;
        whichSet;
    end
    
    methods
        function obj= oxfordRobotCarParser(seqTimeStamp, posDisThr, ...
                nonTrivPosDistThr, whichSet, eastThr, northThr, dbRatio)
            
            % whichSet is one of: train, val, test
            assert( ismember(whichSet, {'train', 'val', 'test'}) );
            obj.whichSet = whichSet;
            
            obj.dbRatio = dbRatio;
            obj.posDisThr= posDisThr;
            obj.nonTrivPosDistThr= nonTrivPosDistThr;
            
            obj.eastThr = eastThr;
            obj.northThr = northThr;
            
            paths= localPaths();
            datasetRoot= paths.dsetRootRobotCar;
            
            datasetPathList = cell(size(seqTimeStamp));
            for i = 1:length(seqTimeStamp)
                datasetPathList{i} = {[datasetRoot seqTimeStamp{i} ...
                    '/stereo/centre/undistort_images_crop/']};
            end
            
            imageFnsAllSeq = [];
            seqIdx = [];
            for j = 1:length(datasetPathList)
                imageSingleSeq = dir(char(fullfile(datasetPathList{j},'*.jpg')));
                
                imageFoldersSingleSeq = char(imageSingleSeq.folder);
                imageNamesSingleSeq = char(imageSingleSeq.name);
                imageFnsSingleSeq = cellstr(strcat(string(...
                    imageFoldersSingleSeq(:,44:end)), ...
                    '/', string(imageNamesSingleSeq)));
                imageFnsAllSeq = [imageFnsAllSeq; imageFnsSingleSeq];
                
                seqIdx = [seqIdx; j*ones(length(imageFnsSingleSeq), 1)];
            end
            obj.imageFns = imageFnsAllSeq;
            obj.imageTimeStamp = cellfun(@(x) str2double(x(end-23:end-8)), imageFnsAllSeq);
            obj.seqIdx = seqIdx;
            obj.seqTimeStamp = seqTimeStamp;
            obj.loadUTMPosition();
            obj.removeImagesWithBadGPS();
            obj.dataSplitter();
        end
        
        function loadUTMPosition(obj)
            % Estimate image positions by applyiimageTimeStampng linear interpolation on GPS
            % measurements based on image timestamps
            paths = localPaths;
            imageGPSPositions = [];
            gpsDataRoot = paths.gpsDataRootRobotCar;
            
            parfor i = 1:length(obj.seqTimeStamp)
                % Load GPS+INS measurements.
                ins_file = [gpsDataRoot obj.seqTimeStamp{i} '/gps/ins.csv'];
                
                imageTimeSingleSeq = obj.imageTimeStamp(obj.seqIdx == i);
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
            obj.imageTimeStamp = obj.imageTimeStamp(validGPSMeasurements);
            obj.seqIdx = obj.seqIdx(validGPSMeasurements);
            obj.utm = obj.utm(validGPSMeasurements, :);
        end
        
        function dataSplitter(obj)
            switch obj.whichSet
                case 'train'
                    trainSetIdx = find(obj.utm(:, 2) > obj.eastThr);
                    isDatabase = rand(length(trainSetIdx), 1) < obj.dbRatio;
                    
                case 'val'
                    valSetIdx = obj.utm(:, 2) < obj.eastThr ...
                        & obj.utm(:, 1) > obj.northThr;
                    isDatabase = rand(length(valSetIdx), 1) < obj.dbRatio;
                    
                    dbIdx = valSetIdx(isDatabase);
                    qIdx = valSetIdx(~isDatabase);
                    
                    obj.dbImageFns = obj.imageFns(dbIdx);
                    obj.utmDb = obj.utm(dbIdx);
                    obj.numImages = length(dbIdx);
                    
                    obj.qImageFns = obj.imageFns(qIdx);
                    obj.utmQ = obj.utm(qIdx);
                    obj.numQueries = length(qIdx);
                    
                case 'test'
                    testSetIdx = obj.utm(:, 2) < obj.eastThr ...
                        & obj.utm(:, 1) < obj.northThr;
                    isDatabase = rand(length(testSetIdx), 1) < obj.dbRatio;
                    
                    dbIdx = testSetIdx(isDatabase);
                    qIdx = testSetIdx(~isDatabase);
                    
                    obj.dbImageFns = obj.imageFns(dbIdx);
                    obj.utmDb = obj.utm(dbIdx);
                    obj.numImages = length(dbIdx);
                    
                    obj.qImageFns = obj.imageFns(qIdx);
                    obj.utmQ = obj.utm(qIdx);
                    obj.numQueries = length(qIdx);
                    
                otherwise
                    disp('Unknown dataset type!');
                    assert(false);
            end
            dbIdx = trainSetIdx(isDatabase);
            qIdx = trainSetIdx(~isDatabase);
            
            obj.dbImageFns = obj.imageFns(dbIdx);
            obj.utmDb = obj.utm(dbIdx);
            obj.numImages = length(dbIdx);
            
            obj.qImageFns = obj.imageFns(qIdx);
            obj.utmQ = obj.utm(qIdx);
            obj.numQueries = length(qIdx);
        end
    end
end

