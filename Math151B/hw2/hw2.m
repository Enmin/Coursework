F  = @(y)4*y*(1-y);
format long
tInitial    = 0.0;                      % Initial time
tFinal      = 1.0;                      % Final time
yInitial    = 0.1;                    % Initial value of y
Eresult = zeros(6,1);
RKresult = zeros(6,1);
%Euler
index = 1;
for h = [0.1, 0.05, 0.025, 0.0125, 0.00625, 0.003125]
    N=(tFinal- tInitial)/h;
    y = zeros(N+1,1);
    t = zeros(N+1,1); 
    t(1)  = tInitial;
    y(1)  = yInitial;
    for i = 1:N
        t(i+1) = t(i) + h;
        y(i+1) = y(i) + h*F(y(i));
    end
    Eresult(index) = y(N+1);
    index = index + 1;
end

%RK2 Heum
index = 1;
for h = [0.1, 0.05, 0.025, 0.0125, 0.00625, 0.003125]
    N=(tFinal- tInitial)/h;
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
    RKresult(index) = y(N+1);
    index = index + 1;
end

Erate = zeros(4,1);
RKrate = zeros(4,1);
for i = 2:5
    Erate(i-1) = log((Eresult(i-1)-Eresult(i))/(Eresult(i)-Eresult(i+1)))/log(2);
end
for i = 2:5
    RKrate(i-1) = log((RKresult(i-1)-RKresult(i))/(RKresult(i)-RKresult(i+1)))/log(2);
end
Eresult
RKresult
Erate
RKrate