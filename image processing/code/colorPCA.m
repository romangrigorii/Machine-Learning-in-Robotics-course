function out = colorPCA(I)
% appliesPCA on a three channel image
X = reshape(I,size(I,1)*size(I,2),3);
coeff = pca(X);
Itransformed = X*coeff;
out{1} = reshape(Itransformed(:,1),size(I,1),size(I,2));
out{2} = reshape(Itransformed(:,2),size(I,1),size(I,2));
out{3} = reshape(Itransformed(:,3),size(I,1),size(I,2));
end