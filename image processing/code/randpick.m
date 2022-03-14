function out = randpick(mat,D)
    % Given matrix of pixel values mat and the size of a seed image D,
    % randpick returns a position vector corresponding to the corner of the
    % subsample image ampled randomly from mat
    [a,b] = size(mat);
    aa = floor(rand(1)*(a - D(1)));
    bb = floor(rand(1)*(b - D(2)));
    out = [aa,bb];
end