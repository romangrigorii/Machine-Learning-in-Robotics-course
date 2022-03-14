input = [];
output = [];
p = 6;
for i = 1:2^p-1
    n = i;
    ii = p-1;
    while ii >= 0
        if n>=2^ii;
            input(i,ii+1) = 1;
            n = n - 2^ii;
        else
            input(i,ii+1) = 0;
        end
        ii = ii - 1;
    end
    output(i) = xor(input(i,1),input(i,5));
    for ii = 2:p-1
        output(i) = xor(output(i),input(i,ii));
    end
end
levels = [5];
validcount = 0;
validacc = 0;
traincount = 0;
trainacc = 0;
plott = 1;
for h = 1:1
    trainin = [];
    trainout = [];
    validin = [];
    validout = [];
    rat = .8;
    for i = 1:1:2^p-1
        if rand(1)<=rat
            trainin = [trainin;input(i,:)];
            trainout = [trainout;output(i)];
        else
            validin = [validin;input(i,:)];
            validout = [validout;output(i)];
        end
    end
    cc = NNcodereg1(trainin,trainout,levels,plott);
    y = [];
    for i = 1:length(validout)
        y(i) = classifyNN(cc{1},cc{2},validin(i,:)');
    end
    %fprintf('validation accuracy: %f\n',sum((round(y)-validout')==0)/length(validout));
    
    yt = [];
    for i = 1:length(trainout)
        yt(i) = classifyNN(cc{1},cc{2},trainin(i,:)');
    end
    %fprintf('train accuracy: %f\n',sum((round(yt)-trainout')==0)/length(trainout));
    validcount = validcount + length(validout);
    traincount = traincount + length(trainout);
    validacc = validacc + sum((round(y)-validout')==0);
    trainacc = trainacc + sum((round(yt)-trainout')==0);
    plott = 0;
end
figure
hold on
plot(trainout);
plot(yt)
xlabel('label');
ylabel('value of label');
title('Expected training labels vs NN classified labels on training data')
legend('training labels','output labels of NN model');
hold off
figure
hold on
plot(validout);
plot(y)
xlabel('label');
ylabel('value of label');
title('Validation data true label versus validation data classified label')
legend('validation labels','output labels of NN model');
hold off
fprintf('Training accuracy: %d %%\n', round(100*(trainacc/traincount)));
fprintf('Validation accuracy: %d %%\n', round(100*(validacc/validcount)));
