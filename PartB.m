close all
clc
for Mat = ["Fluorescein", "Rhodamine 6G", "Rhodamine B"]
    for C = [0.0001, 0.0005, 0.0008, 0.001, 0.0025, 0.005, 0.01, 0.025, 0.05, 0.1]
        % for each image, make scaled color image for the corresponding
        % primary color
        path = sprintf('../מדידות/Part B/%s/Cropped/%smM.jpg', Mat, string(C));
        A=imread(path);
        A1=im2double(A);
        figure("Name", string(C))
        if(Mat == "Rhodamine B")
            imagesc(A1(:,:,1))
        else
            imagesc(A1(:,:,2))
        end
        title(sprintf("Scaled color image for %smM of %s", string(C), Mat), 'Interpreter', 'Latex', 'FontSize', 14 )
        path = sprintf('Part B/%s/Images/%smM_sc.jpg', Mat, string(C));
        saveas(gcf, path)
    end
end

%% Gets the log of the intensity for each image
Materials = ["Fluorescein", "Rhodamine 6G", "Rhodamine B"];
Cont = [0.0001, 0.0005, 0.0008, 0.001, 0.0025, 0.005, 0.01, 0.025, 0.05, 0.1];

[~,sheets] = xlsfinfo('Part B/meas.xlsx')


for Mat = Materials
    index_row = find(Mat == Materials)

    % reads the pixels from excel sheet
    sheet = xlsread('Part B/meas.xlsx', sheets{index_row});
    pixel_start = sheet(:, 1)
    pixel_max = sheet(:, 2)
    pixel_height = sheet(:, 3)
    for C = Cont
        % for each concentration, creates an excel sheet with Log of
        % intensity and x
        path = sprintf('../מדידות/Part B/%s/Cropped/%smM.jpg', Mat, string(C));
        A=imread(path);
        A1=im2double(A);

        index_col = find(C == Cont)
        if(Mat == "Rhodamine B")
            Av=A1(pixel_height(index_col),pixel_start(index_col):pixel_max(index_col),1);
        else
            Av=A1(pixel_height(index_col),pixel_start(index_col):pixel_max(index_col),2);
        end
        x=linspace(0, 10, length(Av));
        
        filename = sprintf('Part B/%s/Data/%s.xlsx', Mat, string(C));
        tb = table(x', log(Av'))
        tb = renamevars(tb, "Var1", "x")
        tb = renamevars(tb, "Var2", "logI")
        writetable(tb,filename,'Sheet',1,'Range','A1');
    end
end

%% Linear fit for each concentration
close all
clc

chis_red = [];
pprobs = [];

Materials = ["Fluorescein", "Rhodamine 6G", "Rhodamine B"];
Cont = [0.0001, 0.0005, 0.0008, 0.001, 0.0025, 0.005, 0.01, 0.025, 0.05, 0.1];
Espilons = [];
Espilons_err = [];

% for each concentration and each mateiral, plots the data of log of
% intensity and fits a linear line to it

for Mat = Materials
    index_row = find(Mat == Materials)
    for C = Cont
        path = sprintf('../מדידות/Part B/%s/Cropped/%smM.jpg', Mat, string(C));
        A=imread(path);
        A1=im2double(A);

        index_col = find(C == Cont)

        sheet = xlsread(sprintf('Part B/%s/Data/%s.xlsx', Mat, string(C)));
        x = sheet(:, 1)
        y = sheet(:, 2)
        dx = sheet(:, 3)
        dy = sheet(:, 4)

        figure("Name", string(C))
        hold on
        scatter(x,y, 'Marker', 'o')
        grid minor
    
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
        h = plot(fitresult);
        set(h,'linewidth',1.7);
        %e = errorbar(xData, yData, dy / 2, dy / 2, dx / 2, dx / 2, 'LineStyle','none', 'Marker', 'o','MarkerSize',4,'Color',Colors(index));
        hold off

        legend('hide')
        xlabel('x[cm]', 'Interpreter', 'Latex', 'FontSize', 14 )
        ylabel('log(Power) [AU]', 'Interpreter', 'Latex', 'FontSize', 14 )
        title(sprintf('Linear fit for %smM of %s', string(C), Mat), 'Interpreter', 'Latex', 'FontSize', 14 )

        path = sprintf('Part B/%s/Linear Fit/%smM.jpg', Mat, string(C));
        saveas(gcf, path)

        chisq = calcchi2(xData,yData,dx,dy,'lin_fit',coeffvalues(fitresult));
        RChiSquare = chisq/(length(xData)-2) ;
        PProb = 1 - chi2cdf(chisq,length(xData)-2);
        err = calc_uncertainty(xData,yData,dx,dy,'lin_fit',coeffvalues(fitresult));
    
        Epsilons(index_row, index_col) = fitresult.a
        Epsilons_err(index_row, index_col) = err(1)
        chis_red(index_row, index_col) = RChiSquare
        Pprobs(index_row, index_col) = PProb

        plotResiduals(xData, yData, dx, dy, fitresult, sprintf('Part B/%s/Linear Fit/%s - res', Mat, string(C)), '$x [cm]$', '$y(i) - f(log(I(i))) [AU]$', sprintf('Residual plot for linear fit for %smM of %s', string(C), Mat), 'lin_fit')
    end
end