F  = @(t,y)-20*y + 20*sin(t) + cos(t);

tInitial    = 0.0;                      % Initial time
tFinal      = 2.0;                      % Final time
yInitial    = 1;                      % Initial value of y
h = 0.1;
N=(tFinal- tInitial)/h;

%Euler's
y = zeros(N+1,1);
t = zeros(N+1,1); 
t(1)  = tInitial;
y(1)  = yInitial;
for i = 1:N
    t(i+1) = t(i) + h;
    y(i+1) = y(i) + h*F(t(i),y(i));
end
plot(t, y, 'DisplayName','Euler')
hold on

%RK4
y = zeros(N+1,1);
t = zeros(N+1,1); 
t(1)  = tInitial;
y(1)  = yInitial;
for i = 1:N
    s1 = F(t(i), y(i));
    s2 = F(t(i)+h/2, y(i) + h/2*s1);
    s3 = F(t(i)+h/2, y(i) + h/2*s2);
    s4 = F(t(i)+h, y(i) + h*s3);
    t(i+1) = t(i) + h;
    y(i+1) = y(i) + h*(1/6*s1 + 1/3*s2 + 1/3*s3 + 1/6*s4);
end
plot(t, y, 'DisplayName','RK4')
hold on

%Trapezoidal
y = zeros(N+1,1);
t = zeros(N+1,1); 
t(1)  = tInitial;
y(1)  = yInitial;
for i = 1:N
    t(i+1) = t(i) + h;
    y(i+1) = 0.5*(sin(t(i))+0.05*cos(t(i))+sin(t(i+1))+0.05*cos(t(i+1)));
end
plot(t, y, 'DisplayName','Trapezoidal')
hold on

%Exact
y = zeros(N+1,1);
t = zeros(N+1,1); 
t(1)  = tInitial;
y(1)  = yInitial;
for i = 1:N
    t(i+1) = t(i) + h;
    y(i+1) = sin(t(i+1)) + exp(-20*t(i+1));
end
plot(t, y, 'DisplayName', 'Exact')
hold on

tPlotMin =     tInitial;
tPlotMax =     tFinal;
yPlotMin =     -1.0;
yPlotMax =     2.0;

axis([tPlotMin,tPlotMax,yPlotMin,yPlotMax]);
legend
title('Problem 2')
xlabel('t')
ylabel('y(t)')