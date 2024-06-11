function y = logistic(t,a,m,n,tau)

y = a * (1+m.*exp(-t./tau)) ./ (1+n.*exp(-t./tau));