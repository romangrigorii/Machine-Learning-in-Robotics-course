%%%%                        progress report                           %%%%
addpath('C:\Users\Roman\Desktop\420\Project\2Dsamples');

img = double(rgb2gray(imread('sample1.jpg')));
sample1 = double(img);
sample1 = sample1(1:512,1:512);
img = double(rgb2gray(imread('sample2.jpg')));
sample2 = double(img);
sample2 = sample2(1:512,1:512);
img = double(rgb2gray(imread('sample3.jpg')));
sample3 = double(img);
sample3 = sample3(1:512,1:512);
img = double(rgb2gray(imread('sample4.jpg')));
sample4 = double(img);
sample4 = sample4(1:512,1:512);
img = double(rgb2gray(imread('sample5.jpg')));
sample5 = double(img);
sample5 = sample5(1:512,1:512);

figure
subplot(5,2,1);
back = -1*ones(100,100);
s = sample1(1:100,1:50);
s = 255*(s - min(min(s)))/(max(max(s)) - min(min(s)));
sam1b = back; sam1b(1:100,1:50) = s;
imagesc(sam1b);
title('sample 1 before');
xticks({}); yticks({});
subplot(5,2,2);
sam1a = NonParamSampling(sample1(1:100,1:50),[100,100],[50,40],1,0);
imagesc(sam1a);
title('sample 1 after');
xticks({}); yticks({});

subplot(5,2,3);
back = -1*ones(100,100);
s = sample2(1:100,1:50);
s = 255*(s - min(min(s)))/(max(max(s)) - min(min(s)));
sam1b = back; sam2b(1:100,1:50) = s;
imagesc(sam2b);
title('sample 2 before');
xticks({}); yticks({});
subplot(5,2,4);
sam2a = NonParamSampling(sample2(1:100,1:50),[100,100],[50,40],1,0);
imagesc(sam2a);
title('sample 2 after');
xticks({}); yticks({});

subplot(5,2,5);
back = -1*ones(100,100);
s = sample3(1:100,1:50);
s = 255*(s - min(min(s)))/(max(max(s)) - min(min(s)));
sam1b = back; sam3b(1:100,1:50) = s;
imagesc(sam3b);
title('sample 3 before');
xticks({}); yticks({});
subplot(5,2,6);
sam3a = NonParamSampling(sample3(1:100,1:50),[100,100],[50,40],1,0);
imagesc(sam3a);
title('sample 3 after');
xticks({}); yticks({});

subplot(5,2,7);
back = -1*ones(100,100);
s = sample4(1:100,1:50);
s = 255*(s - min(min(s)))/(max(max(s)) - min(min(s)));
sam4b = back; sam4b(1:100,1:50) = s;
imagesc(sam4b);
title('sample 4 before');
xticks({}); yticks({});
subplot(5,2,8);
sam4a = NonParamSampling(sample4(1:100,1:50),[100,100],[50,40],1,0);
imagesc(sam4a);
title('sample 4 after');
xticks({}); yticks({});

subplot(5,2,9);
back = -1*ones(100,100);
s = sample5(1:100,1:50);
s = 255*(s - min(min(s)))/(max(max(s)) - min(min(s)));
sam1b = back; sam5b(1:100,1:50) = s;
imagesc(sam5b);
title('sample 5 before');
xticks({}); yticks({});
subplot(5,2,10);
sam5a = NonParamSampling(sample5(1:100,1:50),[100,100],[50,40],1,0);
imagesc(sam5a);
title('sample 5 after');
xticks({}); yticks({});