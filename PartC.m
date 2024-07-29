%% Find UP and LP states their peaks' wavenumbers
close all
clc

lambda_up = [];
lambda_down = [];
lambda_up_err=  [];
lambda_down_err=  [];

for angle = -20:2:20
    sheet = xlsread(sprintf('../מדידות/Part C/%s.xlsx', string(angle)));
    xdata = sheet(:, 1);
    ydata = sheet(:, 2);
    dxdata = sheet(:, 3);
    dydata = sheet(:, 4);
        
    figure()
    legend()
    hold on
    plot(xdata, ydata)

    lower_bounds = [528 540]
    upper_bounds = [560 570]
    
    lower_range = find(lower_bounds(1) <= xdata & xdata <= lower_bounds(2))
    [y_lower, x_lower] = max(ydata(lower_range))
    lower_max = xdata(lower_range)
    lower_max = lower_max(x_lower)
    plot(lower_max, y_lower, 'Marker', 'O')

    upper_range = find(upper_bounds(1) <= xdata & xdata <= upper_bounds(2))
    [y_upper, x_upper] = max(ydata(upper_range))
    upper_max = xdata(upper_range)
    upper_max = upper_max(x_upper)
    plot(upper_max, y_upper, 'Marker', 'O')
    hold off

    % parabolic fit for each maximum in order to find more precise wavenumber
    range = find(xdata == lower_max) - 50:find(xdata == lower_max) + 50
    x = sheet(range, 1)
    y = sheet(range, 2)
    dx = sheet(range, 3)
    dy = sheet(range, 4)

    figure("Name", string(C))
    hold on
    plot(x,y, 'Marker', 'o')
    grid minor

    [xData, yData] = prepareCurveData( x, y );
    
    % Set up fittype and options.
    ft = fittype( 'a*x^2+b*x+c', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Algorithm = 'Trust-Region';
    opts.Display = 'Off';
    opts.Robust = 'LAR';
    opts.MaxFunEvals = 6000;
    opts.MaxIter = 4000;
    opts.TolFun = 1e-06;
    opts.TolX = 1e-06;
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
    % Plot fit with data.
    h = plot(fitresult);
    set(h,'linewidth',1.7);
    hold off

    legend('hide')
    xlabel('$\lambda[nm]$', 'Interpreter', 'Latex', 'FontSize', 14 )
    ylabel('$Intensity [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 )
    title(sprintf('$Intensity\\: as\\: a\\: function\\: of\\: \\lambda\\: for\\: %s^{\\circ} - lower\\: peak$', string(angle)), 'Interpreter', 'Latex', 'FontSize', 14 )

    path = sprintf('Part C/Parabolic/%s_lower.jpg', string(angle));
    saveas(gcf, path)

    lambda_down(find(angle == -20:2:20)) = -fitresult.b/(2*fitresult.a)
    lambda_down_err(find(angle == -20:2:20)) = (2*fitresult.a*err(1)-fitresult.b*2*err(1))/(4*fitresult.a)


    range = find(xdata == upper_max) - 50:find(xdata == upper_max) + 50

    x = sheet(range, 1)
    y = sheet(range, 2)
    dx = sheet(range, 3)
    dy = sheet(range, 4)

    figure("Name", string(C))
    hold on
    plot(x,y, 'Marker', 'o')
    grid minor

    [xData, yData] = prepareCurveData( x, y );
    
    % Set up fittype and options.
    ft = fittype( 'a*x^2+b*x+c', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Algorithm = 'Trust-Region';
    opts.Display = 'Off';
    opts.Robust = 'LAR';
    opts.MaxFunEvals = 6000;
    opts.MaxIter = 4000;
    opts.TolFun = 1e-06;
    opts.TolX = 1e-06;
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
    % Plot fit with data.
    h = plot(fitresult);
    set(h,'linewidth',1.7);
    hold off

    legend('hide')
    xlabel('$\lambda[nm]$', 'Interpreter', 'Latex', 'FontSize', 14 )
    ylabel('$Intensity [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 )
    title(sprintf('$Intensity\\: as\\: a\\: function\\: of\\: \\lambda\\: for\\: %s^{\\circ} - higher\\: peak$', string(angle)), 'Interpreter', 'Latex', 'FontSize', 14 )

    path = sprintf('Part C/Parabolic/%s_upper.jpg', string(angle));
    saveas(gcf, path)

    lambda_up(find(angle == -20:2:20)) = -fitresult.b/(2*fitresult.a)
    lambda_up_err(find(angle == -20:2:20)) = (2*fitresult.a*err(1)-fitresult.b*2*err(1))/(4*fitresult.a)
end

k_down = 2*pi*sin((-20:2:20)*pi/180)./lambda_down
k_up = 2*pi*sin((-20:2:20)*pi/180)./lambda_up
E_down = 1240.68./lambda_down
E_up = 1240.68./lambda_up
tb = table(k_down'*10^3, E_down', (lambda_down_err.*k_down./lambda_down)'*10^3, (E_down.*lambda_down_err./lambda_down)')
filename = 'Part C/Energy_upper.xlsx';
writetable(tb,filename,'Sheet',1,'Range','A1');
tb = table(k_up'*10^3, E_up', (lambda_up_err.*k_up./lambda_up)'*10^3, (E_up.*lambda_up_err./lambda_up)')
filename = 'Part C/Energy_lower.xlsx';
writetable(tb,filename,'Sheet',1,'Range','A1');


%% fit data to exciton-polariton
% gets data from sheets
sheet = xlsread('Part C/Energy_lower.xlsx');
k_down = sheet(:, 1);
E_down = sheet(:, 2);
d_k_down = sheet(:, 3);
d_E_down = sheet(:, 4);
sheet = xlsread('Part C/Energy_upper.xlsx');
k_up = sheet(:, 1);
E_up = sheet(:, 2);
d_k_up = sheet(:, 3);
d_E_up = sheet(:, 4);

[xData, yData] = prepareCurveData( x, y );
    
% Set up fittype and options.
ft = fittype( '0.5*(a+b*sqrt(x^2+c)-sqrt(d+(a-b*sqrt(x^2+c))^2))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Trust-Region';
opts.Display = 'Off';
opts.Robust = 'LAR';
opts.StartPoint = [2 1.28*10^-1 (pi/0.165)^2 0.5]
opts.Lower = [0 0 0 0]
opts.Upper = [10 Inf Inf 1]
opts.MaxFunEvals = 6000;
opts.MaxIter = 4000;
opts.TolFun = 1e-06;
opts.TolX = 1e-06;

% Fit model to data.
[fitresult_down, gof] = fit( k_down, E_down, ft, opts );

ft = fittype( '0.5*(a+b*sqrt(x^2+c)+sqrt(d+(a-b*sqrt(x^2+c))^2))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Trust-Region';
opts.Display = 'Off';
opts.Robust = 'LAR';
opts.StartPoint = [2 1.28*10^-1 (pi/0.165)^2 0.5]
opts.Lower = [0 0 0 0]
opts.Upper = [10 Inf Inf 1]
opts.MaxFunEvals = 6000;
opts.MaxIter = 4000;
opts.TolFun = 1e-06;
opts.TolX = 1e-06;
[fitresult_up, gof] = fit( k_up, E_up, ft, opts );

% print LP
figure()
hold on
h = plot(linspace(k_down(1), k_down(end), 100), feval(fitresult_down, linspace(k_down(1), k_down(end), 100)))
set(h,'linewidth',1.7);
errorbar(k_down, E_down, d_E_down / 2, d_E_down / 2, d_k_down / 2, d_k_down / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4);
hold off
legend('hide')
xlabel('$k[1/\mu m]$', 'Interpreter', 'Latex', 'FontSize', 14 )
ylabel('$E[eV]$', 'Interpreter', 'Latex', 'FontSize', 14 )
title("$Energy\: as\: a\: function\: of\: k\: - LP$", 'Interpreter', 'Latex', 'FontSize', 14 )
path = 'Part C/LP.jpg';
saveas(gcf, path)

chisq_down = calcchi2(k_down,E_down,d_k_down,d_E_down,'lin_fit',coeffvalues(fitresult_down));
RChiSquare_down = chisq_down/(length(k_down)-length(opts.StartPoint)) ;
PProb_down = 1 - chi2cdf(chisq_down,length(k_down)-length(opts.StartPoint));
err_down = calc_uncertainty(k_down,E_down,d_k_down,d_E_down,'LP',coeffvalues(fitresult_down));
plotResiduals(k_down, E_down, d_k_down, d_E_down, fitresult_down, sprintf('Part C/LP - res', Mat), '$k [1/\mu m]$', '$y(i) - f(E(i)) [eV]$', 'LP - Residuals', 'LP')

% print UP
figure()
hold on
h = plot(linspace(k_up(1), k_up(end), 100), feval(fitresult_up, linspace(k_up(1), k_up(end), 100)))
set(h,'linewidth',1.7);
errorbar(k_up, E_up, d_E_up / 2, d_E_up / 2, d_k_up / 2, d_k_up / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4);
hold off
legend('hide')
xlabel('$k[1/\mu m]$', 'Interpreter', 'Latex', 'FontSize', 14 )
ylabel('$E[eV]$', 'Interpreter', 'Latex', 'FontSize', 14 )
title("$Energy\: as\: a\: function\: of\: k\: - UP$", 'Interpreter', 'Latex', 'FontSize', 14 )
path = 'Part C/UP.jpg';
saveas(gcf, path)

chisq_up = calcchi2(k_up,E_up,d_k_up,d_E_up,'lin_fit',coeffvalues(fitresult_up));
RChiSquare_up = chisq_up/(length(k_up)-length(opts.StartPoint)) ;
PProb_up = 1 - chi2cdf(chisq_up,length(k_up)-length(opts.StartPoint));
err_up = calc_uncertainty(k_up,E_up,d_k_up,d_E_up,'UP',coeffvalues(fitresult_up));
plotResiduals(k_up, E_up, d_k_up, d_E_up, fitresult_up, sprintf('Part C/UP - res', Mat), '$k [1/\mu m]$', '$y(i) - f(E(i)) [eV]$', 'UP - Residuals', 'UP')

% print UP && LP
figure()
legend('Location','east')
hold on
plot(linspace(k_down(1), k_down(end), 100), feval(fitresult_down, linspace(k_down(1), k_down(end), 100)), 'DisplayName', 'LP', 'linewidth',1.7, 'Color', [0.9730    0.6490    0.8003])
plot(linspace(k_up(1), k_up(end), 100), feval(fitresult_up, linspace(k_up(1), k_up(end), 100)), 'DisplayName', 'UP', 'linewidth',1.7, 'Color', [0.1320    0.9421    0.9561])
errorbar(k_down, E_down, d_E_down / 2, d_E_down / 2, d_k_down / 2, d_k_down / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4, 'HandleVisibility', 'off', 'Color', [0.3532    0.8212    0.0154]);
errorbar(k_up, E_up, d_E_up / 2, d_E_up / 2, d_k_up / 2, d_k_up / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4, 'HandleVisibility', 'off', 'Color', [0.5470    0.2963    0.7447]);
hold off
path = 'Part C/Both.jpg';
xlabel('$k[1/\mu m]$', 'Interpreter', 'Latex', 'FontSize', 14 )
ylabel('$E[eV]$', 'Interpreter', 'Latex', 'FontSize', 14 )
title("$Energy\: as\: a\: function\: of\: k\: - LP\: \&\: UP$", 'Interpreter', 'Latex', 'FontSize', 14 )
saveas(gcf, path)
