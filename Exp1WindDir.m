% EXPERIMENT 1: WIND DIRECTION
%% Step One: Simulation
clc;close;clear;
% first without blade pitch control

% Link the helper function
addpath funcs/

% ExperimentID: Where results will be held.
ExperimentID = "Data/WindDir";

% StatusFileID: This stores which tests have already run
StatusFileID = "WindDir_Status.txt";

% This shows what each entry in the input vector holds

% [wind direction, wind speed, blade pitch, air density, 
% blade_1_erosion_1,blade_1_erosion_2, blade_1_erosion_3,
%   blade_1_erosion_4, blade_1_erosion_5, blade_1_erosion_6,
% blade_2_erosion_1,blade_2_erosion_2, blade_2_erosion_3,
%   blade_2_erosion_4,blade_2_erosion_5, blade_2_erosion_6, 
% blade_3_erosion_1,blade_3_erosion_2, blade_3_erosion_3,
%   blade_3_erosion_4,blade_3_erosion_5, blade_3_erosion_6]

% Go ahead and make all the prep-folders and files
status = mkdir(ExperimentID);

% We must set the test duration:
test_dur = 180;

% blade pitch control (0=off, 1=on)
bld_fix = 0;

% we average last seconds
trans = 50;

% Test Points for Wind Direction
test_points = linspace(0,15,11);

% Run the Simulations

% As we go, write down the result folder of each completed test to a file
% that tracks the progress of the simulation
for i = 1:numel(test_points)
    % Set the vector input
    vector = [test_points(i),11.4,0,1225,...
        0,0,0,0,0,0,...
            0,0,0,0,0,0,...
                0,0,0,0,0,0];

    % Set up the test
    [status,TestID] = set_up(vector, i, "Template_NREL5MW",...
    "Simulate_NREL5MW",test_dur,bld_fix);
    
    %executable = "/Users/aidangettemy/anaconda3/bin/openfast";
    executable = "openfast_x64";

    fastFileName = "Simulate_NREL5MW/" + TestID + ".fst";

    command = executable + " " + fastFileName;

    % Run the test
    [status,result] = system(command,'-echo');
    
    % Create the Output Data Table and the Summary Table
    %   First Move the Results
    lookfolder="Simulate_NREL5MW/";
    status = move_clean(lookfolder,ExperimentID,TestID);
    %   Then create the data table
    
    % This is the address of the out file
    test_out = ExperimentID + "/" + TestID + "/" + TestID + ".out";
    [test1outs,stat1] = create_mat_files(test_out);

    % Now make the summary files
    SumID = ExperimentID + "/" + TestID + "/" +"Sensor_Data";
    tablename = "SensorDataT.txt";
    status = create_sum_table(SumID,tablename,trans);
    
    % Delete the .out files  
    oldfolder = cd(ExperimentID+"/"+TestID);
    delete *out
    delete *outb
    cd(oldfolder)
    % As we go, write down the result folder of each completed test to this
    % status file:
    n=1;
    if i>1
        test_cell = cell(1,n);
        data = gather_up(StatusFileID);
        for j = 1:numel(data)
            test_cell{1,j} = data{1,j};
        end
        test_cell{1,i} = ExperimentID+"/"+TestID;
    else
        test_cell = cell(1,n);
        test_cell{1,1} = ExperimentID+"/"+TestID;
    end
    fileID = fopen(StatusFileID,'w');
    fprintf(fileID,'%s\n',test_cell{:});
    fclose(fileID);
    % Indicate the progress:
    display = ['Currently finished with test ',num2str(i)];
    disp(display)
end
%% Step Two: Data Manipulation
% - here is where we make tables
%
% These are the same fileIDs as in Step One

addpath funcs/

% ExperimentID: Where results will be held.
ExperimentID = "Data/WindDir";

% StatusFileID: This stores which tests have already run
StatusFileID = "WindDir_Status.txt";

% Experimentname: This will be used for making the titles etc of the plots
exp_name = "Wind Direction";

% Select the number of experiment points
n = 21;

% Give the nominal value
nomval = 0;

