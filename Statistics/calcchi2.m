function chi2 = calcchi2(x,y,sigx,sigy,fitfun,a)

%chi2 = sum( ((y-feval(fitfun,x,a)) ./sig).^2);
xup = x + sigx;
xdwn = x - sigx;
chi2 = sum( ((y-feval(fitfun,x,a)).^2)./(sigy.^2 + ((feval(fitfun,xup,a) - feval(fitfun,xdwn,a))./2).^2) );