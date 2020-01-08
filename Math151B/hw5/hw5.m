xInitial = 0;
xFinal = 2;
h = 0.2;
N = (xFinal - xInitial)/h;
yInitial = 0;
yFinal = -4;

% exact
fexact = @(x) 1/6*x^3*exp(x) - 5/3*x*exp(x) + 2*exp(x) - x - 2;
y = zeros(N+1,1);
x = zeros(N+1,1);
x(1) = xInitial;
y(1) = yInitial;
x(N+1) = xFinal;
y(N+1) = yFinal;
for i = 1:N-1
    x(i+1) = x(i) + h;
    y(i+1) = fexact(x(i+1));
end
plot(x, y, 'DisplayName','exact')
hold on

% FDM
p = -2;
q = 1;
f = @(x) x*exp(x) - x;
A = zeros(N-1, N-1);
A(1,1) = -2/h^2 + q;
A(1,2) = 1/h^2 + p/(2*h);
A(N-1,N-2) = 1/h^2 - p/(2*h);
A(N-1,N-1) = -2/h^2 + q;
for i = 2:N-2
    A(i,i-1) = 1/h^2 - p/(2*h);
    A(i,i) = -2/h^2 + q;
    A(i,i+1) = 1/h^2 + p/(2*h);
end
B = zeros(N-1,1);
B(1) = f(xInitial + h) - yInitial/h^2 + p*yInitial/(2*h);
B(N-1) = f(xFinal - h) - yFinal/h^2 - p*yFinal/(2*h);
for i = 2:N-2
    B(i) = f(xInitial + i*h);
end
FDMY = inv(A)*B;
y = zeros(N+1,1);
y(1) = yInitial;
y(N+1) = yFinal;
for i = 2:N
    y(i) = FDMY(i-1);
end
plot(x, y, 'DisplayName','FDM')
hold on

legend
title('Problem 2')
xlabel('x')
ylabel('y(x)')
