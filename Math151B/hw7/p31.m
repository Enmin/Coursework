L = [0,0,0,0,0,0;-1,0,0,0,0,0;0,-1,0,0,0,0;-1,0,0,0,0,0;0,-1,0,-1,0,0;0,0,-1,0,-1,0];
U = [0,-1,0,-1,0,0;0,0,-1,0,-1,0;0,0,0,0,0,-1;0,0,0,0,-1,0;0,0,0,0,0,-1;0,0,0,0,0,0];
D = [4,0,0,0,0,0;0,4,0,0,0,0;0,0,4,0,0,0;0,0,0,4,0,0;0,0,0,0,4,0;0,0,0,0,0,4];
A = L + D + U;
N = 1000;
r = 0.01;
b = transpose([2,1,2,2,1,2]);
 
%Jacobi
x = cell(N+1);
x{1} = transpose([0,0,0,0,0,0]);
k=1;
T = -inv(D)*(L+U);
g = inv(D)*b;
norm = [];
while k <= N
    x{k+1} = T*x{k} + g;
    residualvector = b - A * x{k+1};
    norm(k) = sqrt(sum(residualvector.^2));
    if norm(k) <= r
        break;
    else
        k = k + 1;
    end
end
plot((1:k), norm, 'DisplayName','Jacobi')
hold on
legend
title('Problem 3')
xlabel('r')
ylabel('k')