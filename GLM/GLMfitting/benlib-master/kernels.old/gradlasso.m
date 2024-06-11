function [E dEdb] = gradlasso(v,x,y,lambda,pred)%,mu,J)
% function [E dEdb] = gradlasso(v,x,y,lambda,pred)%,mu,J)
%
% NH 2013
% objective function and gradient for lasso.

b = v(1:(end-1))';
b0 = v(end);
N = size(x,2);

yhat = b*x + b0;
r = (y-yhat);
Ed = sum(r.^2)./(2*N);

if pred
    E = Ed;
else
    Ep = lambda*sum(abs(b));% + mu*b'*J'*J*b;
    E = Ed + Ep;
end

if nargout>1
    if pred
        dEdb = yhat;
    else
        dEdb = (r*x')./(-N) + lambda*sign(b);%
        dEdb0 = sum(r)./(-N);
        dEdb = [dEdb dEdb0]';
    end
end
