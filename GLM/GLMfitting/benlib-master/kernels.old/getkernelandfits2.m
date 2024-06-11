function kernel = getkernelandfits2(fitfunc, predfunc, data, fit, pred)
% function kernel = getkernelandfits2(fitfunc, predfunc, data, fit, pred)

kernel = feval(fitfunc, data.X_fht(:,:,fit.idx), data.y_t(fit.idx));
kernel.y_hat = feval(predfunc, data.X_fht, kernel);

[kernel.fit.sp_exp, kernel.fit.cc] = testfit2(data.y_t(fit.idx), kernel.y_hat(fit.idx), fit.sigpower);
[kernel.pred.sp_exp, kernel.pred.cc] = testfit2(data.y_t(pred.idx), kernel.y_hat(pred.idx), pred.sigpower);

