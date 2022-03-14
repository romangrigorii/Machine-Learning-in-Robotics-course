%% THE MAIN FILE %%

x = input('Press 1 if you want to observe pixel based synthesis results 0 to skip\n');
if x == 1
    fprintf('Expect ~3 minute compuation\n');
    img = double(rgb2gray(imread('2Dsamples1\sample1.jpg')));
    sample1 = double(img);
    sample1 = sample1(1:512,1:512);
    img = double(rgb2gray(imread('2Dsamples1\sample2.jpg')));
    sample2 = double(img);
    sample2 = sample2(1:512,1:512);
    img = double(rgb2gray(imread('2Dsamples1\sample3.jpg')));
    sample3 = double(img);
    sample3 = sample3(1:512,1:512);
    img = double(rgb2gray(imread('2Dsamples1\sample4.jpg')));
    sample4 = double(img);
    sample4 = sample4(1:512,1:512);
    img = double(rgb2gray(imread('2Dsamples1\sample5.jpg')));
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
    sam1a = NonParamSampling(sample1(1:100,1:50),2,[100,100],[50,40],1,0,1,1);
    imagesc(sam1a);
    title('sample 1 after');
    xticks({}); yticks({});
    fprintf('1/5 images computed\n');
    
    subplot(5,2,3);
    back = -1*ones(100,100);
    s = sample2(1:100,1:50);
    s = 255*(s - min(min(s)))/(max(max(s)) - min(min(s)));
    sam2b = back; sam2b(1:100,1:50) = s;
    imagesc(sam2b);
    title('sample 2 before');
    xticks({}); yticks({});
    subplot(5,2,4);
    sam2a = NonParamSampling(sample2(1:100,1:50),2,[100,100],[50,40],1,0,1,1);
    imagesc(sam2a);
    title('sample 2 after');
    xticks({}); yticks({});
    fprintf('2/5 images computed\n');
    
    
    subplot(5,2,5);
    back = -1*ones(100,100);
    s = sample3(1:100,1:50);
    s = 255*(s - min(min(s)))/(max(max(s)) - min(min(s)));
    sam3b = back; sam3b(1:100,1:50) = s;
    imagesc(sam3b);
    title('sample 3 before');
    xticks({}); yticks({});
    subplot(5,2,6);
    sam3a = NonParamSampling(sample3(1:100,1:50),2,[100,100],[50,40],1,0,1,1);
    imagesc(sam3a);
    title('sample 3 after');
    xticks({}); yticks({});
    fprintf('3/5 images computed\n');
    
    subplot(5,2,7);
    back = -1*ones(100,100);
    s = sample4(1:100,1:50);
    s = 255*(s - min(min(s)))/(max(max(s)) - min(min(s)));
    sam4b = back; sam4b(1:100,1:50) = s;
    imagesc(sam4b);
    title('sample 4 before');
    xticks({}); yticks({});
    subplot(5,2,8);
    sam4a = NonParamSampling(sample4(1:100,1:50),2,[100,100],[50,40],1,0,1,1);
    imagesc(sam4a);
    title('sample 4 after');
    xticks({}); yticks({});
    fprintf('4/5 images computed\n');
    
    subplot(5,2,9);
    back = -1*ones(100,100);
    s = sample5(1:100,1:50);
    s = 255*(s - min(min(s)))/(max(max(s)) - min(min(s)));
    sam5b = back; sam5b(1:100,1:50) = s;
    imagesc(sam5b);
    title('sample 5 before');
    xticks({}); yticks({});
    subplot(5,2,10);
    sam5a = NonParamSampling(sample5(1:100,1:50),2,[100,100],[50,40],1,0,1,1);
    imagesc(sam5a);
    title('sample 5 after');
    xticks({}); yticks({});
    fprintf('5/5 images computed\n');
    colormap gray
