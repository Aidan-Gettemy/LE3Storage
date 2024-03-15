clc;close;clear;
%% TEST SETUP
% Verify the special wind setup file
readfile_ID = "Template_NREL5MW" + "/modules/wind/steady_wind.wnd";

writefile_ID = "Simulate_NREL5MW" + "/modules/wind/steady_wind.wnd";

addpath funcs\

start_speed = 7;
end_speed = 17;
testdur = 100;
numb = 6;

stat = special_wind(readfile_ID,writefile_ID,numb,...
    start_speed,end_speed,testdur);


%% Verify the set-up function
% ExperimentID: Where results will be held.
ExperimentID = "Data/Test";

% StatusFileID: This stores which tests have already run
StatusFileID = "Test_Status.txt";

% Link the helper function
addpath funcs/

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
test_dur = 160;

% blade pitch control (0=off, 1=on)
bld_fix = 1;

% Set the vector input
vector = [5,11.4,-1,1325,...
    0,0,0,0,0,0,...
        0,0,0,.5,.5,1,...
           0,0,0,0,0,0];
% test number
test_number = 3;

% Set up the test
[status,TestID] = set_up(vector, test_number, "Template_NREL5MW",...
"Simulate_NREL5MW",test_dur,bld_fix);
    
% Move the Results
lookfolder="Simulate_NREL5MW/";
status = move_clean(lookfolder,ExperimentID,TestID);

%% This is a demo area for debugging simulation runs

% ExperimentID: Where results will be held.
ExperimentID = "Data/MorrisDisasters";

% StatusFileID: This stores which tests have already run
StatusFileID = "MorrisDisasters_Status.txt";

% Specify the input runs

sampleM = zeros(3+5+5+1,21);
M = readmatrix('Morris21_6T');
offending_tests = [20,21,22,30,111,112,...
    113,114,115,119,120,121,122,123];
for jj = 1:numel(offending_tests)
    sampleM(jj,:) = M(offending_tests(jj),:);
end
%%
% We must set the test duration:
test_dur = 190;

% blade pitch control (0=off, 1=on)
bld_fix = 1;

% Run the Simulations

% As we go, write down the result folder of each completed test to a file
% that tracks the progress of the simulation
for i = 1:numel(sampleM(:,1))
    % Set the vector input
    vector = [0,11.4,0,1225,...
        0,0,0,0,0,0,...
            0,0,0,0,0,0,...
                0,0,0,0,0,0];

    run_point = sampleM(i,:);

    % translate each input into the relevant range
    vector(1,1) = 30*run_point(1,1);% wind direction
    vector(1,2) = 3+22*run_point(1,2);% wind speed
    vector(1,3) = 0;% start the blade pitch at 0;
    vector(1,4) = 1225*.95 + 1225*(0.1)*run_point(1,3);
    vector(1,5:22) = run_point(1,4:21);

    % Set up the test
    [status,TestID] = set_up(vector, i, "Template_NREL5MW",...
    "Simulate_NREL5MW",test_dur,bld_fix);
    
    executable = "openfast_x64";

    fastFileName = "Simulate_NREL5MW/" + TestID + ".fst";

    command = executable + " " + fastFileName;

    % Run the test
    [status,result] = system(command,'-echo');

    %   First Move the Results
    lookfolder="Simulate_NREL5MW/";
    status = move_clean(lookfolder,ExperimentID,TestID);
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

%% Now make the summary tables etc.
trans0 = 50; % We will set the start of non-transitory behaviour to average over
data = gather_up(StatusFileID);
for i = 1:numel(data)
    trans = trans0;%reset on each iteration
    disp(data{i})
    line = split(data{i},"/");
    TestID = line{3};
    
    % Make big table
    test_out = ExperimentID + "/" + TestID + "/" + TestID + ".out";
    [test1outs,stat1] = create_mat_files(test_out);
    
    % Now make the summary files
    SumID = ExperimentID + "/" + TestID + "/" +"Sensor_Data";
    tablename = "SensorDataT.txt";
    
    % Make this part adaptive in case of test failure
    proc = 0;
    while proc > 1
        try
            [status,len] = create_sum_table(SumID,tablename,trans);
            proc = 2;
            datacheck(i) = len; % for each data table we have saved, check if the experiment worked properly
            alphas(i) = trans;
        catch
            trans = .9*trans;
        end
    end
    
    % Delete the .out files  
    oldfolder = cd(ExperimentID+"/"+TestID);
    delete *out
    delete *outb
    cd(oldfolder)

end
for i =1:numel(datacheck)
    ftext = "Test "+num2str(i)+" lasted "+num2str(datacheck(i)/160)+ " seconds with trans = " + num2str(alphas(i));
    if datacheck(i)/160 < test_dur
        disp("WARNING-TEST ENDED PREMATURELY")
    end
    disp(output)
end
%% Now we can do some plotting:
% Create every experiment table
addpath funcs/

% ExperimentID: Where results will be held.
%ExperimentID = "Data/MorrisDisasters";

% StatusFileID: This stores which tests have already run
%StatusFileID = "MorrisDisasters_Status.txt";


experiments_names = {"MorrisDisasters"};

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
% ExperimentID: Where results will be held.
ExperimentID = "Data/MorrisDisasters";

% StatusFileID: This stores which tests have already run
StatusFileID = "MorrisDisasters_Status.txt";

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
        sttl = "Redo Morris Disasters = " + num2str(i);
        subtitle(sttl)
        % Add a script to save the file to a database of plots:
        % save into the experiment folder into a database folder called
        % Plots: 
        % these should be labeled by test number, ts#, type:multiplot
        saveID = "figure_"+num2str(i)+num2str(j)+".fig";
        savefig(f,saveID)
    end
end

%% And we are free to clean up the results
