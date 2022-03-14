function out = sigmoidd(x,d)
    out = 1./(ones(length(x),1)+exp(-x));
     if d == 1
        out = out.*(ones(length(out),1) - out);
     end
end