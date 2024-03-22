clc;close;clear;
% This plots the results from the experiments with wind and erosion 
addpath funcs/
data = gather_up("WvE1_Status.txt");

Idtab = split(data{10},"/");
tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";

TableNow = readtable(tableID);
names = TableNow.Properties.VariableNames;
%%

% We can compare the experiment design matrix to recall how to read the
% tests

% In this case, we Erosion is fixed for Testn -Test(n+10) then we advance
% to the next erosion level.

% First, for fixed Erosion, plot the changing wind speeds.
% select an output to plot;
a = 2;
name = names{a};
selectTests = 12:20;
f = figure(Visible="on");
hold on
for i = 1:numel(selectTests)
    Idtab = split(data{selectTests(i)},"/");
    tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";
    TableNow = readtable(tableID);
    x = TableNow.Time;
    y = TableNow(:,a).Variables;
    z = ones(1,numel(TableNow.Time))*(i-1)*2+3;
    plot3(x,z',y,"LineWidth",2);
end
% Title
ttl = "Plot "+name+" vs Time vs Wind Speed";
title(ttl)
xlabel("Time (s)")
ylabel("Wind Speed (m/s)")
zlabel(name)
