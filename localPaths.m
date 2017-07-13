function paths= localPaths()
    
    % --- dependencies
    
    % refer to README.md for the information on dependencies
    
    paths.libReljaMatlab= '~/catkin_ws/src/relja_matlab/';
    paths.libMatConvNet= '~/catkin_ws/src/matconvnet/'; % should contain matlab/
    
    % If you have installed yael_matlab (**highly recommended for speed**),
    % provide the path below. Otherwise, provide the path as 'yael_dummy/':
    % this folder contains my substitutes for the used yael functions,
    % which are **much slower**, and only included for demonstration purposes
    % so do consider installing yael_matlab, or make your own faster
    % version (especially of the yael_nn function)
    paths.libYaelMatlab= '~/catkin_ws/src/yael_matlab/';
    
    % --- dataset specifications
    
    paths.dsetSpecDir= '~/Data/netvlad/datasets';
    
    % --- dataset locations
    paths.dsetRootPitts= '~/Database/Pittsburgh/'; % should contain images/ and queries/
    paths.dsetRootTokyo247= '~/Database/Tokyo247/'; % should contain images/ and query/
    paths.dsetRootTokyoTM= '~/Database/TokyoTM/'; % should contain images/
    paths.dsetRootOxford= '~/Database/OxfordBuildings/'; % should contain images/ and groundtruth/, and be writable
    paths.dsetRootParis= '~/Databases/Paris/'; % should contain images/ (with subfolders defense, eiffel, etc), groundtruth/ and corrupt.txt, and be writable
    paths.dsetRootHolidays= '~/Databases/Holidays/'; % should contain jpg/ for the original holidays, or jpg_rotated/ for rotated Holidays, and be writable
    paths.dsetRootRobotCar= '/media/yawei/My_Passport/RobotCar-Datasets/';
    paths.gpsDataRootRobotCar= '/media/yawei/My_Passport/DSO_Map/GPS/';
    % --- our networks
    % models used in our paper, download them from our research page
    paths.ourCNNs= '~/Data/netvlad/models/';
    
    % --- pretrained networks
    % off-the-shelf networks trained on other tasks, available from the MatConvNet
    % website: http://www.vlfeat.org/matconvnet/pretrained/
    paths.pretrainedCNNs= '~/Data/netvlad/pretrained/';
    
    % --- initialization data (off-the-shelf descriptors, clusters)
    % Not necessary: these can be computed automatically, but it is recommended
    % in order to use the same initialization as we used in our work
    paths.initData= '~/Data/netvlad/initdata/';
    
    % --- output directory
    paths.outPrefix= '/media/yawei/HDD/netvlad/output/';
end
