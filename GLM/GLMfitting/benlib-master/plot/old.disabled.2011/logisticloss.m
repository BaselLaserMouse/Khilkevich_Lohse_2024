function loss = logisticloss(x,y,parms)

yp = logistic(x,parms(1),parms(2),parms(3),parms(4));

loss = nansum((y-yp).^2);