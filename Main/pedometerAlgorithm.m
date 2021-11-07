function [accSteps newAcc] = pedometerAlgorithm(AccX,AccY,AccZ...
    ,LinAccX,LinAccY,LinAccZ...
    ,GyroX,GyroY,GyroZ...
    ,rawDatalowerLimit, rawDataupperLimit)
    
% Initializing variables
enable_gyro_code = 1;
accSteps = 0;
var_k = 0;
var_q = 0;
fc = 2;
u = 1;
n = 1;
q=1;
gyro_name = '';
threshold = 0.3;
gyroDetection = 0;

acc_count_enable = 0;
gyro_count_enable = 0;
upper = rawDataupperLimit;
lower = rawDatalowerLimit;
lenOfData = upper-lower+1;
t = linspace(1,lenOfData,lenOfData);

%% scaling Gyro Data to acceleromter data
scaled_GyroX = ((GyroX).*(180/pi)).*(1/30);
scaled_GyroY = ((GyroY).*(180/pi)).*(1/30);
scaled_GyroZ = ((GyroZ).*(180/pi)).*(1/30);

%% Determine most dominant axis
stdGyroX = std(abs(scaled_GyroX));
stdGyroY = std(abs(scaled_GyroY));
stdGyroZ = std(abs(scaled_GyroZ));

if(stdGyroX>stdGyroY) && (stdGyroX>stdGyroZ)
    gyro = scaled_GyroX;
    gyro_name = 'GyroX';
end

if(stdGyroY>stdGyroX) && (stdGyroY>stdGyroZ)
    gyro = scaled_GyroY;
    gyro_name = 'GyroY';
end

if(stdGyroZ>stdGyroX) && (stdGyroZ>stdGyroY)
    gyro = scaled_GyroZ;
    gyro_name = 'GyroZ';
end

%% Apply filter to dominant gyro data
gyroFilter = lowPassFilter(fc);
Gyro = filter(gyroFilter,gyro)';
    
        
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

peaksGyro = [];
indexOfPeaksGyro = [];
valleysGyro = [];
indexOfValleysGyro = [];
peakCount = 1;
valleyCount =1;
%% Reducing false peaks - mean difference method

leftValues = 0;
rightValues = 0;
windowSize =77;
windowLength = (windowSize-1)/2;
for i = windowLength+1:(lenOfData-windowLength)
    
    for j = (i+1):(windowLength+i)
        
%         leftValues = (filteredAfterwardsAccMagnitude(i) - filteredAfterwardsAccMagnitude(j)) + leftValues;
        rightValues = (filteredAfterwardsAccMagnitude(i) - filteredAfterwardsAccMagnitude(j)) + rightValues;
        
    end
    
    for k = (i-1):-1:(i-windowLength)
        
        leftValues = (filteredAfterwardsAccMagnitude(i) - filteredAfterwardsAccMagnitude(k)) + leftValues;
%         rightValues = (filteredAfterwardsAccMagnitude(i) - filteredAfterwardsAccMagnitude(j)) + rightValues;
        
    end
    
    newAcc(i) = ((leftValues)+(rightValues))/(2*windowLength);
    leftValues = 0;
    rightValues = 0;
end

%% Reducing false peaks - idk difference method
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
% Gyro = Gyro(1:length(newAcc),:);

%% Step Detection Algorithm
for i = 3:length(newAcc)
% for i = 3:lenOfData  
    j = i - 1;
    k = j - 1;   
%% Peak Detection
if((newAcc(i)<newAcc(j)) && (newAcc(j)>newAcc(k)) && acc_count_enable == 1)
%                 acc_count_enable = 0;
    
    if (newAcc(j) >= threshold)
        peaksAcc(n) = newAcc(j);
        indexOfPeaksAcc(n) = j;
        n = n + 1;
        var_k=u;
    end
    