min = nomval;
max = 30+nomval;

test_points = linspace(min,max,n);

% We must set the test duration:
test_dur = 180;

% blade pitch control (0=off, 1=on)
bld_fix = 0;

% We must set the test transient cut off:
test_trans = 120;

% Create the experiment table
data = gather_up(StatusFileID);
summary_tables = cell(1,n);
for i = 1:n
    summary_tables{1,i} = data{1,i} + ...        
        "/"+"Sensor_Data/SensorData_Mean_Std.txt";
end

% Make the experiment summary files
[mean_exp_table, std_exp_table] = full_exp_table(summary_tables);

% Save the experiment summary files
output_ID = ExperimentID + "/"+"Experiment_means.txt";
writetable(mean_exp_table,output_ID,'WriteRowNames',true)

output_ID = ExperimentID + "/"+"Experiment_stds.txt";
writetable(std_exp_table,output_ID,'WriteRowNames',true)

% Verification of Simulation Runs

lib_datas = cell(1,n);
for i = 1:n
    data = gather_up(StatusFileID);
    Testfolder = data{1,i};
    lib_datas{1,i} = Testfolder + "/" + "Sensor_Data/SensorDataT.txt";
end

data = gather_up(StatusFileID);

nameID = data{1,1} + "/Sensor_Data/output_names.mat";

names = load(nameID);
names = names.Output_Names;

% Use the MultiPlot Function 
% we will decide which outputs to plot
% we will save the figure as a .fig and a .pdf but not print it
ts1 = [1, 1, 1, 1, 1, 1,  1,  1, 1, 1, 1, 1;...
       3,47,53,34,51,52,154,155,27,35,30,11];
ts_set = {ts1};
for i = 1:n
    batches = cell(1,1);
    for j = 1:1
        batches{1,1} = {readtable(lib_datas{1,i}),names,ts_set{1,j}};
        rts = plot_multi(batches);
        ttl = "Plot Test " + num2str(i);
        title(ttl)
    end
end

% Next we can see which outputs had the most changes in mean and STD

meanID = ExperimentID + "/Experiment_means.txt";
stdID = ExperimentID + "/Experiment_stds.txt";
tableMEAN = readtable(meanID,"ReadRowNames",true);
tableSTD = readtable(stdID,"ReadRowNames",true);

% Read each line of the table.
names_of_rows = tableMEAN.Row;

for i = 1:numel(names_of_rows)
    normi(i) = spmet(tableMEAN(i,:).Variables);
    normistd(i) = spmet(tableSTD(i,:).Variables);
end

results_means_Table = table();
results_means_Table.SN = normi';
results_means_Table.Properties.RowNames = names_of_rows;

results_stds_Table = table();
results_stds_Table.SN = normistd';
results_stds_Table.Properties.RowNames = names_of_rows;

% -- fix this --
% depends on if blade pitch control is (0=off, 1=on)

% set any rows having to deal with windspeed, **blade pitch, wind
% direction, yaw position, and time to zero;

nope = ["YawPzn","WindHubAngXY","WindHubVelMag",...
    "WindHubVelX","WindHubVelY","WindHubVelZ","BldPitch1",...
    "BldPitch2","BldPitch3","B1Pitch","B2Pitch","B3Pitch",...
    "Time"];

results_stds_Table(nope,:) = table(zeros(numel(nope),1));
results_means_Table(nope,:) = table(zeros(numel(nope),1));

sortedmeans = rmmissing(sortrows(results_means_Table));
sortedstds = rmmissing(sortrows(results_stds_Table));

top_num = 24; % This is how many outputs we will show
labelsmeans = sortedmeans.Properties.RowNames(end-top_num:end);
valsmeans = sortedmeans(end-top_num:end,1).Variables;

labelsstds = sortedstds.Properties.RowNames(end-top_num:end);
valsstds = sortedstds(end-top_num:end,1).Variables;

% Finally, we can save plots and figures
plotsfolder = ExperimentID + "/" + "Plots";
mkdir(plotsfolder)

