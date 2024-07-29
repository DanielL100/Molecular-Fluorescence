function plotResiduals(x, y, dx, dy, fit, file_name, xlab, ylab, ttl, fun, linewidth, show)
if nargin < 11
    linewidth = 1.7;
    show = false;
else if (nargin == 11)
    show = false;
end
end
f = figure( 'Name', 'residuals' );
if ~show
    f.WindowState = 'minimized';
end
coff = coeffvalues(fit);
ynew = y - feval(fun, x, coff);
errorbar(x, ynew, dy/2, dy/2, dx/2, dx/2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4,'Color','blue');
hold on
yline(0, 'Color', 'red', 'LineWidth', linewidth)
xlabel( xlab, 'Interpreter', 'Latex', 'FontSize', 14 );
ylabel( ylab, 'Interpreter', 'Latex', 'FontSize', 14 );
title(ttl, 'FontSize', 14, 'Interpreter', 'Latex');
saveas(gcf,file_name + ".png")