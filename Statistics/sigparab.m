function [err1,cov]=sigparab(x,y,sigx,sigy,fitfun,a,stepsize)

[dum, nparm] = size(a);

for j=1:nparm

    da(j) = stepsize(j);

    a1=a;
    a1(j)=a1(j)+da(j);
   
     a2= a;
     a3= a1;
     for k=1:nparm
          da(k) = stepsize(k);
         a2(k)=a2(k)+da(k);
         a3(k)=a3(k)+da(k); 
          dCHI2da(j,k)=0.5*(calcchi2(x,y,sigx,sigy,fitfun,a)-calcchi2(x,y,sigx,sigy,fitfun,a1)-calcchi2(x,y,sigx,sigy,fitfun,a2)+calcchi2(x,y,sigx,sigy,fitfun,a3))/da(j)/da(k);
     end
 end
errc=inv(dCHI2da);
cov=errc;
for j=1:nparm
     err1(j) = sqrt(abs(errc(j,j)));
end