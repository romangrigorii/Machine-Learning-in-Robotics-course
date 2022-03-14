function out = gauss2d(m1,m2,s1,s2,X,Y)
% returns a 2D gaussian weighted window of specified variance, mean and
% window size
    out = zeros(length(X),length(Y));
    for x = 1:length(X)
        for y = 1:length(Y)
            out(x,y) = exp(-(((X(x)-m1)^2)/s1 + ((Y(y)-m2)^2)/s2));
        end
    end
end