function out = classifyNN(W,b,input)
    a{1} = input;
    for i = 1:length(b)
        a{i+1} = sigmoidd(W{i}*a{i} + b{i},0);
    end
    out = a{i+1};
end

