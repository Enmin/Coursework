F  = @(y)10*(y-y^2);

tInitial = 0;
tFinal = 5;
h = 0.01;
yInitial = 0.5;
N = (tFinal - tInitial)/h;

y = zeros(N+1,1);
t = zeros(N+1,1); 
t(1)  = tInitial;
y(1)  = yInitial;
for i = 1:N
    s1 = F(y(i));
    s2 = F(y(i)+h*s1);
    t(i+1) = t(i) + h;
    y(i+1) = y(i) + h/2*(s1+s2);
end

plot(t, y, 'DisplayName', 'RK2')
hold on

tPlotMin =     tInitial;
tPlotMax =     tFinal;
yPlotMin =     0.0;
yPlotMax =     2.0;

axis([tPlotMin,tPlotMax,yPlotMin,yPlotMax]);
legend
title('Problem 3 obtained with RK2''s method ')
xlabel('t')
ylabel('y(t)')