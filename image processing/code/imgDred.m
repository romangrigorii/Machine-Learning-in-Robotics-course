function out = imgDred(img,D)
DI = [0,0];
[DI(1),DI(2),~] = size(img);
A = D(1);
B = D(2);
AB = A*B;
Z = zeros(DI(1)-D(1)-1,DI(2)-D(2)-1,AB);
img = colorPCA(img);
img = img{1};
for a = 1:DI(1)-D(1)-1
    for b = 1:DI(2)-D(2)-1
        Z(a,b,1:AB) = reshape(img(a:a+D(1)-1,b:b+D(2)-1),AB,1);
    end
    a
end
out = Z;
end