% Grab full tables of the key plots
table_holder = cell(1,3);
key_plots = [1,11,21];
for i = 1:3
    tableID = key_plots(i);
    data = gather_up(StatusFileID);
    Testfolder = data{1,tableID};
    pathtotable = Testfolder + "/" + "Sensor_Data/SensorDataT.txt";
    table_holder{1,i} = readtable(pathtotable);
end

% First we will plot the bar charts
f = figure;
f.Position(1:4) = [100 100 650 1100];
subplot(2,1,1)
barh(labelsmeans,valsmeans);
barchart_title_means = "Output Means most affected by " + exp_name;
title(barchart_title_means);

subplot(2,1,2)
barh(labelsstds,valsstds);
barchart_title_stds = "Output Standard Deviations most affected by " + exp_name;
title(barchart_title_stds)
prt = plotsfolder + "/" + "Bar_Chart.pdf";
print(gcf,prt,"-dpdf")

% Now we will plot the top five Means
for i = 0:4
    f = figure;
    f.Position(1:4) = [100 100 700 1100];
    xs = test_points;
    subplot(5,4,[1,2,5,6])
    hold on
    ys = tableMEAN([string(labelsmeans{end-i,1})],:).Variables;
    plot(xs,ys,LineWidth=2);
    xlabel(exp_name)
    yblb = labelsmeans{end-i,1} + " mean";
    ylabel(yblb)
    scatter(test_points(key_plots(1)),ys(key_plots(1)),50,'filled')
    scatter(test_points(key_plots(2)),ys(key_plots(2)),50,'filled')
    scatter(test_points(key_plots(3)),ys(key_plots(3)),50,'filled')
    ptl = labelsmeans{end-i,1}+" mean";
    a1 = exp_name + " = " + num2str(test_points(key_plots(1)));
    a2 = exp_name + " = " + num2str(test_points(key_plots(2)));
    a3 = exp_name + " = " + num2str(test_points(key_plots(3)));
    lgd = {ptl,a1,a2,a3};
    ttl = "Rank(M) " +num2str(i+1) +": Mean " + labelsmeans{end-i,1} + " vs " + exp_name;
    title(ttl);
    legend(lgd,'Location','southwest')
    hold off

    subplot(5,4,[3,4,7,8])
    hold on
    ys = tableSTD([string(labelsmeans{end-i,1})],:).Variables;
    plot(xs,ys,LineWidth=2);
    xlabel(exp_name)
    yblb = labelsmeans{end-i,1} + " std";
    ylabel(yblb)
    scatter(test_points(key_plots(1)),ys(key_plots(1)),50,'filled')
    scatter(test_points(key_plots(2)),ys(key_plots(2)),50,'filled')
    scatter(test_points(key_plots(3)),ys(key_plots(3)),50,'filled')
    ptl = labelsmeans{end-i,1}+" std";
    a1 = exp_name + " = " + num2str(test_points(key_plots(1)));
    a2 = exp_name + " = " + num2str(test_points(key_plots(2)));
    a3 = exp_name + " = " + num2str(test_points(key_plots(3)));
    lgd = {ptl,a1,a2,a3};
    legend(lgd,'Location','southwest')
    ttl = "Rank(M) " +num2str(i+1) +": Std " + labelsmeans{end-i,1} + " vs " + exp_name;
    title(ttl);
    hold off
    for j = 1:3
        a = 4*(2+j);
        subplot(5,4,[a-3,a-2,a-1,a])
        hold on
        data_table = table_holder{1,j};
        xs = data_table.Time;
        xs = xs';
        ys = eval("data_table."+labelsmeans{end-i,1});
        ys = ys';
        plot(xs,ys);
        xlabel("Time (s) ");
        ylabel(labelsmeans{end-i,1})
        ttl = labelsmeans{end-i,1} + " " + exp_name + " = " +...
            num2str(test_points(key_plots(j)));
        plot([70,70],[min(ys),max(ys)],LineStyle=":",LineWidth=3)
        pltttl = labelsmeans{end-i,1} +": "+exp_name+" = " + num2str(test_points(key_plots(j)));
        lgd = {pltttl,"post-transients"};
        legend(lgd,'Location','southwest')
        %title(ttl) 
        hold off
    end
    prt = plotsfolder + "/" + "MEAN_RANK" + num2str(i+1)+".pdf";
    
    print(gcf,prt,"-dpdf")