end
%% Gyroscope Peak and Valley detection
% Detecting Peak
if((Gyro(i)<Gyro(j)) && (Gyro(j)>Gyro(k)))
    if(n>1 && gyro_count_enable == 1)
    peaksGyro(peakCount) = Gyro(j);
    indexOfPeaksGyro(peakCount) = j;
    peakCount = peakCount + 1;
    var_q=q;
    end
end

% Detecting Valley 
if((Gyro(i)>Gyro(j)) && (Gyro(j)<Gyro(k)) )
    if (n>1 && gyro_count_enable == 1)
    valleysGyro(peakCount) = Gyro(j);
    indexOfValleysGyro(peakCount) = j;
    valleyCount = valleyCount + 1;
    var_q=q;
    end
end

%
%% Sample time delay to reduce the detection of false peaks - Accelerometer
if((u<var_k+30))
    acc_count_enable=0;
else
    acc_count_enable=1;
end

u = u + 1;
    
    
%% Sample time delay to reduce the detection of false peaks or valleys - Gyroscope
if((q<var_q+30))
    gyro_count_enable=0;
else
    gyro_count_enable=1;
end
q = q + 1;
   
end
%% Gyroscope Condition to determine first instance of peak or valley   
      
if( (indexOfValleysGyro(1) > indexOfPeaksAcc(1)) && (indexOfValleysGyro(1) < indexOfPeaksAcc(2)) &&...
        (indexOfPeaksGyro(1) > indexOfPeaksAcc(1)) && (indexOfPeaksGyro(1) < indexOfPeaksAcc(2))...
        )
        if(abs(peaksGyro(1))>abs(valleysGyro(1)))
            gyroDetection = 1;
        else 
            gyroDetection = -1;
        end

elseif(((indexOfValleysGyro(1) > indexOfPeaksAcc(1)) && (indexOfValleysGyro(1) < indexOfPeaksAcc(2))))
    gyroDetection = -1;
    
    
elseif(((indexOfPeaksGyro(1) > indexOfPeaksAcc(1)) && (indexOfPeaksGyro(1) < indexOfPeaksAcc(2))))
    gyroDetection = 1;
    
else
    gyroDetection = 0;
end
%% Check for periodicity of gyroscope data - this determines if the phone is in the pocket
if gyroDetection == 0
    enable_gyro_code = 0;
    
elseif gyroDetection == 1               % Peak
    for i = 3:length(indexOfPeaksGyro)
        j = i - 1;
        k = j - 1;
        correspondingAccPeak = (k*2)-1; % a single gyro peak or valley should be inbetween 2 acc. peak 
        a = abs(indexOfPeaksGyro(i)-indexOfPeaksGyro(j));
        b = abs(indexOfPeaksGyro(k)-indexOfPeaksGyro(j));
        if (abs(a-b)>20)                % determines the variation between peaks or valleys to estimate periodicity
            enable_gyro_code = 0;
        end
    end
    
elseif gyroDetection == -1              % Valley
    for i = 3:length(indexOfValleysGyro)
        j = i - 1;
        k = j - 1;
        correspondingAccPeak = (k*2)-1; % a single gyro peak or valley should be inbetween 2 acc. peak 
        a = abs(indexOfValleysGyro(i)-indexOfValleysGyro(j));
        b = abs(indexOfValleysGyro(k)-indexOfValleysGyro(j));
        if (abs(a-b)>20)                % determines the variation between peaks or valleys to estimate periodicity
            enable_gyro_code = 0;
        end
    end
    
end

    
if enable_gyro_code == 1
    [gyroSteps] = SampathJayalath(GyroX,GyroY,GyroZ,rawDataupperLimit-rawDatalowerLimit);
end

if (enable_gyro_code == 0)
    
    if isempty(peaksAcc)
        disp('No Steps')
    end
    
    accSteps = length(peaksAcc);  
    disp(["Trivaan Steps" string(accSteps)])

    figure;
    plot(newAcc,'DisplayName','Filtered afterwards Accelerometer Magnitude');
    hold on;
