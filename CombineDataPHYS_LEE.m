clc;close;clear;
addpath funcs/

%% First, we will make one table of all of the output statistics

StatusFileIDs = {'LEE_ERD1_25_Status.txt'};


a = 1*ones(2);b = 2*ones(2);c = 3*ones(2);
g = cat(2,cat(2,a,b),c);
%%
bigData = {};
for j = 1:numel(StatusFileIDs)
    data = gather_up(StatusFileIDs{1,j});
    bigData = [bigData,data];
end

data = bigData;

% Grab the names:
nameID = data{1,1} + "/Sensor_Data/output_names.mat";
names = load(nameID);
names = names.Output_Names;

varnames(1:3) = ["Wind_Direction","Wind_Speed","Air_Density"];
suffixes = ["","_std","_f1","_f2"];
iter = 4;
for j = 1:4
    for i = 1:numel(names)
        varnames(iter) = string(names{1,i}{1})+suffixes(j);
        iter = iter+1;
    end
end

STDmat = zeros(numel(data),numel(names));
MEANmat = zeros(numel(data),numel(names));

% These next two variables explore some additional features which might be helpful
DOMFREQmat = zeros(numel(data),numel(names));
SUBFREQmat = zeros(numel(data),numel(names));

for i = 1:numel(data)
    tableID = data{1,i}+"/Sensor_Data/SensorData_Mean_Std.txt";
    table_mstd = readtable(tableID,"ReadRowNames",true);
    for j = 1:numel(varnames)/4
        STDmat(i,j) = table_mstd{j,2};
        MEANmat(i,j) = table_mstd{j,1};
        DOMFREQmat(i,j) = table_mstd{j,3};
        SUBFREQmat(i,j) = table_mstd{j,4};
    end
end

% Concatenate all of the matrices together
ALLmat = cat(2,cat(2,cat(2,MEANmat,STDmat),DOMFREQmat),SUBFREQmat);


%% Now, read in the input matrix
M = readmatrix('LifeCycleErosionClasses_Test2.txt');

wind_dir = M(:,1);
wind_speed = M(:,2);
air_dens = M(:,3);

% Append the data
ALLmat = cat(2,cat(2,cat(2,wind_dir,wind_speed),air_dens),ALLmat);

ALLTable = array2table(ALLmat,"VariableNames",varnames);

% might have to remove the useless or unwanted predictor columns...
ALLTable(:,[4:7,11,162:165,169,320:323,327,478:481,485])=[];


ErosionRegions = M(:,4:21);

OutTable = array2table(ErosionRegions);

for i = 1:3
    for j = 1:6
        k = 6*(i-1)+j;
        evarnames(k) = "Blade"+num2str(i)+"Region"+num2str(j);
    end
end
% OutTable is what we want to predict
OutTable.Properties.VariableNames=evarnames;
OutTable.TurbineAgeClass = categorical(M(:,22));
% InTable is the data we can use
InTable = ALLTable;

%% Save In and Out tables
DataID = "_test2.txt";
rng("default")
% Testing Percentage = 25%
p = 0.25;
cvpart = cvpartition(OutTable.TurbineAgeClass,'holdout',p);

In_train = InTable(training(cvpart),:);
Out_train = OutTable(training(cvpart),:);

In_test = InTable(test(cvpart),:);
Out_test = OutTable(test(cvpart),:);


writetable(InTable,"InTable_All"+DataID);
writetable(OutTable,"OutTable_All"+DataID);
writetable(In_train,"InTable_Train"+DataID);
writetable(Out_train,"OutTable_Train"+DataID);
writetable(In_test,"InTable_Test"+DataID);
writetable(Out_test,"OutTable_Test"+DataID);

