x = 0:.1:10;
input = (1+sin(x'))/2;
output = ((input(:,1)>.5).*(input(:,1)<.9));
levels = [10];
cc = NNcodereg(input,output,levels,1);
y = [];
for i = 1:length(input)
    y = [y,classifyNN(cc{1},cc{2},input(i))];
end
figure
hold on
plot(input);
plot(output);
plot(y);
xlabel('entry');
ylabel('value of entry');
legend('input','output','Classification');
title('classification on data without noise');
hold off
CLASSerror = [];
for i = 1:500
inputv = input+.1*(rand(size(input)));
yv = [];
for i = 1:length(input)
    yv = [yv,classifyNN(cc{1},cc{2},inputv(i))];
end
CLASSerror = [CLASSerror,sum(abs(output-round(yv')))/length(output)];
end
fprintf('NN model is build on data without noise classifying \n validation data with %d %% accuracy \n',round(100*(1-mean(CLASSerror))));

inputv = input+.1*(rand(size(input)));
output = ((input(:,1)>.5).*(input(:,1)<.9));
levels = [10];
cc = NNcodereg(inputv,output,levels,0);
y = [];
for i = 1:length(input)
    y = [y,classifyNN(cc{1},cc{2},inputv(i))];
end
figure
hold on
plot(inputv);
plot(output);
plot(y);
xlabel('entry');
ylabel('value of entry');
legend('input','output','Classification');
title('classification on data with added noise');
hold off
CLASSerror = [];
for i = 1:500
inputv = input+.1*(rand(size(input)));
yv = [];
for i = 1:length(input)
    yv = [yv,classifyNN(cc{1},cc{2},inputv(i))];
end
CLASSerror = [CLASSerror,sum(abs(output-round(yv')))/length(output)];
end
fprintf('NN model build on data with noise classifying \n validation data with noise with %d %% accuracy \n',round(100*(1-mean(CLASSerror))));