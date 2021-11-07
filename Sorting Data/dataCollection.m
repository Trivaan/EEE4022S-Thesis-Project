close all;
%% Sorting the IMU data into a stucture that contains the file name for each data set
% rawData.fileName = ["100.csv" "200.csv" "300.csv" "400.csv" "500.csv" "600.csv"...
%     "700.csv" "800.csv" "900.csv" "101.csv" "201.csv" "301.csv"];

rawData.fileName = ["001-slow-65.csv" "001-normal-53.csv" "001-fast-48.csv" "002-slow-50.csv" "002-normal-47.csv" "002-fast-41.csv" "003-slow-50.csv" "003-normal-48.csv" "003-fast-45.csv"...
     "001-hb-slow-54.csv" "001-hb-normal-54.csv" "001-hb-fast-48.csv" "002-hb-slow-46.csv" "002-hb-normal-43.csv" "002-hb-fast-42.csv" "003-hb-slow-50.csv" "003-hb-normal-50.csv" "003-hb-fast-46.csv"...
     "001-downstairs-17.csv" "002-downstairs.csv" "003-downstairs.csv" "001-upstairs-17.csv" "002-upstairs.csv" "003-upstairs.csv" ...
    "001-downstaira-17-hb.csv" "002-downstairs-hb.csv" "003-hb-downstairs.csv" "001-stairs-17-hb.csv" "002-upstairs-hb.csv" "003-hb-upstairs.csv"];


%% Excute the Data Collection Function
for i = 1:length(rawData.fileName)
   [allData]= dataCollectionFunction(rawData.fileName(i)); 
end 
%% Data Collection Function
function [allData] = dataCollectionFunction(fileName)
%DATACOLLECTION is used to sort out the raw data so only relevant data is
%used
%   while the user uses the android application to collect raw IMU data,
%   the action of placing the phone in and out of the pocket or bag to
%   respectively start and stop recording data contributes to missteps
%   being. Therefore it is important to utilize data only when the action of walking is recorded.
%   This is achieved by plotting the data and manually limiting the x axis to
%   samples only when the event of walking was true.
%% 
imuData = csvread(fileName);

allData = struct('AccX',imuData(:,1),'AccY',imuData(:,2),'AccZ',imuData(:,3),...
    'GravityX',imuData(:,4),'GravityY',imuData(:,5),'GravityZ',imuData(:,6),...
    'LinAccX',imuData(:,7),'LinAccY',imuData(:,8),'LinAccZ',imuData(:,9),...
    'GyroX',imuData(:,10),'GyroY',imuData(:,11),'GyroZ',imuData(:,12),...
    'MagX',imuData(:,13),'MagY',imuData(:,14),'MagZ',imuData(:,15),'t',imuData(:,16));

%% Plots the raw IMU data to be manually sectioned 
figure;
plot(allData.GyroX,'DisplayName','GyroX');
hold on;
plot(allData.GyroY,'DisplayName','GyroY');
plot(allData.GyroZ,'DisplayName','GyroZ');
plot(allData.AccX,'DisplayName','AccX');
plot(allData.AccY,'DisplayName','AccY');
plot(allData.AccZ,'DisplayName','AccZ');
hold off;
title(fileName);
xlabel('Sample Index');
ylabel('Gyroscope ({rad}/{s}) and Accelerometer ({m}/{s^2})')
legend('GyroX','GyroY','GyroZ','AccX','AccY','AccZ');
end

