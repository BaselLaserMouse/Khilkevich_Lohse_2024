function kernel = getkernelandfits(fitfunc, X_fit, y_fit, sigpower_fit, predfunc, X_pred, y_pred, sigpower_pred)
% function kernel = getkernelandfits(fitfunc, X_fit, y_fit, sigpower_fit, predfunc, X_pred, y_pred, sigpower_pred)

kernel = feval(fitfunc, X_fit, y_fit);

kernel.fit.y_hat = feval(predfunc, X_fit, kernel);
[kernel.fit.sp_exp, kernel.fit.cc] = testfit2(y_fit, kernel.fit.y_hat, sigpower_fit);

kernel.pred.y_hat = feval(predfunc, X_pred, kernel);
[kernel.pred.sp_exp, kernel.pred.cc] = testfit2(y_pred, kernel.pred.y_hat, sigpower_pred);
