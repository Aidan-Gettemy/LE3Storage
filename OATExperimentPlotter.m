clc;close;clear;
%% One at a Time Analysis Maker
% Create every experiment table
addpath funcs/

experiments_names = {"WindDir","WindSpeed","BladePitch","AirDensity",...
    "ErosionBlade1Region1","ErosionBlade1Region2","ErosionBlade1Region3",...
    "ErosionBlade1Region4"};

% cycle over all experiments
for i = 1:numel(experiments_names)
    % Put in the experimentID
    ExperimentID = "Data/"+experiments_names{i};
    
    % Grab the status file
    StatusID = experiments_names{i}+"_Status.txt";
    
    data = gather_up(StatusID);
    summary_tables = cell(1,numel(data));
    for j = 1:numel(data)
        summary_tables{1,j} = data{1,j} + ...        
            "/"+"Sensor_Data/SensorData_Mean_Std.txt";
    end
    
    % Make the full Experiment Table
    [mean_exp_table, std_exp_table,f1_table,f2_table] = full_exp_table(summary_tables);
    
    % Save Those Tables
    output_ID = ExperimentID + "/"+"Experiment_means.txt";
    writetable(mean_exp_table,output_ID,'WriteRowNames',true)
    
    output_ID = ExperimentID + "/"+"Experiment_stds.txt";
    writetable(std_exp_table,output_ID,'WriteRowNames',true)

    output_ID = ExperimentID + "/"+"Experiment_f1.txt";
    writetable(f1_table,output_ID,'WriteRowNames',true)

    output_ID = ExperimentID + "/"+"Experiment_f2.txt";
    writetable(f2_table,output_ID,'WriteRowNames',true)
end

%% Next we can see plot outputs changes in mean etc

ExperimentID = "Data/WindDir";
StatusID = "WindDir_Status.txt";

data = gather_up(StatusID);
lib_datas = cell(1,numel(data));
for i = 1:numel(data)
    Testfolder = data{1,i};
    lib_datas{1,i} = Testfolder + "/" + "Sensor_Data/SensorDataT.txt";
end

a = 1;
tablez = readtable(lib_datas{1,a});
nameID = data{1,1} + "/Sensor_Data/output_names.mat";
names = load(nameID);
names = names.Output_Names;
st = plot_ts(names,tablez);
%% Select groups of outputs to compare across tests
ts1 = [1,1,1,1;2,3,4,5];
ts2 = [1,1,1,1;9,10,11,157];
ts3 = [1,1,1,1;103,121,136,92];
ts_set = {ts1,ts2,ts3};
plotstitle = {"Confirmation of Test Setting","Shaft and Power","Blade Node"};
for i = 1:11
    batches = cell(1,1);
    for j = 1:3
        batches{1,1} = {readtable(lib_datas{1,i}),names,ts_set{1,j},plotstitle{j}};
        [f, rts] = plot_multi(batches);
        sttl = "Wind Direction Test = " + num2str(i);
        subtitle(sttl)
        % Add a script to save the file to a database of plots:
        % save into the experiment folder into a database folder called
        % Plots: 
        % these should be labeled by test number, ts#, type:multiplot
        saveID = "figure_"+num2str(i)+num2str(j)+".fig";
        savefig(f,saveID)
    end
end
%%
openfig("figure_12.fig","visible")

openfig("figure_62.fig","visible")

openfig("figure_112.fig","visible")

%% Now to make the OAT table of plots
% specify the start, stop, and number for the x axis for each experiment
xinfo = {{0,15,11},...
    {11.4*.5,11.4*1.5,11},...
    {-13,30,11},...
    {1.225*.9,1.225*1.1,11},...
    {.5,1,11},...
    {.5,1,11},{.5,1,11},{.5,1,11}};

% specify the row number of the output
number = 103;
% specify the name of the variable
subttl = "Blade 1 Region 1 Angle of Attack";


experiments_names = {"WindDir","WindSpeed","BladePitch","AirDensity"};

% specify names of varied inputs 
inputnames = {"Wind Direction (deg)", "Wind Speed (m/s)",...
    "Blade Pitch (deg)", "Air Density (kg/_{m^3})"};

f = figure;
f.Position(1:4) = [100 100 700 1100];
gmax = 0;
gmin = 100000;
for i = 1:4
    % Iterate Through the Experiments
    ExperimentID = "Data/"+experiments_names{1,i};

    F1tableID = ExperimentID+"/Experiment_f1.txt";

    tableF1 = readtable(F1tableID,"ReadRowNames",true);
    
    % Read each line of the table.
    names_of_rows = tableF1.Row;

    xs{i} = linspace(xinfo{1,i}{1},xinfo{1,i}{2},xinfo{1,i}{3});
    
    
    ys{i} = tableF1([string(names_of_rows(number))],:).Variables;
    
    lmin = min(ys{i});
    lmax = max(ys{i});
    if gmin>lmin
        gmin = lmin;
    end
    if gmax<lmax
        gmax = lmax;
    end
end

% Iterate again for plotting
for i = 1:4
    subplot(2,2,i)
    xvals = xs{i};
    yvals = ys{i};
    scatter(xvals,yvals,70,'filled')
    xlabel(inputnames{i})
    ylabel(names{number})
    ttl = "Output Dominant Frequency vs "+inputnames{i};
    title(ttl)
    subtitle(subttl)
    ax = gca;
    ax.XGrid = "on";
    ax.YGrid = "on";
    ax.FontSize = 7;
    ylim([gmin,gmax])
end


prt = "F1" + num2str(number) + "_OAT.pdf";   
print(gcf,prt,"-dpdf")

%% Now make a different plot for the erosion effects
f = figure;
f.Position(1:4) = [100 100 700 1100];
gmax = 0;
gmin = 100000;

experiments_names = {"ErosionBlade1Region1","ErosionBlade1Region2","ErosionBlade1Region3",...
    "ErosionBlade1Region4"};

% specify names of varied inputs 
inputnames = {"Blade1Erosion1",...
    "Blade1Erosion2","Blade1Erosion3","Blade1Erosion4"};

% specify the linspace(a,b,c) of the inputs
xinfo = {.5,1,11};

for i = 1:4
    % Iterate Through the Experiments
    ExperimentID = "Data/"+experiments_names{1,i};

    F1tableID = ExperimentID+"/Experiment_f1.txt";

    tableF1 = readtable(F1tableID,"ReadRowNames",true);
    
    % Read each line of the table.
    names_of_rows = tableF1.Row;

    xs{i} = linspace(xinfo{1},xinfo{2},xinfo{3});
    
    ys{i} = tableF1([string(names_of_rows(number))],:).Variables;
    
    lmin = min(ys{i});
    lmax = max(ys{i});
    if gmin>lmin
        gmin = lmin;
    end
    if gmax<lmax
        gmax = lmax;
    end
end

% Iterate again for plotting
lgd = cell(1,numel(inputnames));
for i = 1:numel(inputnames)
    hold on
    xvals = xs{i};
    yvals = ys{i};
    scatter(xvals,yvals,70,'filled')
    lgd{1,i} = inputnames{1,i};
end
if gmin == gmax
    gmin = gmax-1;
end
xlabel("Erosion Level")
ylabel(names{number})
ttl = "Output Dominant Frequency vs Erosion Regions";
title(ttl)
subtitle(subttl)
ax = gca;
ax.XGrid = "on";
ax.YGrid = "on";
ax.FontSize = 16;
ylim([gmin,gmax])
legend(lgd)


prt = "Erosion_MEAN" + num2str(number) + "_OAT.pdf";   
print(gcf,prt,"-dpdf")


