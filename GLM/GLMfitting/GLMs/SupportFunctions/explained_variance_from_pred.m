function rsq = explained_variance_from_pred(y, yhat)

var_y = var(y);
var_resid = var(y - yhat);
rsq = 1 - var_resid / var_y;