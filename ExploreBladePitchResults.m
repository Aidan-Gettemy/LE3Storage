clc;close;clear;
% This plots the results from the experiments with wind and erosion 
addpath funcs/
data = gather_up("BladePitchTest6_Status.txt");

Idtab = split(data{10},"/");
tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";

TableNow = readtable(tableID);
names = TableNow.Properties.VariableNames;
%%
% We can compare the experiment design matrix to recall how to read the
% tests

% In this case, we have 24 wind speeds from 3 to 26 m/s.  There is the
% eroded case, which we are trying a new system of starting at 10 degrees
% if ws is above 11.4 m/s, and then we have the clean turbine which should
% not have any problems at any of these speeds

% First, for fixed Erosion, plot the changing wind speeds.
% select an output to plot;
a = 7;
name = names{a};
selectTests = 1:24;
f = figure(Visible="on");
hold on
for i = 1:numel(selectTests)
    Idtab = split(data{selectTests(i)},"/");
    tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";
    TableNow = readtable(tableID);
    x = TableNow.Time;
    y = TableNow(:,a).Variables;
    z = ones(1,numel(TableNow.Time))*(i-1)*2/23+11;
    zs(i) = (i-1)*2/23+11;
    means(i) = mean(y(end-.1*160:end));
    plot3(x,z',y,"LineWidth",2);
end
grid on
% Title
ttl = "Plot "+name+" vs Time vs Wind Speed";
title(ttl)
xlabel("Time (s)")
ylabel("Wind Speed (m/s)")
zlabel(name)

view(45,29)

% Also make a bar chart of the means:
figure
bar(zs,means)
xlabel("Wind Speed m/s")
%xlabel("Erosion Level")
ylab = name + " mean";
ylabel(ylab)
ttlb = name + " Mean vs Blade Test";
title(ttlb)
%%
a=7;i=6;
figure
Idtab = split(data{selectTests(i)},"/");
tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";
TableNow = readtable(tableID);
x = TableNow.Time;
y = TableNow(:,a).Variables;
plot(x,y)
