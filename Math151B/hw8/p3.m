format long
format long e

mlist = [20,40,80,10];
mStar      = 400;          % Number of equispaced data points to evaluate fit
polyDegree = 3;            %Maximal poly degree used for fit. 
                           % polyDegree must be less than 14


F  = @(x)x.*exp(-1.5*x); 
xMin = 0.0;
xMax = 5.0;
monomials = { (@(x) x.^0),  (@(x) x.^1),  (@(x) x.^2), ...
              (@(x) x.^3),  (@(x) x.^4),  (@(x) x.^5), ...
              (@(x) x.^6),  (@(x) x.^7),  (@(x) x.^8), ...
              (@(x) x.^9),  (@(x) x.^10), (@(x) x.^11), ...
              (@(x) x.^12), (@(x) x.^13), (@(x) x.^14)}; 
rand('seed',314159);
xStar = linspace(xMin,xMax,mStar)';
data = rand(80,1)*(xMax-xMin) + xMin;
%plot(xStar,F(xStar),'b','Linewidth',2,'Displayname','F(x)');
%hold on
lsArray = zeros(5,4);
starArray = zeros(5,4);
index = 1;
for m = mlist
    x = data(1:m);
    y=F(x);
    for p = [1,2,3,4,5]
        phi = {};
        for i = 1:p
            phi{i} = monomials{i};
        end

        A   = zeros(m,p);
        c   = zeros(p,1);

        for j = 1:p
            A(:,j) = phi{j}(x)';
        end
        c = A\y;
        yStar = zeros(mStar,1);

        for j = 1:p
            yStar = yStar + c(j)*phi{j}(xStar);
        end

        %plot(xStar,yStar,'r','Linewidth',2,'Displayname',['(',num2str(p),',',num2str(m),')']);
        %hold on
        normY         = norm(y,2);
        lsResidual = norm(y-A*c,2)/normY;
        lsArray(index) = lsResidual;
        normFstar     = norm(F(xStar),2);
        starResidual  = norm(yStar - F(xStar),2)/normFstar;
        starArray(index) = starResidual;
        index = index + 1;
    end 
end

axis([xMin,xMax,-.2,.5]);
for i = [1,2,3,4]
    plot( [1,2,3,4,5], lsArray(:,i),'-','Displayname', ['(ls,m=',num2str(mlist(i)),')'])
    hold on
    plot([1,2,3,4,5], starArray(:,i),':', 'Displayname', ['(star,m=',num2str(mlist(i)),')'])
    hold on
end
legend
title('relaive residual value vs p')
ylabel('value')
xlabel('p')
hold off