end

% and we will plot the top five stds
for i = 0:4
    f = figure;
    f.Position(1:4) = [100 100 700 1100];
    xs = test_points;
    subplot(5,4,[1,2,5,6])
    hold on
    ys = tableSTD([string(labelsstds{end-i,1})],:).Variables;
    plot(xs,ys,LineWidth=2);
    xlabel(exp_name)
    yblb = labelsstds{end-i,1} + " std";
    ylabel(yblb)
    scatter(test_points(key_plots(1)),ys(key_plots(1)),50,'filled')
    scatter(test_points(key_plots(2)),ys(key_plots(2)),50,'filled')
    scatter(test_points(key_plots(3)),ys(key_plots(3)),50,'filled')
    ptl = labelsstds{end-i,1}+" std";
    a1 = exp_name + " = " + num2str(test_points(key_plots(1)));
    a2 = exp_name + " = " + num2str(test_points(key_plots(2)));
    a3 = exp_name + " = " + num2str(test_points(key_plots(3)));
    lgd = {ptl,a1,a2,a3};
    legend(lgd,'Location','southwest')
    ttl = "Rank(STD) " +num2str(i+1) +": STD " + labelsstds{end-i,1} + " vs " + exp_name;
    title(ttl);
    hold off
    subplot(5,4,[3,4,7,8])
    hold on
    ys = tableMEAN([string(labelsstds{end-i,1})],:).Variables;
    plot(xs,ys,LineWidth=2);
    xlabel(exp_name)
    yblb = labelsstds{end-i,1} + " mean";
    ylabel(yblb)
    scatter(test_points(key_plots(1)),ys(key_plots(1)),50,'filled')
    scatter(test_points(key_plots(2)),ys(key_plots(2)),50,'filled')
    scatter(test_points(key_plots(3)),ys(key_plots(3)),50,'filled')
    ptl = labelsstds{end-i,1}+" mean";
    a1 = exp_name + " = " + num2str(test_points(key_plots(1)));
    a2 = exp_name + " = " + num2str(test_points(key_plots(2)));
    a3 = exp_name + " = " + num2str(test_points(key_plots(3)));
    lgd = {ptl,a1,a2,a3};
    legend(lgd,'Location','southwest')
    ttl = "Rank(STD) " +num2str(i+1) +": Mean " + labelsstds{end-i,1} + " vs " + exp_name;
    title(ttl);
    hold off
    for j = 1:3
        a = 4*(2+j);
        subplot(5,4,[a-3,a-2,a-1,a])
        hold on
        data_table = table_holder{1,j};
        xs = data_table.Time;
        xs = xs';
        ys = eval("data_table."+labelsstds{end-i,1});
        ys = ys';
        plot(xs,ys);
        xlabel("Time (s) ");
        ylabel(labelsstds{end-i,1})
        ttl = labelsstds{end-i,1}  + " " + exp_name + " = " +...
            num2str(test_points(key_plots(j)));
        plot([70,70],[min(ys),max(ys)],LineStyle=":",LineWidth=3)
        pltttl = labelsstds{end-i,1} +": "+exp_name+" = " + num2str(test_points(key_plots(j)));
        lgd = {pltttl,"post-transients"};
        legend(lgd,'Location','southwest')
        %title(ttl) 
        hold off
    end
    prt = plotsfolder + "/" + "STD_RANK" + num2str(i+1)+".pdf";
    print(gcf,prt,"-dpdf")
end
%_______________________________________________________________________%
function spnorm = spmet(fx)
    % Input: vector of function values
    % Output: scalar rep. norm
    sum = 0;
    difs = 0;
    for i=1:(numel(fx)-1)
        sum = sum + abs(fx(i));
        difs = difs + abs(fx(i+1) - fx(i));
    end
    spnorm = (1/sum)*difs*numel(fx);
end