function uncertainty = calc_uncertainty(x, y, sigx, sigy, fitfun, a)
stepsize = abs(a)*0.01+eps ; % the amount each parameter will be varied by in each iteration
[aerr,cov] = sigparab(x,y,sigx,sigy,fitfun,a,stepsize);
uncertainty = aerr;