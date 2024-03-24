clc;close;clear;
% This plots the results from the experiments with wind and erosion 
addpath funcs/
data = gather_up("WvE2_Status.txt");

Idtab = split(data{10},"/");
tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";

TableNow = readtable(tableID);
names = TableNow.Properties.VariableNames;
%%

% We can compare the experiment design matrix to recall how to read the
% tests

% In this case, we Erosion is fixed for Testn -Test(n+10) then we advance
% to the next erosion level.

% First, for fixed wind speed, plot changing erosion
% select an output to plot;
a = 2; % Select Name
b= 10; % Select Wind speed...
name = names{a};
selectTests = [0:10]*10+b+290;%this is the region one test at 1/3,2/3,1 erosion
% at the slow speed
f = figure(Visible="on");
hold on
for i = 1:numel(selectTests)
    Idtab = split(data{selectTests(i)},"/");
    tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";
    TableNow = readtable(tableID);
    x = TableNow.Time;
    y = TableNow(:,a).Variables;
    means(i) = mean(y(end-45*160:end));
    zs(i) = (i-1)*1/10;%(i-1)*2+3;
    z = ones(1,numel(TableNow.Time))*((i-1)*1/10);
    plot3(x,z',y,"LineWidth",2);
end
grid on
% Title
ttl = "Plot "+name+" vs Time vs Wind Speed";
title(ttl)
xlabel("Time (s)")
%ylabel("Wind Speed (m/s)")
ylabel("Erosion Level")
zlabel(name)
view(50,30)
subttl = "Wind Speed = "+num2str((b-1)*2+3);
subtitle(subttl)
% Also make a bar chart of the means:
figure
zs = [0:10]*1/10;
bar(zs,means)
%xlabel("Wind Speed m/s")
xlabel("Erosion Level")
ylab = name + " mean";
ylabel(ylab)
ttlb = name + " Mean vs Erosion Level Test Bar Chart";
title(ttlb)
subttl = "Wind Speed = "+num2str((b-1)*2+3);
subtitle(subttl)
%% Look at the experiment
M = readmatrix("WvEtest2.txt");
