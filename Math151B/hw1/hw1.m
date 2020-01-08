F  = @(t,y)-5*y + 5*t^2 + 2*t

tInitial    = 0.0;                      % Initial time
tFinal      = 1.0;                      % Final time
yInitial    = 1/3;                      % Initial value of y


for h = [0.1, 0.05, 0.025]
    N=(tFinal- tInitial)/h
    y = zeros(N+1,1);
    t = zeros(N+1,1); 
    t(1)  = tInitial;
    y(1)  = yInitial;
    for i = 1:N
            t(i+1) = t(i) + h;
            y(i+1) = y(i) + h*F(t(i),y(i));
    end
    plot(t, y, 'DisplayName',num2str(h))
    hold on
end

tPlotMin =     tInitial;
tPlotMax =     tFinal;
yPlotMin =     0.0;
yPlotMax =     2.0;

axis([tPlotMin,tPlotMax,yPlotMin,yPlotMax]);
legend
title('Approximate solution to dy/dt = -5y+5t^2+2t obtained with Euler''s method ')
xlabel('t') 
ylabel('y(t)')
