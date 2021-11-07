close all;
%% Sorting the IMU data into a stucture that contains the file name, upper and lower limits (from manually sectioning data) for each data set
rawData.fileName = ["009-testingSampling.csv"];
rawData.lowerLimit = [735];
rawData.upperLimit = [2215];

%% Excutes the interpolationFunction
for i = 1:length(rawData.fileName)
   [allData, len, t2, timeData, interpolatedData]= interpolationFunction(rawData.fileName(i),rawData.lowerLimit(i), rawData.upperLimit(i)); 
end 

%% Interpolation function
% Looks at the time between each sample and linearly interpolates to
% correct the sampling time to 10ms.
function [allData, len, t2, timeData, interpolatedData] = interpolationFunction(fileName, lowerLimit, upperLimit)
%% Reading manually selected data
imuData = csvread(fileName);
imuData = imuData(lowerLimit:upperLimit,:);
len = length(imuData);
t2 = linspace(1,len,len);
count = 0;

allData = struct('AccX',imuData(:,1),'AccY',imuData(:,2),'AccZ',imuData(:,3),...
    'GravityX',imuData(:,4),'GravityY',imuData(:,5),'GravityZ',imuData(:,6),...
    'LinAccX',imuData(:,7),'LinAccY',imuData(:,8),'LinAccZ',imuData(:,9),...
    'GyroX',imuData(:,10),'GyroY',imuData(:,11),'GyroZ',imuData(:,12),...
    'MagX',imuData(:,13),'MagY',imuData(:,14),'MagZ',imuData(:,15),'t',imuData(:,16));

%% Deteriming sample time between the data points
% timeData.origalSamplePoints is for normalizing the data set to start at 0 seconds instead
% of the time it was selected at during the data collection phase.

% timeData.t is to determine the sample time between adjacent samples of
% the raw IMU data

for i = 1:len
    if i == 1 
       timeData.t(i) = 10;  % assume the sampling rate for the first sample is 10ms, since there is no previous sample to calcualte.
       timeData.originalSamplePoints(i) = 0;
    elseif i == len
        timeData.t(i) = 10; % assume the sampling rate for the last sample is 10ms. since there is no subsequent sample to calcualte.
        timeData.originalSamplePoints(len) = allData.t(i)-allData.t(1);
    else
        timeData.t(i) = allData.t(i+1)-allData.t(i); % time between samples
        timeData.originalSamplePoints(i) = allData.t(i)-allData.t(1);
    end
end


% Creates a new time vector with spacing of 10ms, i.e., 100Hz
for i = 1:len
    timeData.tsample(i) = count;
    count = count + 10;
end

fields = fieldnames(allData);

% Creates the new Dataset for each sensor reading by means of linear
% interpolation
for i = 1:length(fields)
    interpolatedData.(fields{i}) = interp1(timeData.originalSamplePoints,allData.(fields{i}),timeData.tsample,'linear');
end
%% Determining the sample time between adjacent samples of the new interpolated data
% for i = 1:len
%     if i == 1 
%        interpolatedData.t(i) = 10;
%     elseif i == len
%         interpolatedData.t(i) = 10; % assume the sampling rate for the last sample is 10ms. No next sample to calc
%     else
%         interpolatedData.t(i) = interpolatedData.t(i+1)-interpolatedData.t(i); % time between samples
%     end
% end

%% Displays the varying sampling time between recorded samples
figure;
plot(timeData.t(:,1:end-1));
xlabel('Sample Index');
ylabel('Time between adjacent samples [ms]');
ylim([7 13])
title(fileName);

%% Displays the interpolated dataset sample time
% figure;
% plot(interpolatedData.t(:,1:end-1),'DisplayName','Interpolated Data');
% xlabel('Sample Index');
% ylabel('Time between adjacent samples [ms]');
% ylim([7 13])
% title(fileName)

%% Plots comparing the raw IMU sensor readings to the interpolated sensor readings
%% GYRO
% figure;
% plot(allData.GyroX,'DisplayName','GyroX')
% hold on;
% plot(interpolatedData.GyroX,'--','DisplayName','InterpolatedGyroX')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.GyroY,'DisplayName','GyroY')
% hold on;
% plot(interpolatedData.GyroY,'--','DisplayName','InterpolatedGyroY')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.GyroZ,'DisplayName','GyroZ')
% hold on;
% plot(interpolatedData.GyroZ,'--','DisplayName','InterpolatedGyroZ')
% hold off;
% title(fileName);
% legend();
% 
% %% ACC
% figure;
% plot(allData.AccX,'DisplayName','AccX')
% hold on;
% plot(interpolatedData.AccX,'--','DisplayName','InterpolatedAccX')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.AccY,'DisplayName','AccY')
% hold on;
% plot(interpolatedData.AccY,'--','DisplayName','InterpolatedAccY')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.AccZ,'DisplayName','AccZ')
% hold on;
% plot(interpolatedData.AccZ,'--','DisplayName','InterpolatedAccZ')
% hold off;
% title(fileName);
% legend();
% 
% %% GRAVITY
% figure;
% plot(allData.GravityX,'DisplayName','GravX')
% hold on;
% plot(interpolatedData.GravityX,'--','DisplayName','InterpolatedGravX')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.GravityY,'DisplayName','GravY')
% hold on;
% plot(interpolatedData.GravityY,'--','DisplayName','InterpolatedGravY')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.GravityZ,'DisplayName','GravZ')
% hold on;
% plot(interpolatedData.GravityZ,'--','DisplayName','InterpolatedGravZ')
% hold off;
% title(fileName);
% legend();
% 
% %% LIN_ACC
% figure;
% plot(allData.LinAccX,'DisplayName','LinAccX')
% hold on;
% plot(interpolatedData.LinAccX,'--','DisplayName','InterpolatedLinAccX')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.LinAccY,'DisplayName','LinAccY')
% hold on;
% plot(interpolatedData.LinAccY,'--','DisplayName','InterpolatedLinAccY')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.LinAccZ,'DisplayName','LinAccZ')
% hold on;
% plot(interpolatedData.LinAccZ,'--','DisplayName','InterpolatedLinAccZ')
% hold off;
% title(fileName);
% legend();
% 
% %% MAG
% figure;
% plot(allData.MagX,'DisplayName','MagX')
% hold on;
% plot(interpolatedData.MagX,'--','DisplayName','InterpolatedMagX')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.MagY,'DisplayName','MagY')
% hold on;
% plot(interpolatedData.MagY,'--','DisplayName','InterpolatedMagY')
% hold off;
% title(fileName);
% legend();
% 
% figure;
% plot(allData.MagZ,'DisplayName','MagZ')
% hold on;
% plot(interpolatedData.MagZ,'--','DisplayName','InterpolatedMagZ')
% hold off;
% title(fileName);
% legend();
end