%     plot(Gyro,'DisplayName',gyro_name);
    plot(indexOfPeaksAcc, peaksAcc, 'r', 'Marker', 'o', 'LineStyle', 'none');
%     plot(indexOfPeaksGyro, peaksGyro, 'b', 'Marker', 'o', 'LineStyle', 'none');
%     plot(indexOfValleysGyro, valleysGyro, 'p', 'Marker', 'o', 'LineStyle', 'none');
    xlabel('Sample Index');
    ylabel('Acceleration Norm ({m}/{s^2})')
    legend();
    
end

end


%% Plots comparing Acc to LinAcc - Interpolated
%     figure;
%     plot(t,AccX,'DisplayName','Accelerometer X Magnitude');
%     hold on;
%     plot(t,LinAccX,'--','DisplayName','Linear Accelerometer X Magnitude');
%     xlabel('Sample Index');
%     ylabel('Accelerometer vs Linear Accelerometer(m/s^2)')
%     legend();
%     
%     figure;
%     plot(t,AccY,'DisplayName','Accelerometer Y Magnitude');
%     hold on;
%     plot(t,LinAccY,'--','DisplayName','Linear Accelerometer Y Magnitude');
%     xlabel('Sample Index');
%     ylabel('Accelerometer vs Linear Accelerometer(m/s^2)')
%     legend();
%     
%     figure;
%     plot(t,AccZ,'DisplayName','Accelerometer Z Magnitude');
%     hold on;
%     plot(t,LinAccZ,'--','DisplayName','Linear Accelerometer Z Magnitude');
%     xlabel('Sample Index');
%     ylabel('Accelerometer vs Linear Accelerometer(m/s^2)')
%     legend();

%% Plots comparing Acc to LinAcc - Filtered
%     figure;
%     plot(t,filterAccX,'DisplayName','Accelerometer X Magnitude');
%     hold on;
%     plot(t,filterLinAccX,'--','DisplayName','Linear Accelerometer X Magnitude');
%     xlabel('Sample Index');
%     ylabel('Accelerometer vs Linear Accelerometer(m/s^2)')
%     legend();
%     
%     figure;
%     plot(t,filterAccY,'DisplayName','Accelerometer Y Magnitude');
%     hold on;
%     plot(t,filterLinAccY,'--','DisplayName','Linear Accelerometer Y Magnitude');
%     xlabel('Sample Index');
%     ylabel('Accelerometer vs Linear Accelerometer(m/s^2)')
%     legend();
%     
%     figure;
%     plot(t,filterAccZ,'DisplayName','Accelerometer Z Magnitude');
%     hold on;
%     plot(t,filterLinAccZ,'--','DisplayName','Linear Accelerometer Z Magnitude');
%     xlabel('Sample Index');
%     ylabel('Accelerometer vs Linear Accelerometer(m/s^2)')
%     legend();

%% Plot Comparing the Accelerometer Magnitude With the Filtered Accelerometer Magnitude
%     figure; 
%     plot(t,AccMagnitude,'DisplayName','Accelerometer Magnitude');
%     hold on;
%     plot(t,filteredAccMagnitude,'DisplayName','Filtered Accelerometer Magnitude')
%     xlabel('Sample Index');
%     ylabel('Magnitude (m/s^2)')
%     legend();

%% Plot Comparing the filtered Acclereomter Magnitudes
%     figure;
%     plot(t,LinFilteredAccMagnitude,'DisplayName','Linear Accelerometer Magnitude');
%     hold on;
%     plot(t,abs(FilteredAccMagnitudeWOgravity),'--','DisplayName','Accelerometer WO gravity')
%     plot(t,filteredAccMagnitude,'DisplayName','Accelerometer Data');
%     hold off;
%     xlabel('Sample Index');
%     yline(minMagnitudeWOgravity);
%     ylabel('Magnitude (m/s^2)')
%     legend();