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

% Fixed wind speed, plot changing erosion

% c = 0: region1: selectTests=[180+b, [0:2]*10+b+c]; b is between 1,10
% c = 30: region2:
% c = 60: region3:
% c = 90: region3:
% c = 120: region3:
% c = 150: region3:
% c = 180: profile 1: selectTests = [0:10]*10+b+c; 
% c = 290: profile 2

c = 0; 
% select an output to plot;
a = 5; % Select Output Name
b= 3; % (b-1)*2+3 =  Wind speed (b is between 1 and 10


if c == 0
    d = 1;
elseif c == 30
    d = 2;
elseif c == 60
    d = 3;
elseif c == 90
    d = 4;
elseif c == 120
    d = 5;
elseif c == 150
    d = 6;
elseif c == 180
    d = 7;
else
    d = 8;
end

%Erosion test name select 
erosiontestname={"Region1","Region2","Region3","Region4","Region5",...
    "Region6","Profile1","Profile2"};

name = names{a};
if c<180
    selectTests=[180+b, [0:2]*10+b+c];
else
    selectTests = [0:10]*10+b+c;
end
f = figure(Visible="on");
hold on
for i = 1:numel(selectTests)
    Idtab = split(data{selectTests(i)},"/");
    tableID = Idtab{1}+"/"+Idtab{2}+"/"+"TSData"+"/"+Idtab{3}+"_table.txt";
    TableNow = readtable(tableID);
    x = TableNow.Time;
    y = TableNow(:,a).Variables;
    means(i) = mean(y(end-45*160:end));
    Z = numel(selectTests);
    if Z < 10
        Z = 3;
    end
    zs(i) = (i-1)*1/Z;
    z = ones(1,numel(TableNow.Time))*(zs(i));
    plot3(x,z',y,"LineWidth",2);
end
grid on
% Title
ttl = "Plot "+name+" vs Time vs Wind Speed "+erosiontestname{d};
title(ttl)
xlabel("Time (s)")
%ylabel("Wind Speed (m/s)")
ylabel("Erosion Level")
zlabel(name)
view(50,30)
subttl = "Wind Speed = "+num2str((b-1)*2+3);
subtitle(subttl)
savnm = name+erosiontestname{d}+"wind"+num2str((b-1)*2+3)+"par_ts.png";
saveas(gcf,savnm)
% Also make a bar chart of the means:
figure
bar(zs,means)
%xlabel("Wind Speed m/s")
xlabel("Erosion Level")
ylab = name + " mean";
ylabel(ylab)
ttlb = name + " Mean vs Erosion Level Test Bar Chart "+erosiontestname{d};
title(ttlb)
subttl = "Wind Speed = "+num2str((b-1)*2+3);
subtitle(subttl)
savnm = name+erosiontestname{d}+"wind"+num2str((b-1)*2+3)+"par_barch.png";
saveas(gcf,savnm)
%% Look at the experiment
M = readmatrix("WvEtest2.txt");
