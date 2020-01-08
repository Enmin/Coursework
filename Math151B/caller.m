[r, u] = ode45(@f, [5 8], [0.0038731 0.0030769]);
plot(r,u(:,1))
title('Solution  with ODE45');
xlabel('Radius r');
ylabel('Displacement u');
legend('u_1')