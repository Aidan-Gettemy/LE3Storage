clc;close;clear;
% This plots the results from the experiments with wind and erosion 
addpath funcs/
data = gather_up("");

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
a = 21;
name = names{a};
selectTests = [1,11,21];
f = figure(Visible="on");
hold on
for i = 1:numel(selectTests)
    Idtab = split(data{selectTests(i)},"/");
    tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";
    TableNow = readtable(tableID);
    x = TableNow.Time;
    y = TableNow(:,a).Variables;
    z = ones(1,numel(TableNow.Time))*((i-1)*2+3);
    plot3(x,z',y,"LineWidth",2);
end
grid on
% Title
ttl = "Plot "+name+" vs Time vs Wind Speed";
title(ttl)
xlabel("Time (s)")
ylabel("Wind Speed (m/s)")
zlabel(name)
%%
M = readmatrix("");