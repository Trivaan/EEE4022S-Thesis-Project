function [AccSteps newAcc] = AccelerometerAlgorithm(AccX,AccY,AccZ...
    ,LinAccX,LinAccY,LinAccZ...
    ,GyroX,GyroY,GyroZ...
    ,rawDatalowerLimit, rawDataupperLimit)
    
% Initializing variables

AccSteps = 0;
var_k = 0;

u = 1;
n = 1;


threshold = 0.3;

acc_count_enable = 0;
upper = rawDataupperLimit;
lower = rawDatalowerLimit;
lenOfData = upper-lower+1;
t = linspace(1,lenOfData,lenOfData);    
        
% Smooth
filterAccX = smooth(AccX,21);          % Accelerometer
filterAccY = smooth(AccY,21);
filterAccZ = smooth(AccZ,21);


% Accelerometer Magnitude
AccMagnitude = sqrt((AccX).*(AccX) + (AccY).*(AccY) + (AccZ).*(AccZ));
filterAccMagnitude = sqrt((filterAccX).*(filterAccX) + (filterAccY).*(filterAccY) + (filterAccZ).*(filterAccZ));

% remove gravity component
filteredAfterwardsAccMagnitude = smooth(filterAccMagnitude,21)-9.8;


peaksAcc = [];
indexOfPeaksAcc = [];

%% Reducing false peaks - mean difference method

leftValues = 0;
rightValues = 0;
windowSize =77;
windowLength = (windowSize-1)/2;
for i = windowLength+1:(lenOfData-windowLength)
    
    for j = (i+1):(windowLength+i)
        rightValues = (filteredAfterwardsAccMagnitude(i) - filteredAfterwardsAccMagnitude(j)) + rightValues; 
    end
    
    for k = (i-1):-1:(i-windowLength)
        leftValues = (filteredAfterwardsAccMagnitude(i) - filteredAfterwardsAccMagnitude(k)) + leftValues;
    end
    
    newAcc(i) = ((leftValues)+(rightValues))/(2*windowLength);
    leftValues = 0;
    rightValues = 0;
end

%% Reducing false peaks
% leftValues = 0;
% rightValues = 0;
% windowSize =77;
% windowLength = (windowSize-1)/2;
% for i = windowLength+1:(lenOfData-windowLength)
%     
%     for j = (i+1):(windowLength+i)
%         
% %         leftValues = (filteredAfterwardsAccMagnitude(i) - filteredAfterwardsAccMagnitude(j)) + leftValues;
%         rightValues = (filteredAfterwardsAccMagnitude(j)) + rightValues;
%         
%     end
%     
%     for k = (i-1):-1:(i-windowLength)
%         
%         leftValues = (filteredAfterwardsAccMagnitude(k)) + leftValues;
% %         rightValues = (filteredAfterwardsAccMagnitude(i) - filteredAfterwardsAccMagnitude(j)) + rightValues;
%         
%     end
%     
%    
%     newAcc(i) = (((filteredAfterwardsAccMagnitude(i))-((leftValues)/(windowLength)))+...
%         ((filteredAfterwardsAccMagnitude(i))-((rightValues)/(windowLength))))/2;
%     leftValues = 0;
%     rightValues = 0;
% end

%% Original Step Detection Algorithm
for i = 3:length(newAcc)  
    j = i - 1;
    k = j - 1;

%% Peak Detection
if((newAcc(i)<newAcc(j)) && (newAcc(j)>newAcc(k)) && acc_count_enable == 1)
    
    if (newAcc(j) >= threshold)
        peaksAcc(n) = newAcc(j);
        indexOfPeaksAcc(n) = j;
        n = n + 1;
        var_k=u;
    end
    
end
%
%% Sample time delay to reduce the detection of false peaks
% This is set to 30 samples, which equates to 300ms -> 3.33Hz walking
% speed. If the user runs then this needs to be reduced 
if((u<var_k+30))
    acc_count_enable=0;
else
    acc_count_enable=1;
end

u = u + 1;
end
    
if isempty(peaksAcc)
    disp('No Steps')
end

AccSteps = length(peaksAcc);
disp(["Accelerometer algorithm step count: " AccSteps])

figure;
plot(newAcc,'DisplayName','Acceleration Norm');
hold on;
plot(indexOfPeaksAcc, peaksAcc, 'r', 'Marker', 'o', 'LineStyle', 'none');
xlabel('Sample Index');
ylabel('Accelerometer Norm (m/s^2)')
title('Acceleration algorithm peak detection');
% legend('Acceleration Norm (m/s^2)');
end


