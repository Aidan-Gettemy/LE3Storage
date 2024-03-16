clc;close;clear;
addpath funcs/
StatusFileID = "";

data = gather_up(StatusFileID);

% Grab the names:
nameID = data{1,1} + "/Sensor_Data/output_names.mat";
names = load(nameID);
names = names.Output_Names;

for i = 1:numel(names)
    varnames(i) = string(names{1,i}{1});
end

STDmat = zeros(numel(data),numel(names));
MEANmat = zeros(numel(data),numel(names));

% These next two variables explore some additional features which might be helpful
DOMFREQmat = zeros(numel(data),numel(names));
SUBFREQmat = zeros(numel(data),numel(names));

for i = 1:numel(data)
    tableID = data{1,i}+"/Sensor_Data/SensorData_Mean_Std.txt";
    table_mstd = readtable(tableID,"ReadRowNames",true);
    for j = 1:numel(varnames)
        STDmat(i,j) = table_mstd{j,2};
        MEANmat(i,j) = table_mstd{j,1};
        DOMFREQmat(i,j) = table_mstd{j,3};
        SUBFREQmat(i,j) = table_mstd{j,4};
    end
end

StdTab = array2table(STDmat,"VariableNames",varnames);
MeanTab = array2table(MEANmat,"VariableNames",varnames);

DFTab = array2table(DOMFREQmat,"VariableNames",varnames);
SFTab = array2table(SUBFREQmat,"VariableNames",varnames);

meantabID = "";
stdtabID = "";
f1tabID = "";
f2tableID = "";
writetable(MeanTab,meantabID);
writetable(StdTab,stdtabID);
writetable(DFTab,f1tabID);
writetable(SFTab,f2tabID);

% consider using the join table GUI to combine multiple tables at once...
