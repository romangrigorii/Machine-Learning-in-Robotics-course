function out = NNcodereg1(input,labels,levels,plott)
[a,b] = size(input);
in = abs(max(labels)-min(labels)); % calculating the range of the labels for good initiation
levels = [levels,1];
a = {}; a{1} = input(1,:)'; b = {}; W = {}; s = {}; z = {};
L = length(levels);
Li = length(input);
%Forward propogating initial values
for i = 1:L
    b{i} = in*(rand(length(levels(i)),1));
    W{i} = in*(rand(levels(i),length(a{i})));
    z{i} = W{i}*a{i} + b{i};
    a{i+1} = sigmoidd(z{i},0);
end
% Back propagation
gradCw = {}; gradCb = {};
C = [];
nu = Li/L;
lim = 400; % number of epochs
for p = 1:lim
    Ccur = [];
    for j = 1:length(input)
        a{1} = input(j,:)';
        for k = 1:100 % number of reiterations of same input
            s{L} = (a{L+1}-labels(j)).*sigmoidd(z{L},1);
            u = L-1;
            while u > 0
                s{u} = (W{u+1}'*s{u+1}).*sigmoidd(z{u},1);
                u = u - 1;
            end
            for i = 1:L
                gradCb{i} = s{i}; %appying equation 1-2
                gradCw{i} = s{i}*a{i}'; % applying equations 3-4
            end
            for i = 1:L
                W{i} = W{i} - .005*nu*gradCw{i}; % updating weights through gradient descent
                b{i} = b{i} - .005*nu*gradCb{i}; % updating offsets through gradient descent
            end
            for i = 1:L % forward propagation the newly applied weights
                z{i} = W{i}*a{i} + b{i};
                a{i+1} = sigmoidd(z{i},0);
            end
        end
        err = [];
        for j = 1:length(input)
            err(j) = classifyNN(W,b,input(j,:)') - labels(j);
        end
        Ccur = [Ccur,mean(abs(err))];
    end
    %fprintf('percent done: %d training classification error: %f\n',round(100*p/lim),Ccur(end));
    %fprintf('percent: %d \n',round(100*p/lim));
    C = [C,mean(Ccur)];
end
if plott == 1
    figure
    plot(C);
    xlabel('epoch');
    ylabel('error');
    title('Classification error as function of epochs on data set 1');
end
out{1} = W;
out{2} = b;
end