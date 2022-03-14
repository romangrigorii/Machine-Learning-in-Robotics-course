function out = vectomat2(vec)
% vectomat2() takes a vector of size 1xN and produces a matrix of size NxN
% by creating topogaphical sqaures of values on the matrix latice. i.e.
% given [1 2 3] the result is [[1 2 3],[2 2 3],[3 3 3]]
L = length(vec);
out = zeros(L,L);
for l = 1:length(vec)
    out(l,:) = [vec(1:l-1),vec(l)*ones(1,L-l+1)];
end
end