tInitial = 0;
tFinal = 3;
yInitial = 1;
h = 0.1;
N = (tFinal - tInitial)/h;

%exact solution
y = zeros(N+1,1);
t = zeros(N+1,1);
t(1)  = tInitial;
y(1)  = yInitial;
for i = 1:N
    t(i+1) = t(i) + h;
    y(i+1) = 43/36*exp(t(i+1)) + 1/4*exp(-t(i+1)) - 4/9*exp(-2*t(i+1)) + 1/6*t(i+1)*exp(t(i+1));
end
plot(t, y, 'DisplayName','exact')
hold on

%RK2
v = cell(N+1);
t = zeros(N+1,1);
t(1)  = tInitial;
v{1}  = [1;2;0];
mat = [0,1,0;0,0,1;2,1,-2];
for i = 1:N
    t(i+1) = t(i) + h;
    vstar = v{i} + h * mat * v{i} + [0;0;exp(t(i))];
    s1 = mat * v{i} + [0;0;exp(t(i))];
    s2 = mat * vstar + [0;0;exp(t(i+1))];
    v{i+1} = v{i} + h/2*(s1+s2);
end
y = zeros(N+1,1);
for i = 1:N+1
    y(i) = v{i}(1);
end
plot(t, y, 'DisplayName','RK2')
hold on

legend
title('Problem 2')
xlabel('t')
ylabel('y(t)')