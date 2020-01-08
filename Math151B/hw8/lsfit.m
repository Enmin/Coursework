% 
% Script to explore least squares fitting 
%
% Modify as needed.
%
% Created for UCLA Math 151B Winter 2019 
%
% Version 3/10/2019

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Input parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
format long
format long e


m          = 20;           % Number of data points
mStar      = 400;          % Number of equispaced data points to evaluate fit
polyDegree = 3;            %Maximal poly degree used for fit. 
                           % polyDegree must be less than 14


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Data Creation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Target function (used to create synthetic data)

F  = @(x)x.*exp(-1.5*x);  

%F  = @(x)x.^(0.5);  
%F  = @(x)(1.0)./(1.0 + 10.0.*x.^2);  

fprintf('Test Function \n');
fprintf('%s \n\n',func2str(F));

xMin = 0.0;
xMax = 5.0;

%
% Create sorted, uniformly distributed random numbers in [xMin,xMax]
% to be the sample ordinates. 
%
% Setting the seed of the random number generator so the 
% random numbers are the same each time the script is run
%

rand('seed',314159);
x = sort(rand(m,1))*(xMax-xMin) + xMin;

% Create data 

y = F(x); 
                


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(x,y,'o','Linewidth',2);
hold on


% Now plot the target function at mStar uniformly spaced set 
% of points xStar

xStar = linspace(xMin,xMax,mStar)';

plot(xStar,F(xStar),'b','Linewidth',2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Specification of functions be used for the fit 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create a cell array of monomials in the variable x to be used for 
% the fit. I'm adding parenthesis about each function so I don't have to
% worry about spaces in the function specification. The "." in the 
% specification of the power allows these functions to be applied to 
% a vector of values. 
%

monomials = { (@(x) x.^0),  (@(x) x.^1),  (@(x) x.^2), ...
              (@(x) x.^3),  (@(x) x.^4),  (@(x) x.^5), ...
              (@(x) x.^6),  (@(x) x.^7),  (@(x) x.^8), ...
              (@(x) x.^9),  (@(x) x.^10), (@(x) x.^11), ...
              (@(x) x.^12), (@(x) x.^13), (@(x) x.^14)}; 
    
    
% Create a list of functions, the first in the list being 
% monomials up to degree polyDegree
    
p = polyDegree+1;

for i = 1:p
  phi{i} = monomials{i};
end


% Add in extra functions by incrementing p, and then assigning
% phi{p} to the function
%
%
%p = p+1;
%phi{p} = @(x) exp(-1.0.*x);
%
   

fprintf('Functions used in fit \n');
for i = 1:p
  fprintf('%s \n',func2str(phi{i}));
end

% Construct over determined set of equations using this 
% list of functions 

A   = zeros(m,p);
c   = zeros(p,1);

for j = 1:p
  A(:,j) = phi{j}(x)';
end

% Obtain the least squares solution using the \ command

fprintf('\nCoefficients of fit \n');

c = A\y

%
% Evaluate and plot the approximation at a uniformly spaced set
% set of points
%

yStar = zeros(mStar,1);

for j = 1:p
yStar = yStar + c(j)*phi{j}(xStar);
end

plot(xStar,yStar,'r','Linewidth',2);

legend('data','F(x)','LS approximation');

% Set axis, so it doesn't change for different experiments 

axis([xMin,xMax,-.2,.5]);

% Evaluate the relative residual of the least squares 
% solution of the linear system of equations, and the relative residual of the
% fit at a uniformly spaced set of points 

normY         = norm(y,2);
lsResidual    = norm(y-A*c,2)/normY

normFstar     = norm(F(xStar),2);
starResidual  = norm(yStar - F(xStar),2)/normFstar

hold off