else
    x = input('Press 1 if you want to observe patch based synthesis results 0 to skip\n');
    if x == 1
        fprintf('Expect ~3 minute computation\n');
        %% reading in images
        sample1f = zeros(512,512,3);
        sample2f = zeros(512,512,3);
        sample3f = zeros(512,512,3);
        sample4f = zeros(512,512,3);
        sample5f = zeros(512,512,3);
        img = double(imread('2Dsamples2\sample1.jpg'));
        for i = 1:3
            sample1f(:,:,i) = squeeze(img(1:512,1:512,i));
        end
        img = double(imread('2Dsamples2\sample2.jpg'));
        for i = 1:3
            sample2f(:,:,i) = squeeze(img(1:512,1:512,i));
        end
        img = double(imread('2Dsamples2\sample3.jpg'));
        for i = 1:3
            sample3f(:,:,i) = squeeze(img(1:512,1:512,i));
        end
        img = double(imread('2Dsamples2\sample4.jpg'));
        for i = 1:3
            sample4f(:,:,i) = squeeze(img(1:512,1:512,i));
        end
        img = double(imread('2Dsamples2\sample5.jpg'));
        for i = 1:3
            sample5f(:,:,i) = squeeze(img(1:512,1:512,i));
        end
        
        img = double(rgb2gray(imread('2Dsamples2\sample1.jpg')));
        sample1 = double(img);
        sample1 = sample1(1:512,1:512);
        img = double(rgb2gray(imread('2Dsamples2\sample2.jpg')));
        sample2 = double(img);
        sample2 = sample2(1:512,1:512);
        img = double(rgb2gray(imread('2Dsamples2\sample3.jpg')));
        sample3 = double(img);
        sample3 = sample3(1:512,1:512);
        img = double(rgb2gray(imread('2Dsamples2\sample4.jpg')));
        sample4 = double(img);
        sample4 = sample4(1:512,1:512);
        img = double(rgb2gray(imread('2Dsamples2\sample5.jpg')));
        sample5 = double(img);
        sample5 = sample5(1:512,1:512);
        
        %% computing and plotting results
        
        im = {};
        figure
        subplot(1,3,1)
        imshow(uint8(sample1f));
        title('original');
        ylabel('sample 1');
        xticks({}); yticks({});
        subplot(1,3,2)
        out = NonParamSampling(sample1,sample1f,[512,512],[100,100],2,50,1,0);
        im{1,1,1} = out{1}; im{1,1,2} = out{2};
        imshow(uint8(im{1,1,2}));
        title('no feathering');
        xticks({}); yticks({});
        subplot(1,3,3)
        out = NonParamSampling(sample1,sample1f,[512,512],[100,100],2,20,1.5,1);
        im{1,2,1} = out{1}; im{1,2,2} = out{2};
        imshow(uint8(im{1,2,2}));
        title('with feathering');
        xticks({}); yticks({});
        
        subplot(1,3,1)
        imshow(uint8(sample2f));
        title('original');
        ylabel('sample 2');
        xticks({}); yticks({});
        subplot(1,3,2)
        out = NonParamSampling(sample2,sample2f,[512,512],[100,100],2,50,1,0);
        im{2,1,1} = out{1}; im{2,1,2} = out{2};
        imshow(uint8(im{2,1,2}));
        title('no feathering');
        xticks({}); yticks({});
        subplot(1,3,3)
        out = NonParamSampling(sample2,sample2f,[512,512],[100,100],2,20,1,1);
        im{2,2,1} = out{1}; im{2,2,2} = out{2};
        imshow(uint8(im{2,2,2}));
        title('with feathering');
        xticks({}); yticks({});
        
        subplot(1,3,1)
        imshow(uint8(sample3f));
        title('original');
        ylabel('sample 3');
        xticks({}); yticks({});
        subplot(1,3,2)
        out = NonParamSampling(sample3,sample3f,[512,512],[100,100],2,50,.5,0);
        im{3,1,1} = out{1}; im{3,1,2} = out{2};
        imshow(uint8(im{3,1,2}));
        title('no feathering');
        xticks({}); yticks({});
        subplot(1,3,3)
        out = NonParamSampling(sample3,sample3f,[512,512],[100,100],2,20,.5,1);
        im{3,2,1} = out{1}; im{3,2,2} = out{2};
        imshow(uint8(im{3,2,2}));
        title('with feathering');
        xticks({}); yticks({});
        
        
        subplot(1,3,1)
        imshow(uint8(sample4f));
        title('original');
        ylabel('sample 4');
        xticks({}); yticks({});
        subplot(1,3,2)
        out = NonParamSampling(sample4,sample4f,[512,512],[100,100],2,50,.5,0);
        im{4,1,1} = out{1}; im{4,1,2} = out{2};
        imshow(uint8(im{4,1,2}));
        title('no feathering');
        xticks({}); yticks({});
        subplot(1,3,3)
        out = NonParamSampling(sample4,sample4f,[512,512],[100,100],2,50,.5,1);
        im{4,2,1} = out{1}; im{4,2,2} = out{2};
        imshow(uint8(im{4,2,2}));
        title('with feathering');
        xticks({}); yticks({});
        
        subplot(1,3,1)
        imshow(uint8(sample5f));
        title('original');
        ylabel('sample 5');
        xticks({}); yticks({});
        subplot(1,3,2)
        out = NonParamSampling(sample5,sample5f,[512,512],[100,100],2,50,1,0);
        im{5,1,1} = out{1}; im{5,1,2} = out{2};
        imshow(uint8(im{5,1,2}));
        title('no feathering');
        xticks({}); yticks({});
        subplot(1,3,3)
        out = NonParamSampling(sample5,sample5f,[512,512],[100,100],2,50,.7,1);
        im{5,2,1} = out{1}; im{5,2,2} = out{2};
        imshow(uint8(im{5,2,2}));
        title('with feathering');
        xticks({}); yticks({});
    else
        x = input('Press 1 if you want to observe PCA decomposition of the image in the folder \PCA\nNote you can place your own image there to observe the results\n');
        if x == 1
            x = input('Enter the number of dimensions out of 1024 you wish to see retained in PCA decomposition\nNote that the number must be in the set (binary multiples) {1,2,4,8,16,32...1024}\n');
            sample = double(imread('PCA\image.jpg'));
            imshow(uint8(imagePCA(sample(1:512,1:512,:),[32,32],x,0)));
        end
    end
end
