clc;close;clear
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
for j = 1:12
    iter = 1;
    for i = 1:6
        a = j^(3/2)*i^(7/3)/18;b = i^(1/12)/18;
        pd1 = makedist("Gamma","a",a,"b",b);
        xs = linspace(0,1.2,256);
        ys = pd1.pdf(11*xs);
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
for j = 1:12
    iter = 1;
    for i = 1:6
        a = j^(3/2)*i^(7/3)/18;b = i^(1/12)/18;
        pd2 = makedist("Gamma","a",a,"b",b);
        xs = linspace(0,1.2,256);
        ys = pd2.cdf(11*xs);
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
    plot(1:12,means(1:12,i)/11,"Color",colors{i})
end
xlabel("time")
ylabel("stats")
legend(lgd)
title("means")
figure
hold on
for i = 1:6
    plot(1:12,vars(1:12,i)/11,"Color",colors{i})
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
times = 1:12;
regions = 1:6;
iter = 1;
for k = 1:2 % 2 realizations of each type
    for i = 1:numel(times)
        for j = 1:numel(regions)
            t = times(i);
            r = regions(j);
            a = t^(3/2)*r^(7/3)/18;
            b = r^(1/12)/18;
            pd = makedist("Gamma","a",a,"b",b);
            x = random(pd)/11;
            for p = 1:3
                ps(p) = min(max(randn(1)*(x/20)+x,0),1);
            end
            design(iter,[j,j+6,j+12]) = ps;
        end
        iter = iter+1;
    end
end
%%

for i = 1:24
    figure
    bar(1:6,design(i,1:6),"yellow")
    hold on
    bar(7:12,design(i,7:12),"magenta")
    bar(13:18,design(i,13:18),"red")
    ylim([0,1])
end
