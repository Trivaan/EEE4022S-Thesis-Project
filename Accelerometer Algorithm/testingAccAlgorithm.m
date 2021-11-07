close all;
clear all;
%% Import the Raw Datasets
% rawData.fileName = ["100.csv" "200.csv" "300.csv" "400.csv" "500.csv" "600.csv"...
%     "700.csv" "800.csv" "900.csv" "101.csv" "201.csv" "301.csv"];
% rawData.lowerLimit = [964 925 772 847 773 727 715 464 569 640 753 730];
% rawData.upperLimit = [3678 3569 3465 3452 3522 3432 3371 3577 3545 3515 2185 1844];

rawData.fileName = ["001-slow-65.csv" "001-normal-53.csv" "001-fast-48.csv" "002-slow-50.csv" "002-normal-47.csv" "002-fast-41.csv" "003-slow-50.csv" "003-normal-48.csv" "003-fast-45.csv"...
     "001-hb-slow-54.csv" "001-hb-normal-54.csv" "001-hb-fast-48.csv" "002-hb-slow-46.csv" "002-hb-normal-43.csv" "002-hb-fast-42.csv" "003-hb-slow-50.csv" "003-hb-normal-50.csv" "003-hb-fast-46.csv"...
     "001-downstairs-17.csv" "002-downstairs.csv" "003-downstairs.csv" "001-upstairs-17.csv" "002-upstairs.csv" "003-upstairs.csv" ...
    "001-downstaira-17-hb.csv" "002-downstairs-hb.csv" "003-hb-downstairs.csv" "001-stairs-17-hb.csv" "002-upstairs-hb.csv" "003-hb-upstairs.csv"];

rawData.lowerlimit = [451 649 1045 649 632 646 442 420 708 622 527 560 652 610 814 491 674 489 855 636 450 792 650 557 614 1171 786 446 470 550]
rawData.upperlimit = [5814 4213 3750 4845 3871 3166 3865 3397 3350 4452 4089 3417 3390 3620 3346 3718 4116 3128 2262  1666 1575 2259 1917 1756 1892 2281 1947 1753 1649 1790]

%% Run the different functions for each Dataset
for i = 1:length(rawData.fileName)
    [allData]= testingAccelerometerAlgorithm(rawData.fileName(i),rawData.lowerLimit(i), rawData.upperLimit(i));
    
    [AccSteps newAcc] = AccelerometerAlgorithm(allData.AccX, allData.AccY, allData.AccZ...
        ,allData.LinAccX, allData.LinAccY, allData.LinAccZ...
        ,allData.GyroX, allData.GyroY, allData.GyroZ...
        ,rawData.lowerLimit(i), rawData.upperLimit(i));
end

%% Function that sorts the data into the pre-processing stage and subbsequent filtering stage
function [allData] = testingAccelerometerAlgorithm(fileName, lowerLimit, upperLimit)
 
imuData = csvread(fileName);
imuData = imuData(lowerLimit:upperLimit,:);

allData = struct('AccX',imuData(:,1),'AccY',imuData(:,2),'AccZ',imuData(:,3),...
    'GravityX',imuData(:,4),'GravityY',imuData(:,5),'GravityZ',imuData(:,6),...
    'LinAccX',imuData(:,7),'LinAccY',imuData(:,8),'LinAccZ',imuData(:,9),...
    'GyroX',imuData(:,10),'GyroY',imuData(:,11),'GyroZ',imuData(:,12),...
    'MagX',imuData(:,13),'MagY',imuData(:,14),'MagZ',imuData(:,15),'t',imuData(:,16));

end




