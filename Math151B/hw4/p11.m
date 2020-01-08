F = @(t,y)-5*y+5*t^2+2*t;
yInitial = 1/3;
tInitial = 0;
tFinal = 1;
h = 0.1;
N = (tFinal - tInitial)/h;

y = zeros(N+1,1);
t = zeros(N+1,1);
t(1)  = tInitial;
y(1)  = yInitial;
%RK4
t(2) = 0.1;
s1 = F(t(1), y(1));
s2 = F(t(1)+h/2, y(1) + h/2*s1);
s3 = F(t(1)+h/2, y(1) + h/2*s2);
s4 = F(t(1)+h, y(1) + h*s3);
y(2) = y(2) + h*(1/6*s1 + 1/3*s2 + 1/3*s3 + 1/6*s4);

%AB2
for i = 2:N
    y(i+1) = y(i) + h*(3/2*F(t(i),y(i)) - 1/2*F(t(i-1),y(i-1)));
    t(i+1) = t(i) + h;
end
plot(t, y, 'DisplayName','AB2')
hold on

%exact
for i = 1:N
    t(i+1) = t(i)+h;
    y(i+1) = t(i+1)^2 + 1/3*exp(-5*t(i+1));
end
plot(t, y, 'DisplayName','exact')
hold on

tPlotMin =     tInitial;
tPlotMax =     tFinal;
yPlotMin =     -1.0;
yPlotMax =     2.0;

axis([tPlotMin,tPlotMax,yPlotMin,yPlotMax]);
legend
title('Problem 1')
xlabel('t')
ylabel('y(t)')