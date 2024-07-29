%% log(Intensity) as a function of wave length for each Material

% Closing all open figures and clearing command line
close all
clc

Material = ["Fluorescein", "Rhodamine 6G", "Rhodamine B"];
Cont = [0.0001, 0.0005, 0.0008, 0.001, 0.0025, 0.005, 0.01, 0.025, 0.05, 0.1];
ints = [];
ints_err = [];
Colors = ["red" "green" "blue"];

sheet = readtable('../מדידות/Part A/background noise.ods');
x_noise = table2array(sheet(:, 1));
y_noise = table2array(sheet(:, 2));

idx_noise = find(x_noise > 460 & x_noise < 740);
x_noise = x_noise(idx_noise);
y_noise = y_noise(idx_noise);

dCont = Cont * 0.01 / sqrt(12);

for Mat = Material
    for C = Cont
        % Import the sheet
        path = sprintf('../מדידות/Part A/%s/%smM.ods', Mat, string(C));
        sheet = readtable(path);
        
        % Filtering the LED spectrum
        x = table2array(sheet(:, 1));
        y = table2array(sheet(:, 2));

        idx = find(x > 460 & x < 740);
        x = x(idx);
        y = y(idx);

        % show the spectrum for each concentration
        f = figure()
        f.WindowState = 'minimized';
        plot(x, y)
        xlabel( '$\lambda [nm]$', 'Interpreter', 'Latex', 'FontSize', 14 );
        ylabel( '$Intensity [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 );
        title(sprintf("%s - %s - With noise", Mat, string(C)), 'Interpreter', 'Latex', 'FontSize', 14);
        saveas(gcf, sprintf("Part A/Specs/%s/%s_with_noise.png", Mat, string(C)))

        % if the mean of the neighbourhood of the maximum point in y is
        % larger than the maximum of the backgorund noise, we can subtract
        % it from the data

        [maxvaly,idx] = max(y);

        if(mean(y(idx-70:idx+70)) > 0.03)
            y = y - y_noise
    
            f = figure()
            f.WindowState = 'minimized';
            plot(x, y)
            xlabel( '$\lambda [nm]$', 'Interpreter', 'Latex', 'FontSize', 14 );
            ylabel( '$Intensity [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 );
            title(sprintf("%s - %s - Without noise", Mat, string(C)), 'Interpreter', 'Latex', 'FontSize', 14);
            saveas(gcf, sprintf("Part A/Specs/%s/%s_without_noise.png", Mat, string(C)))
        end
        
        
        % calc the integral of the data
        ints(find(Material == Mat), find(Cont == C)) = trapz(y);
    end
end

%% Spectrum for each Material all Concentrations
colors = [    0.1320    0.9421    0.9561
    0.5752    0.0598    0.2348
    0.3532    0.8212    0.0154
    0.0430    0.1690    0.6491
    0.7317    0.6477    0.4509
    0.5470    0.2963    0.7447
    0.9730    0.6490    0.8003
    0.3685    0.6256    0.7802
    0.0835    0.1332    0.1734
    0.9797    0.4389    0.1111];

for Mat = Material
    figure()
    legend('Location', 'northeast')
    hold on
    for C = Cont
        % Import the sheet
        path = sprintf('../מדידות/Part A/%s/%smM.ods', Mat, string(C));
        sheet = readtable(path);
        
        % Filtering the LED spectrum
        x = table2array(sheet(:, 1));
        y = table2array(sheet(:, 2));

        idx = find(x > 460 & x < 740);
        x = x(idx);
        y = y(idx);

        [maxvaly,idx] = max(y);

        if(mean(y(idx-70:idx+70)) > 0.03)
            y = y - y_noise
        end
    
        plot(x, y, 'DisplayName', sprintf("%smM", string(C)), 'Color', colors(find(Cont == C), :))
    end
    hold off
    xlabel( '$\lambda [nm]$', 'Interpreter', 'Latex', 'FontSize', 14 );
    ylabel( '$Intensity [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 );
    title(sprintf("%s", Mat), 'Interpreter', 'Latex', 'FontSize', 14);
    saveas(gcf, sprintf("Part A/Specs/%s/All Concs.png", Mat))
end

%% plot the integrals per material
[~,sheets] = xlsfinfo('Part A/meas.xlsx')
fits = [];

for Mat = Material
    index = find(Material == Mat);
    sheet = xlsread('Part A/meas.xlsx', sheets{index});
    y = sheet(:, 1)
    dy = sheet(:, 2)
    x = sheet(:, 3)
    dx = sheet(:, 4)

    [xData, yData] = prepareCurveData( x, y );
    
    % Set up fittype and options.
    ft = fittype( 'a*x+b', 'independent', 'x', 'dependent', 'y' );
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

    fits(index, :) = feval(fitresult, x);

    figure()
    xlabel( '$Concentration [mM]$', 'Interpreter', 'Latex', 'FontSize', 14 );
    ylabel( '$log(Intensity) [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 );
    title(Mat, 'Interpreter', 'Latex', 'FontSize', 14);
    hold on
        %plot(C, log(ints(find(Material == Mat), find(Cont == C))), "Marker", "o", 'HandleVisibility','off', 'Color', Colors(find(Material == Mat)))
    errorbar(x, y, dy / 2, dy / 2, dx / 2, dx / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4, 'Color', Colors(find(Material == Mat)));
    hold off
    saveas(gcf, sprintf("Part A/Scatter/%s.png", Mat))
    plotResiduals(xData, yData, dx, dy, fitresult, sprintf('Part A/Scatter/%s - res', Mat), '$Concentration [mM]$', '$y(i) - f(log(I(i))) [AU]$', sprintf('%s - Residuals', Mat), 'lin_fit')
end
%% Plot all 3 materials on one plot
figure()
xlabel( '$Concentration [mM]$', 'Interpreter', 'Latex', 'FontSize', 14 );
ylabel( '$log(Intensity) [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 );
title("$log(Intensity)\:as\:a\:function\:of\:concentration$", 'Interpreter', 'Latex', 'FontSize', 14);
legend('Location', 'southeast')
hold on
for Mat = Material
    index = find(Material == Mat);
    sheet = xlsread('Part A/meas.xlsx', sheets{index});
    y = sheet(:, 1)
    dy = sheet(:, 2)
    x = sheet(:, 3)
    dx = sheet(:, 4)
    plot(x, y, "Marker", "none", 'Color', Colors(find(Material == Mat)), 'DisplayName', Mat)
    errorbar(x, y, dy / 2, dy / 2, dx / 2, dx / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4, 'Color', Colors(find(Material == Mat)), 'HandleVisibility','off');
    plot(x, fits(index, :), 'Color', Colors(find(Material == Mat)), 'HandleVisibility', 'off')
end
hold off
saveas(gcf, "Part A/All_mats.png")

%% Linear fit for linear area for each material
points = [4 5 7]%[4 5 3];
startPoint = [1 2 3]
chis_red = [];
pprobs = [];
fits = [];

for Mat=Material
    index = find(Material == Mat);
    sheet = xlsread('Part A/meas.xlsx', sheets{index});
    y = sheet(startPoint(index):points(index), 1)
    dy = sheet(startPoint(index):points(index), 2)
    x = sheet(startPoint(index):points(index), 3)
    dx = sheet(startPoint(index):points(index), 4)

    [xData, yData] = prepareCurveData( x, y );
    
    % Set up fittype and options.
    ft = fittype( 'a*x+b', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Algorithm = 'Trust-Region';
    opts.Display = 'Off';
    opts.Robust = 'LAR';
    opts.StartPoint = [230 0]
    opts.MaxFunEvals = 6000;
    opts.MaxIter = 4000;
    opts.TolFun = 1e-06;
    opts.TolX = 1e-06;
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
    % Plot fit with data.
    f = figure( 'Name', 'untitled fit 1' );
    h = plot(fitresult);
    set(h,'linewidth',1.7);
    hold on
    e = errorbar(xData, yData, dy / 2, dy / 2, dx / 2, dx / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4,'Color',Colors(index));
    legend('hide');

    % Label axes
    xlabel( '$Concentration [mM]$', 'Interpreter', 'Latex', 'FontSize', 14 );
    ylabel( '$log(Intensity) [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 );
    title(Mat, 'Interpreter', 'Latex', 'FontSize', 14);

    chisq = calcchi2(xData,yData,dx,dy,'lin_fit',coeffvalues(fitresult));
    RChiSquare = chisq/(length(xData)-length(opts.StartPoint)) ;
    PProb = 1 - chi2cdf(chisq,length(xData)-length(opts.StartPoint));
    err = calc_uncertainty(xData,yData,dx,dy,'lin_fit',coeffvalues(fitresult));

    fits(index, 1:2) = [fitresult.a fitresult.b]
    chis_red(index) = RChiSquare
    Pprobs(index) = PProb
    saveas(gcf, sprintf("Part A/Linear/%s_linear.png", Mat))
    plotResiduals(xData, yData, dx, dy, fitresult, sprintf('Part A/Linear/%s - res', Mat), '$Concentration [mM]$', '$y(i) - f(log(I(i))) [AU]$', sprintf('%s - Residuals', Mat), 'lin_fit')
end

%% All linear fits
points = [4 5 7]%[4 5 3];
startPoint = [1 2 3]

f = figure( 'Name', 'untitled fit 1' );
xlabel( '$Concentration [mM]$', 'Interpreter', 'Latex', 'FontSize', 14 );
ylabel( '$log(Intensity) [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 );
title("Linear Fit", 'Interpreter', 'Latex', 'FontSize', 14);
legend('Location', 'southeast')
hold on

for Mat=Material
    index = find(Material == Mat);
    sheet = xlsread('Part A/meas.xlsx', sheets{index});
    y = sheet(startPoint(index):points(index), 1)
    dy = sheet(startPoint(index):points(index), 2)
    x = sheet(startPoint(index):points(index), 3)
    dx = sheet(startPoint(index):points(index), 4)

    [xData, yData] = prepareCurveData( x, y );
    
    % Set up fittype and options.
    ft = fittype( 'a*x+b', 'independent', 'x', 'dependent', 'y' );
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
    
    h = plot(x, feval(fitresult, x),'Color',Colors(index), 'DisplayName', Mat);
    set(h,'linewidth',1.7);
    e = errorbar(xData, yData, dy / 2, dy / 2, dx / 2, dx / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4,'Color',Colors(index), 'HandleVisibility', 'off');
end
hold off
saveas(gcf, "Part A/linear_fit.png")

%% Polynomial fit
chis_red = [];
pprobs = [];
fits = [];

for Mat=Material
    index = find(Material == Mat);
    sheet = xlsread('Part A/meas.xlsx', sheets{index});
    y = sheet(:, 1)
    dy = sheet(:, 2)
    x = sheet(:, 3)
    dx = sheet(:, 4)

    [xData, yData] = prepareCurveData( x, y );
    
    % Set up fittype and options.
    ft = fittype( 'a*(x)^2+b*(x)+c', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Algorithm = 'Trust-Region';
    opts.Display = 'Off';
    opts.Robust = 'LAR';
    opts.StartPoint = [-1000 100 1]% 0]
    %opts.Upper = [0 Inf 100 Inf]
    %opts.Lower = [-Inf -Inf -100 -Inf]
    opts.MaxFunEvals = 6000;
    opts.MaxIter = 4000;
    opts.TolFun = 1e-06;
    opts.TolX = 1e-06;
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
    % Plot fit with data.
    f = figure( 'Name', 'untitled fit 1' );
    h = plot(fitresult);
    set(h,'linewidth',1.7);
    hold on
    e = errorbar(xData, yData, dy / 2, dy / 2, dx / 2, dx / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4,'Color',Colors(index));
    legend('hide');

    % Label axes
    xlabel( '$Concentration [mM]$', 'Interpreter', 'Latex', 'FontSize', 14 );
    ylabel( '$log(Intensity) [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 );
    title(Mat, 'Interpreter', 'Latex', 'FontSize', 14);

    chisq = calcchi2(xData,yData,dx,dy,'parabolic_fit',coeffvalues(fitresult));
    RChiSquare = chisq/(length(xData)-length(opts.StartPoint)) ;
    PProb = 1 - chi2cdf(chisq,length(xData)-length(opts.StartPoint));
    err = calc_uncertainty(xData,yData,dx,dy,'parabolic_fit',coeffvalues(fitresult));
    
    fits(index, 1:3) = [fitresult.a fitresult.b fitresult.c]% fitresult.d]
    chis_red(index) = RChiSquare
    Pprobs(index) = PProb
    saveas(gcf, sprintf("Part A/Poly/%s_fourth_poly.png", Mat))
    plotResiduals(xData, yData, dx, dy, fitresult, sprintf('Part A/Poly/%s - res', Mat), '$Concentration [mM]$', '$y(i) - f(log(I(i))) [AU]$', sprintf('%s - Residuals', Mat), 'parabolic_fit')
end

%% All Poly fits

f = figure( 'Name', 'untitled fit 1' );
xlabel( '$Concentration [mM]$', 'Interpreter', 'Latex', 'FontSize', 14 );
ylabel( '$log(Intensity) [AU]$', 'Interpreter', 'Latex', 'FontSize', 14 );
title("Polynomial Fit", 'Interpreter', 'Latex', 'FontSize', 14);
legend('Location', 'southeast')
hold on

for Mat=Material
    index = find(Material == Mat);
    sheet = xlsread('Part A/meas.xlsx', sheets{index});
    y = sheet(:, 1)
    dy = sheet(:, 2)
    x = sheet(:, 3)
    dx = sheet(:, 4)

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
    h = plot(0:0.001:x(end), feval(fitresult, 0:0.001:x(end)),'Color',Colors(index), 'DisplayName', Mat);
    set(h,'linewidth',1.7);
    e = errorbar(xData, yData, dy / 2, dy / 2, dx / 2, dx / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4,'Color',Colors(index), 'HandleVisibility', 'off');
end
hold off
saveas(gcf, "Part A/poly_fit.png")
