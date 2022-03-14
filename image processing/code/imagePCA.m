function out = imagePCA(img,D,dim,r)
% img = original image in the form of pixel matrix 
% D = the dimensions of a sampled region
% dim = the number of dimensions retained in the final image
% r = specifies whther the output should be only the PCA output components
% (1) or the image that is put back together after the dimensionality has
% been rediced (2)
Z = {};
DI = [0,0];
[DI(1),DI(2),~] = size(img);
A = (DI(1)/D(1));
B = (DI(2)/D(2));
AB = A*B;
for a = 1:D(1)
    for b = 1:D(2)
        for i = 1:3
            Z{i}(a,b,1:AB) = reshape(img((a-1)*A+1:a*A,(b-1)*B+1:b*B,i),AB,1);
        end
    end
end

encodedZ = {};
for a = 1:D(1)
    for b = 1:D(2)
        for i = 1:3
            encodedZ{i}((a-1)*D(1) + b,1:AB) = Z{i}(a,b,:);
        end
    end
end
redDZ = PCAroman(encodedZ,dim);
if r == 1
    out = redDZ{5};
else
    redDZi = redDZ{4};
    decodedZ = {};
    for a = 1:D(1)
        for b = 1:D(2)
            for i = 1:3
                decodedZ{i}(a,b,1:AB) = redDZi{i}((a-1)*D(1) + b,1:AB);
            end
        end
    end
    final = zeros(size(img));
    for a = 1:D(1)
        for b = 1:D(2)
            for i = 1:3
                final((a-1)*A+1:a*A,(b-1)*B+1:b*B,i) = reshape(decodedZ{i}(a,b,:),A,B);
            end
        end
    end
    out = final;
end
end