function out = dist(MAT,mat,cord,D,type)
% MAT = original matrix of pixel values
% mat = patch being placed into the image
% cord = the corrdinates of the patch location
% D = the size of the overlap
% type = the type of overlap necessary to compute the distance for
% dist computes the distance between the overlapping region of two patches
[a,b] = size(mat);
switch type
    case 1
        d = sqrt(sum(sum((MAT(cord(1)-D+1:cord(1),cord(2)-b+1:cord(2)) - mat(1:D,:)).^2)))/(D*b);
    case 2
        d = sqrt(sum(sum((MAT(cord(1)-a+1:cord(1),cord(2)-D+1:cord(2)) - mat(:,1:D)).^2)))/(D*a);
    case 3
        d = sqrt(sum(sum((MAT(cord(1)-D+1:cord(1),cord(2)-D+1:cord(2)-D+b) - mat(1:D,:)).^2)) + sum(sum((MAT(cord(1)+1:cord(1)-D+a,cord(2)-D+1:cord(2)) - mat(D+1:end,1:D)).^2)))/(a*b - (a-D)*(b-D));
      
end
out = d;
end