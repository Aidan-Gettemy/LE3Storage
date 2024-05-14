clc;close;clear;
addpath funcs/
addpath StatusFiles\
%% First, we will make one table of all of the output statistics

StatusFileIDs = {};
ranges = ["1_400"];
for i = 1:length(ranges)
    StatusFileIDs{i} = "NewMorris_"+ranges(i)+"_Status.txt";
end

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
M = readmatrix('Experiment_Points\Morris400.txt');
M(:,1) = 30*M(:,1);% Wind direction
M(:,2) = 3 + 22*M(:,2);% Wind Speed
M(:,3) = 1225*.9 + .2*1225*M(:,3);% Air Density

M(:,[10:15]) = M(:,[4:9]);
M(:,[16:21]) = M(:,[4:9]);

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
%OutTable.TurbineAgeClass = categorical(M(:,22));
% InTable is the data we can use
InTable = ALLTable;

%% Save In and Out tables
DataID = "_NewMorris.txt";
rng("default")

writetable(InTable,"InTable_All"+DataID);
writetable(OutTable,"OutTable_All"+DataID);
