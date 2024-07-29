function f = UP(x, a)
f = 0.5*(a(1)+a(2).*sqrt(x.^2+a(3))+sqrt(a(4)+(a(1)-a(2).*sqrt(x.^2+a(3))).^2))