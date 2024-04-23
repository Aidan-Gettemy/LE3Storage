clc;close;clear;
% This plots the results from the experiments with wind and erosion 
addpath funcs/
data = gather_up("LEE_ERD1_34_Status.txt");

Idtab = split(data{10},"/");
tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";

TableNow = readtable(tableID);
names = TableNow.Properties.VariableNames;
%%
% We can compare the experiment design matrix to recall how to read the
% tests

a = 3;
name = names{a};
selectTests = 1:34;
f = figure(Visible="on");
zs = zeros(1,numel(selectTests));
means = zeros(1,numel(selectTests));
hold on
for i = 1:numel(selectTests)
    Idtab = split(data{selectTests(i)},"/");
    tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";
    TableNow = readtable(tableID);
    x = TableNow.Time;
    y = TableNow(:,a).Variables;
    z = ones(1,numel(TableNow.Time))*i;
    zs(i) = (i);
    means(i) = mean(y(end-.2*120:end));
    plot3(x,z',y,"LineWidth",2);
end
grid on
% Title
ttl = "Plot "+name+" vs Time vs Test #";
title(ttl)
xlabel("Time (s)")
ylabel("Test #")
zlabel(name)

view(45,29)

% Also make a bar chart of the means:
figure
bar(zs,means)
xlabel(" m/s")
%xlabel("Erosion Level")
ylab = name + " mean";
ylabel(ylab)
ttlb = name + " Mean vs Test#";
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
