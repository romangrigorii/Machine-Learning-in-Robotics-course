function vectomat = vectomat(vec,columns)
% vectomat() takes a vector of size 1xN and copies the column entries to
% produce a matrix of size columns x N
[c,d] = size(vec);
if c == 1
    r = d;
else
    r = c;
end
mat = ones(r,columns);
for i = 1:r
     mat(i,:) = mat(i,:)*vec(i);
end
    vectomat = mat;
end