function out = PCAroman(mat,dimleft)
% mat = original image
% dimleft = the number of dimensions to be kept after PCA projection
M = {}; V = {}; E = {}; R = {};MAT = {};
for c = 1:length(mat)
    M{c} = vectomat(mean(mat{c}),length(mat{c}))'; % matlab PCA removes the mean pixel values which we need to retain to make sense of the projection of variances
    [V{c},E{c}] = pca(mat{c} - M{c});
    R{c} = E{c}(:,1:dimleft)*V{c}(:,1:dimleft)' + M{c};
    MAT{c} = mat{c}*V{c}(:,1:dimleft);
end
out{1} = M; out{2} = V; out{3} = E; out{4} = R; out{5} = MAT;
end