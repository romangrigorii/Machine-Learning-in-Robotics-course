function out = placepatch(MAT,mat,cord,d,type,feather)
    % MAT  = the matrix of pixel values onto which a patch will be placed
    % mat = the patch to be placed on the matrix
    % cord = coordinates of the patch position
    % d = size of overap
    % type = type of overlap. There are three posible overlap
    % possibilities, each required their own specific routine
    % feather = determines whether feathering is applied or not
    % Given the above variables, placepatch() places a patch of pixel
    % values in the canvas and returns the new matrix of pixel values
    out = MAT;
    [a,b] = size(mat);
    w = linspace(0,1,d+2);
    w = w(2:end-1);
    switch type
        case 1
            if feather
                out(cord(1)+1:cord(1)-d+a,cord(2)- b+1:cord(2)) = mat(d+1:end,:);
                out(cord(1)-d+1:cord(1),cord(2)- b+1:cord(2)) = mat(1:d,:).*vectomat(w,b) + out(cord(1)-d+1:cord(1),cord(2)- b+1:cord(2)).*vectomat(flip(w),b); 
            else
                out(cord(1)+1-d:cord(1)-d+a,cord(2)- b+1:cord(2)) = mat;
            end
        case 2
            if feather
                out(cord(1)-a+1:cord(1),cord(2)+1:cord(2)-d+b) = mat(:,d+1:end);
                out(cord(1)-a+1:cord(1),cord(2)-d+1:cord(2)) = mat(:,1:d).*vectomat(w,b)' + out(cord(1)-a+1:cord(1),cord(2)-d+1:cord(2)).*vectomat(flip(w),b)';
            else
                out(cord(1)-a+1:cord(1),cord(2)+1-d:cord(2)-d+b) = mat;
            end
        case 3
            if feather
                out(cord(1)+1:cord(1)-d+a,cord(2)+1:cord(2)-d+b) = mat(d+1:end,d+1:end);
                out(cord(1)-d+1:cord(1),cord(2)+1:cord(2)-d+b) = mat(1:d,end-(b-d)+1:end).*vectomat(w,b-d)+ out(cord(1)-d+1:cord(1),cord(2)+1:cord(2)-d+b).*vectomat(flip(w),b-d);
                out(cord(1)+1:cord(1)-d+a,cord(2)-d+1:cord(2)) = mat(end-(a-d)+1:end,1:d).*vectomat(w,a-d)'+ out(cord(1)+1:cord(1)-d+a,cord(2)-d+1:cord(2)).*vectomat(flip(w),a-d)';
                out(cord(1)-d+1:cord(1),cord(2)-d+1:cord(2)) = mat(1:d,1:d).*vectomat2(w) + out(cord(1)-d+1:cord(1),cord(2)-d+1:cord(2)).*vectomat2(flip(w));
            else
                out(cord(1)-d+1:cord(1)-d+a,cord(2)-d+1:cord(2)-d+b) = mat;
            end
    end
end