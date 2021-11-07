%% CONVERTING SAMPATH JAYALATH CODE TO A FUNCTION TO BE RUN IN THE MAIN SCRIPT

function maincount = SampathJayalath(GyroX,GyroY,GyroZ,len)
% Setting up Variables
fs = 100;
t = 0:(1/fs):(len-1)*(1/fs);
counter1 = 0;
counter2 = 0;
var_k = 0;
i = 0;
u = 1;
gyro_up_peak = 0;
gyro_down_peak = 0;
filename = '';
%Variable Set by the Training Algorithm;
threshold1 = 0.05; 
%Variable Used to Update Step Count
maincount = 0;
gyro_count_enable = 0;
markIndices = [];
index = 1;
%% Filter Section
Gyro = zeros(length(GyroX),1);
filterBW = lowPassFilter(2);

% Standard Deciation to determine the most dominate axisst
stdGyroX = std(abs(GyroX));
stdGyroY = std(abs(GyroY));
stdGyroZ = std(abs(GyroZ));

if(stdGyroX>stdGyroY) && (stdGyroX>stdGyroZ)
    gyro = GyroX;
    filename = 'GryoX';
end

if(stdGyroY>stdGyroX) && (stdGyroY>stdGyroZ)
    gyro = GyroY;
    filename = 'GyroY';
end

if(stdGyroZ>stdGyroX) && (stdGyroZ>stdGyroY)
    gyro = GyroZ;
    filename = 'GyroZ';
end    
Gyro = filter(filterBW,gyro);

%% Pedometer Algorithm - Zero Crossing Code 
for i=3:len
    u = u + 1;
    j = i - 1;
    k = j - 1;
    
    
    %Gyro Countdown
    if((Gyro(i)<0) && (Gyro(j)>0)&& (gyro_count_enable==1))
        counter1=1;
        counter2=0;
        var_k=u;
        if(gyro_up_peak >threshold1)
            maincount=maincount+1; 
            markIndicies(index) = i;
            index = index + 1;
        end
    end
    
    %Gyro Countup
    if((Gyro(i)>0) && (Gyro(j)<0) && (gyro_count_enable==1))
        counter2=1; 
        counter1=0;
    var_k=u;
        if(gyro_down_peak <-threshold1)
            maincount=maincount+1;
            markIndicies(index) = i;
            index = index + 1;
        end
    end
    
    %Detecting Upward Peak 
    if((Gyro(i)<Gyro(j)) && (Gyro(j)>Gyro(k) && (counter2==1)))
        gyro_up_peak = Gyro(j);
    end
    
    %Detecting Downward Peak 
    if((Gyro(i)>Gyro(j)) && (Gyro(j)<Gyro(k) && (counter1==1)))
        gyro_down_peak = Gyro(j);
    end
    
    %Sample Time Out 
    if(((counter1==1)&&(u<var_k+15))||((counter2==1)&&(u<var_k+15)))
     gyro_count_enable=0;
    else
     gyro_count_enable=1;
    end
    
end    

%//////////////////End Of The Main Algorithm//////////////////
%Plotting the Gyro-X axis data
figure;
plot(Gyro,'DisplayName',filename);
plot(Gyro,'-x','MarkerIndices',markIndicies,'MarkerEdgeColor','r');
grid;
xlabel('Time (s)');
ylabel('Gyro-X(rad/s)');
title('Gyro Sensor Reading');
legend();

disp(["Gyroscope algorithm steps count: " maincount])
end







