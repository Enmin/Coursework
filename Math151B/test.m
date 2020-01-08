% function dudt = f(r, u)
% dudt = [u(2); u(1)/r^2 - u(2)/r];
% end
F = @(r,u) [u(2); u(1)/r^2 - u(2)/r];
[r, u] = ode45(F, [5 8], [0.0038731; 0.0030769]);
plot(r,u(:,1),'-o',r,u(:,2),'-o')
title('Solution  with ODE45');
xlabel('Radius r');
ylabel('Displacement u');
legend('u_1','u_2')