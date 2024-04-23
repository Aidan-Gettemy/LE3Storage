clc;close all;clear
% We can use a Gamma distribution to represent the probability of erosion
% reaching a certain extent in a given blade regioon 
% n years after the turbine begins operation

% Gamma distributions represent time to failure events

% We assume that failure happens with more frequency towards the tip of the
% blades



% The mean is a*b
% a will be dependent on the years since start
% b will be dependet on the location on blade
hold on
colors = {"#ff0000",...
    "#ff9933",...
    "#808000",...
    "#009900",...
    "#0099ff",...
    "#6600ff"};
for j = 1:20
    iter = 1;
    for i = 1:6
        a = 2.3*(j^(3.5/2)*i^(7/3)/(2*4*18));b = i^(1/20)/(2*7*18)+1/2000*(6-i);
        pd1 = makedist("Gamma","a",a,"b",b);
        xs = linspace(0,1.2,256);
        ys = pd1.pdf(xs);
        plot3(xs,j*ones(1,numel(xs)),ys,LineWidth=3,Color=colors{i})
        lgd(iter) = {"Region"+num2str(i)};
        means(j,i) = [a*b];
        vars(j,i) = [a*b*b];
        iter = iter+1;
        
    end
end
xlabel("Erosion Level")
zlabel("Probability")
ylabel("Time")
legend(lgd)
title("Pdf of erosion distribuiton")


figure
hold on
for j = 1:20
    iter = 1;
    for i = 1:6
        a = 2.3*(j^(3.5/2)*i^(7/3)/(2*4*18));b = i^(1/20)/(2*7*18)+1/2000*(6-i);
        pd2 = makedist("Gamma","a",a,"b",b);
        xs = linspace(0,1.2,256);
        ys = pd2.cdf(xs);
        plot3(xs,j*ones(1,numel(xs)),ys,LineWidth=3,Color=colors{i})
        lgd(iter) = {"Region"+num2str(i)};
        iter = iter+1;
        
    end
end
xlabel("Erosion Level")
zlabel("Probability")
ylabel("Time")
legend(lgd)
title("cdf of erosion distribuiton")
figure
hold on
for i = 1:6
    plot(1:20,means(1:20,i),"Color",colors{i})
end
xlabel("time")
ylabel("stats")
legend(lgd)
title("means")
figure
hold on
for i = 1:6
    plot(1:20,vars(1:20,i),"Color",colors{i})
end
xlabel("time")
ylabel("stats")
legend(lgd)
title("vars")
%%
% We will generate an erosion distribution by assigning a time, and
% then for each region, drawing from the distribution defined by 
% gamma(a,b)
% a = time (in years)
% b = region (i/(i+71))
design = zeros(1,18);
times = 1:20;
regions = 1:6;
iter = 1;
for k = 1 % 2 realizations of each type
    for i = 1:numel(times)
        for j = 1:numel(regions)
            t = times(i);
            r = regions(j);
            a = 2.3*(t^(3.5/2)*r^(7/3)/(2*4*18));
            b = r^(1/20)/(2*7*18)+1/2000*(6-r);
            
            pd = makedist("Gamma","a",a,"b",b);
            x = random(pd);
            for p = 1:3
                ps(p) = min(max(randn(1)*(x/20)+x,0),1);
            end
            design(iter,[j,j+6,j+12]) = ps;
        end
        iter = iter+1;
    end
end
%%

for i = 1:20
    figure
    bar(1:6,design(i,1:6),"yellow")
    hold on
    bar(7:12,design(i,7:12),"magenta")
    bar(13:18,design(i,13:18),"red")
    ylim([0,1])
end
%% Generate a data-set

% We will set up all the points here, so that when we run the test, no
% further changes are needed

% input space dimension: # environmental inputs
dim = 3;

% number of test points:
% Select the number of years to simulate
years = 17;
% Select the number of samples per year
sampls = 100;
% Number of rows needed
num = years*sampls;

X = lhsdesign(num,dim,'Criterion','correlation','iterations',10);

% Add the erosion components
M = zeros(numel(X(:,1)),22); % We add the last column for year

% We have 6 regions
regions = 1:6;

yrs = 0;

% Iterate through the design, and set each column appropriately 
for i =1:numel(X(:,1))
    M(i,1) = 25*X(i,1); % Set wind direction
    M(i,2) = 3+22*X(i,2); % Set wind speed
    M(i,3) = 1225*.9+.2*1225*X(i,3); % Set the air density

    % Then we set the erosion.
    if yrs==0
        M(i,4:21) = zeros(1,18); % Control Group
    else
        t = yrs;
        for j = 1:numel(regions)
            r = regions(j);
            a = 2.3*(t^(3.5/2)*r^(7/3)/(2*4*18));
            b = r^(1/20)/(2*7*18)+1/2000*(6-r);
            
            pd = makedist("Gamma","a",a,"b",b);
            x = random(pd);
            for p = 1:3
                ps(p) = min(max(randn(1)*(x/20)+x,0),1);
            end
            M(i,3+[j,j+6,j+12]) = ps;
            M(i,22) = yrs;
        end
    end

    % Check if we advance to the next year
    if mod(i,sampls) == 0
        yrs = yrs+1.5;
    end

end

save("LifeCycleErosionClasses.txt","M","-ascii")
%% Check if the data-set we made looks right

M = readmatrix("LifeCycleErosionClasses.txt");

for i = 1499:1500
    figure
    hold on
    bar(1,(1/25)*M(i,1),"black")
    bar(2,(1/25)*M(i,2),"black")
    bar(3,(1/(1.1*1225))*M(i,3),"black")

    bar(4:9,M(i,4:9),"yellow")
    
    bar(10:15,M(i,10:15),"magenta")

    bar(16:21,M(i,16:21),"red")

    ylim([0,1])
    title("Year" + num2str(M(i,22)))
end
%%
close all;

image(M(:,4:21),'CDataMapping','scaled')
colorbar

