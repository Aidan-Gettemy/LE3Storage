clc;close;clear;
%% One at a Time Analysis Maker
% Create every experiment table
addpath funcs/

experiments_names = {"WindDir","WindSpeed",...
    "BladePitch","AirDensity","ErB1R1","ErB1R2"};

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
    [mean_exp_table, std_exp_table] = full_exp_table(summary_tables);
    
    % Save Those Tables
    output_ID = ExperimentID + "/"+"Experiment_means.txt";
    writetable(mean_exp_table,output_ID,'WriteRowNames',true)
    
    output_ID = ExperimentID + "/"+"Experiment_stds.txt";
    writetable(std_exp_table,output_ID,'WriteRowNames',true)
end

%% Next we can see plot outputs changes in mean etc

ExperimentID = "Data/AirDensity";
StatusID = "AirDensity_Status.txt";

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
%%
ts1 = [1,1,1,1;2,3,4,5];
b = 9:20;a=ones(1,numel(b));
ts2 = [a;b];
ts3 = [1,1,1,1;203,265,266,69];
ts_set = {ts1,ts2,ts3};
plotstitle = {"Status Check","Shaft Outputs","Generator Outputs"};
for i = 1:11
    batches = cell(1,1);
    for j = 1:3
        batches{1,1} = {readtable(lib_datas{1,i}),names,ts_set{1,j},plotstitle{j}};
        rts = plot_multi(batches);
        sttl = "AirDensity = " + num2str(1.1025 + (i-1)*0.0245);
        subtitle(sttl)
        % Add a script to save the file to a database of plots:
        % save into the experiment folder into a database folder called
        % Plots: 
        % these should be labeled by test number, ts#, type:multiplot
    end
end

%%
% specify the start, stop, and number for the x axis for each experimet
xinfo = {{0,15,11},...
    {11.4*.8,11.4*1.2,11},...
    {-5,5,11},...
    {1225*.9,1225*1.1,11},...
    {0,.2,11},...
    {0,.2,11}};

% specify the row number of the output
number = 81;
% specify the name of the variable
subttl = "Tower Base Side-Side Shear Force";


% specify names of varied inputs 
inputnames = {"Wind Direction (deg)", "Wind Speed (m/s)",...
    "Blade Pitch (deg)", "Air Density (kg/_{m^3})", "Erosion Blade 1 Region 1 (-)",...
    "Erosion Blade 1 Region 2 (-)"};

f = figure;
f.Position(1:4) = [100 100 700 1100];
gmax = 0;
gmin = 100000;
for i = 1:6
    % Iterate Through the Experiments
    ExperimentID = "Data/"+experiments_names{1,i};

    meantableID = ExperimentID+"/Experiment_means.txt";

    tableMEAN = readtable(meantableID,"ReadRowNames",true);
    
    % Read each line of the table.
    names_of_rows = tableMEAN.Row;

    xs{i} = linspace(xinfo{1,i}{1},xinfo{1,i}{2},xinfo{1,i}{3});
    
    
    ys{i} = tableMEAN([string(names_of_rows(number))],:).Variables;
    
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
for i = 1:6
    subplot(2,3,i)
    xvals = xs{i};
    yvals = ys{i};
    scatter(xvals,yvals,70,'filled')
    xlabel(inputnames{i})
    ylabel(names{number})
    ttl = "Output Mean vs "+inputnames{i};
    title(ttl)
    subtitle(subttl)
    ax = gca;
    ax.XGrid = "on";
    ax.YGrid = "on";
    ax.FontSize = 7;
    ylim([gmin,gmax])
end


prt = "MEAN" + num2str(number) + "_OAT.pdf";   
print(gcf,prt,"-dpdf")

