%%                                Part A                                 %% \
%% Problem 1
% Data set extraction
% Opening the Odomtry file
fileID = fopen('ds1/ds1_Odometry.dat','r');
data = textscan(fileID,'%s %s %s');
tdata1 = data{1};
tdata1 = tdata1(12:end);
tdata1 = str2double(cellstr(tdata1));
vdata1 = data{2};
vdata1 = vdata1(12:end);
vdata1 = str2double(cellstr(vdata1));
omdata1 = data{3};
omdata1 = omdata1(12:end);
omdata1 = str2double(cellstr(omdata1));
fclose(fileID);

% Opening the Landmark Ground Truth file
fileID = fopen('ds1/ds1_Landmark_GroundTruth.dat','r');
data = textscan(fileID,'%s %s %s %s %s');
subject1 = data{1};
subject1 = subject1(9:end);
subject1 = str2double(cellstr(subject1));
Xvalue1 = data{2};
Xvalue1 = Xvalue1(9:end);
Xvalue1 = str2double(cellstr(Xvalue1));
Yvalue1 = data{3};
Yvalue1 = Yvalue1(9:end);
Yvalue1 = str2double(cellstr(Yvalue1));
Xstd1 = data{4};
Xstd1 = Xstd1(9:end);
Xstd1 = str2double(cellstr(Xstd1));
Ystd1 = data{5};
Ystd1 = Ystd1(9:end);
Ystd1 = str2double(cellstr(Ystd1));
fclose(fileID);

% Opening the ground truth file
fileID = fopen('ds1/ds1_Groundtruth.dat','r');
data = textscan(fileID,'%s %s %s %s %s');
ttime1 = data{1};
ttime1 = ttime1(8:end);
ttime1 = str2double(cellstr(ttime1));
tX1 = data{2};
tX1 = tX1(8:end);
tX1 = str2double(cellstr(tX1));
tY1 = data{3};
tY1 = tY1(8:end);
tY1 = str2double(cellstr(tY1));
trad1 = data{4};
trad1 = trad1(8:end);
trad1 = str2double(cellstr(trad1));
fclose(fileID);


fileID = fopen('ds1/ds1_Barcodes.dat','r');
data = textscan(fileID,'%s %s');
index1 = data{1};
index1 = index1(14:end);
index1 = str2double(cellstr(index1));
value1 = data{2};
value1 = value1(14:end);
value1 = str2double(cellstr(value1));
fclose(fileID);
subjectall1 = value1(index1);

fileID = fopen('ds1/ds1_Measurement.dat','r');
data = textscan(fileID,'%s %s %s %s');
mtime1 = data{1};
mtime1 = mtime1(9:end);
mtime1 = str2double(cellstr(mtime1));
msubject1 = data{2};
msubject1 = msubject1(9:end);
msubject1 = str2double(cellstr(msubject1));
mrad1 = data{3};
mrad1 = mrad1(9:end);
mrad1 = str2double(cellstr(mrad1));
mbear1 = data{4};
mbear1 = mbear1(9:end);
mbear1 = str2double(cellstr(mbear1));
fclose(fileID);
for i = 1:length(msubject1)
    mindex1(i) = round(sum((msubject1(i)==subjectall1).*index1));
end

% Getting rid of repeated mesurements. I do this because I assume that the
% measurements made at the same time as others have the same error as the
% rest of mesurements made. Since I have enough data, I don't bother with
% these data points for my measurement model

[a,b] = unique(tdata1);
tdata1u = a;
vdata1u = vdata1(b);
omdata1u = omdata1(b);
[a,b] = unique(ttime1);
ttime1u = a;
tX1u = tX1(b);
tY1u = tY1(b);
trad1u = trad1(b);
[a,b] = unique(mtime1); % getting rid of repeating measurument time for easier interpolation
mtime1u = a;
mindex1u = mindex1(b);
mrad1u = mrad1(b);
mbear1u = mbear1(b);

% syncing time
interpX1 = interp1(ttime1u,tX1u,mtime1u);
interpX1 = interp1(mtime1u,interpX1,mtime1);
interpY1 = interp1(ttime1u,tY1u,mtime1u);
interpY1 = interp1(mtime1u,interpY1,mtime1);
interptrad1 = interp1(ttime1u,trad1u,mtime1u);
interptrad1 = interp1(mtime1u,interptrad1,mtime1);
interpV1 = interp1(tdata1,vdata1,mtime1u);
interpV1 = interp1(mtime1u,interpV1,mtime1);
interpW1 = interp1(tdata1,omdata1,mtime1u);
interpW1 = interp1(mtime1u,interpW1,mtime1);

for i = 1:length(mrad1)
    index = mindex1(i);
    XL = sum((index==subject1).*Xvalue1);
    YL = sum((index==subject1).*Yvalue1);
    Xbelieved1(i) = XL - mrad1(i)*cos(interptrad1(i)+mbear1(i));
    Ybelieved1(i) = YL - mrad1(i)*sin(interptrad1(i)+mbear1(i));
end

E = sqrt((Xbelieved1-interpX1').^2 + (Ybelieved1-interpY1').^2);
E1 = E*(interpW1 == min(interpW1));
E2 = E*(interpW1 == 0);
E3 = E*(interpW1 == max(interpW1));
E4 = E*(interpV1 == min(interpV1));
E5 = E*(interpV1 == median(interpV1));
E6 = E*(interpV1 == max(interpV1));
figure
plot([min(interpW1),0,max(interpW1)],[mean(E1),mean(E2),mean(E3)],'*');
xlabel('v odomotery value');
ylabel('rms error of measurement (m)');
title('root mean squared error of measurement');
figure
plot([min(interpV1),median(interpV1),max(interpV1)],[mean(E4),mean(E5),mean(E6)],'*');
xlabel('{\omega} odomotery value');
ylabel('rms error of measurement (m)');
title('root mean squared error of measurement');
figure
histogram(E.*(interpW1==0)')
ylabel('number of occurances');
xlabel('root squared error in position (m)');
title('histogram of error in position measurement made when {\omega} = 0 rad/s');
figure
histogram(E.*(interpW1==0)'.*(interpV1==0)')
ylabel('number of occurances');
xlabel('root squared error in position (m)');
title('histogram of error in position measurement made when v = 0m/s and {\omega} = 0 rad/s');

% building the data set

fileID = fopen('dataset/dataset.txt','w');
fprintf(fileID,'ang vel \t trans vel \t\t\t error \n\n\n');
for i = 1:length(interpV1)
    fprintf(fileID,'%d\t\t\t\t%d\t\t\t\t%d\n',interpW1(i),interpV1(i),E(i));
end
fclose(fileID);

fprintf('Building and evaluating NN algorithm on data set 1\n');
%completing tests on test data 1
testing
fprintf('Building and evaluating NN algorithm on data set 2\n');
%completing tests on test data 2
testing2
