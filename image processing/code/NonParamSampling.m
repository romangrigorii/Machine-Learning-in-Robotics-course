function out = NonParamSampling(orig,orig2,finalsize,windsize,method,overlap,e,feather)
% orig = original image in the form of a matrix with pixel values
% orig2 = the original image representated by three color channels as a
% cell with each cell entry responsible for a specific channel
% finalsize = vector specifying the size of final image
% windsize = the size of windows which are used for patch based sampling
% method = 1: pixel based  2: patch based 
% overlap = the overlap in patch based synthesis
% e = the stopping crtierion for optimal neighborhood search
% feather = 1: feathering applied 0: feathering not applied
% 
% Given the above variables, NonParamSampling() returns a sythesized
% texture image.
out = -1*ones(finalsize);
[a,b] = size(orig);
out(1:a,1:b) = orig;
w = ones(windsize);
switch method
    case 1
        l = 0;
        while l<(finalsize(2)-b)
            for xx = 1:windsize(1)
                mat = out(xx:(xx+windsize(1)-1),(b-windsize(2)+1+l):(b+l));
                smin = windsize(1)*windsize(2)*255;
                loc = [1,1];
                for x = 1:(a-windsize(1))
                    for y = 1:(b-windsize(2)-1)
                        s = sum(sum(abs(mat - orig(x:x+windsize(1)-1,y:y+windsize(2)-1))));
                        if smin > s
                            smin = s;
                            loc = [x,y];
                        end
                    end
                end
                out(xx,b+1+l) = orig(loc(1),loc(2)+windsize(2));
            end
            for xx = windsize(1):a
                mat = out((xx-windsize(1)+1):xx,(b-windsize(2)+1+l):(b+l));
                smin = windsize(1)*windsize(2)*255;
                loc = [1,1];
                for x = 1:(a-windsize(1))
                    for y = 1:(b-windsize(2)-1)
                        s = sum(sum(abs(mat - orig(x+1:x+windsize(1),y+1:y+windsize(2)))));
                        if smin > s
                            smin = s;
                            loc = [x,y];
                        end
                    end
                end
                out(xx,b+1+l) = orig(loc(1)+windsize(1)-1,loc(2)+windsize(2));
            end
            l = l+1;
        end
        l = 0;
        while l<(finalsize(1)-a)
            for yy = 1:windsize(1)
                mat = out((a-windsize(1)+1+l):(a+l),yy:yy+windsize(2)-1);
                smin = windsize(1)*windsize(2)*255;
                loc = [1,1];
                for x = 1:(a-windsize(1)-1)
                    for y = 1:(b-windsize(2))
                        s = sum(sum(abs(mat - orig(x:x+windsize(1)-1,y:y+windsize(2)-1))));
                        if smin > s
                            smin = s;
                            loc = [x,y];
                        end
                    end
                end
                out(a+l+1,yy) = orig(loc(1)+windsize(1),loc(2));
            end
            for yy = windsize(2):finalsize(2)
                mat = out((a-windsize(1)+1+l):(a+l),(yy-windsize(2)+1):yy);
                smin = windsize(1)*windsize(2)*255;
                loc = [1,1];
                for x = 1:(a-windsize(1)-1)
                    for y = 1:(b-windsize(2))
                        s = sum(sum(abs(mat - orig(x:x+windsize(1)-1,y:y+windsize(2)-1))));
                        if smin > s
                            smin = s;
                            loc = [x,y];
                        end
                    end
                end
                out(a+l+1,yy) = orig(loc(1)+windsize(1),loc(2)+windsize(2));
            end
            l = l+1;
        end
    case 2
        out = zeros(finalsize + 3*windsize);
        out2 = zeros(finalsize(1) + 3*windsize(1),finalsize(1) + 3*windsize(1),3);
        m = randpick(orig,windsize);
        out(windsize(1)+1:2*windsize(1),windsize(2)+1:2*windsize(2)) =  orig(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2));
        for j = 1:3
              out2(windsize(1)+1:2*windsize(1),windsize(2)+1:2*windsize(2),j) =  orig2(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2),j);
        end
        loc = 2*windsize;
        flag = 1;
        while loc(1)< finalsize(1) + 2*windsize(1)
            d = 100; g = 1;
            while d > e 
                m = randpick(orig,windsize);
                d = dist(out,orig(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2)),loc,overlap,flag);
            end
            out = placepatch(out,orig(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2)),loc,overlap,flag,feather);
            for j = 1:3
                out2(:,:,j) = placepatch(out2(:,:,j),orig2(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2),j),loc,overlap,flag,feather);
            end            
            loc(1) = loc(1)-overlap+windsize(1);
            loc
        end
        loc(1) = 2*windsize(1);
        e = e/2;
        while loc(2)<finalsize(2)+2*windsize(2)
            d = 100;
            flag = 2; g = 1; E = e;
            while d > e
                m = randpick(orig,windsize);
                d = dist(out,orig(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2)),loc,overlap,flag);
                g = g + 1;
                if g > 100
                    g = 1;
                    e = e*1.01;
                end
            end
            e = E;
            out = placepatch(out,orig(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2)),loc,overlap,flag,feather);
            for j = 1:3
                out2(:,:,j) = placepatch(out2(:,:,j),orig2(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2),j),loc,overlap,flag,feather);
            end
            flag = 3;
            while loc(1)< finalsize(1) + 2*windsize(1)
                d = 100;g = 1; E = e;
                while d > e
                    m = randpick(orig,windsize);
                    d = dist(out,orig(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2)),loc,overlap,flag);
                    g = g + 1;
                    if g > 100
                        g = 1;
                        e = e*1.01;
                    end
                end
                e = E;
                out = placepatch(out,orig(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2)),loc,overlap,flag,feather);
                for j = 1:3
                    out2(:,:,j) = placepatch(out2(:,:,j),orig2(m(1)+1:m(1)+windsize(1),m(2)+1:m(2)+windsize(2),j),loc,overlap,flag,feather);
                end                
                loc(1) = loc(1)-overlap+windsize(1);
                loc
            end
            loc(1) = 2*windsize(1);
            loc(2) = loc(2)-overlap+windsize(2);
        end
        h = out(windsize(1)+1:windsize(1)+finalsize(1),windsize(2)+1:windsize(2)+finalsize(2));
        out = {};
        out{1} = h;
        out{2} = out2(windsize(1)+1:windsize(1)+finalsize(1),windsize(2)+1:windsize(2)+finalsize(2),:);
    case 3
        out = zeros(finalsize + 3*windsize);
        out(windsize(1)+1:2*windsize(1),windsize(2)+1:2*windsize(2)) =  randpick(orig,windsize);
        loc = 2*windsize;
        flag = 1;
        while loc(1)< finalsize(1) + 2*windsize(1)
            d = 100;
            while d > e
                m = randpick(orig,windsize);
                d = dist(out,m,loc,overlap,flag);
            end
            out = placepatch(out,m,loc,overlap,flag,feather);
            loc(1) = loc(1)-overlap+windsize(1);
            loc
        end
        loc(1) = 2*windsize(1);
        while loc(2)<finalsize(2)+2*windsize(2)
            d = 100;
            flag = 2; g = 1;
            while d > e
                m = randpick(orig,windsize);
                d = dist(out,m,loc,overlap,flag);
                g = g + 1;
                if g > 100
                    g = 1;
                    e = e*1.1
                end
            end
            out = placepatch(out,m,loc,overlap,flag,feather);
            flag = 3;
            while loc(1)< finalsize(1) + 2*windsize(1)
                d = 100;g = 1; E = e;
                while d > e
                    m = randpick(orig,windsize);
                    d = dist(out,m,loc,overlap,flag);
                    g = g + 1;
                    if g > 100
                        g = 1;
                        e = e*1.1;
                    end
                end
                e = E;
                out = placepatch(out,m,loc,overlap,flag,feather);
                loc(1) = loc(1)-overlap+windsize(1);
                loc
            end
            loc(1) = 2*windsize(1);
            loc(2) = loc(2)-overlap+windsize(2);
        end
        out = out(windsize(1)+1:windsize(1)+finalsize(1),windsize(2)+1:windsize(2)+finalsize(2));
end
end