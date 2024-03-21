clc;close;clear
%% This will run the Tests of Different Erosion States against various wind direction, speed, and air density conditions
% We will engage the blade controller 

% Link the helper function
addpath funcs/

% Make sure that we have the right test points to run
M = readmatrix('');

%%
% ExperimentID: Where results will be held.
ExperimentID = "Data/BigE2";

% StatusFileID: This stores which tests have already run
StatusFileID = "BigE2_Status.txt";

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
test_dur = 240;

% blade pitch control (0=off, 1=on)
bld_fix = 1;

% we average last seconds
trans = 45;


% Run the Simulations

% SET WHERE TO START THE TESTS
restart = 1;

% As we go, write down the result folder of each completed test to a file
% that tracks the progress of the simulation
for i = restart:numel(M(:,1))
    
    % Pick up where we left off:
    try
        data = gather_up(StatusFileID); % see if we already have the status file
        i = numel(data)+ restart;
    catch
        i = i;
    end

    % Set the vector input
    vector = [0,11.4,0,1225,...
            0,0,0,0,0,0,...
                0,0,0,0,0,0,...
                    0,0,0,0,0,0];
    run_point = M(i,:);

    % No need to translate each input into the relevant range, they are already set up
    vector(1,[1,2,4]) = run_point(1,1:3); % Wind and Air Dens
    vector(1,5:22)= run_point(1,4:21);% Erosion

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


    % As we go, write down the result folder of each completed test to status file:
    if i==restart
        test_cell = cell(1,i-restart+1);
        test_cell{1,1} = ExperimentID+"/"+TestID;
    else
        test_cell = cell(1,i-restart+1);
        data = gather_up(StatusFileID);
        for j = 1:numel(data)
            test_cell{1,j} = data{1,j};
        end
        test_cell{1,j+1} = ExperimentID+"/"+TestID;
    end
    fileID = fopen(StatusFileID,'w');
    fprintf(fileID,'%s\n',test_cell{:});
    fclose(fileID);
    % Indicate the progress:
    display = ['Currently finished with test ',num2str(i)];
    disp(display)
end
%% This will allow us to remake the statusfile
% Link the helper function
addpath funcs/

% Make sure that we have the right test points to run
M = readmatrix('');

% ExperimentID: Where results will be held.
ExperimentID = "Data/BigE2";

% StatusFileID: This stores which tests have already run
StatusFileID = "BigE2_Status.txt";

% We must set the test duration:
test_dur = 240;

% blade pitch control (0=off, 1=on)
bld_fix = 1;

% we average last seconds
trans = 45;

restart = 1;

for i = restart:numel(M(:,1))
    % Pick up where we left off:
    try
        data = gather_up(StatusFileID); % see if we already have the status file
        i = numel(data)+restart;
    catch
        i = i;
    end

    % Set the vector input
    vector = [0,11.4,0,1225,...
            0,0,0,0,0,0,...
                0,0,0,0,0,0,...
                    0,0,0,0,0,0];

    run_point = M(i,:);

    % translate each input into the relevant range (inputs are between 0 and 1)
    vector(1,[1,2,4]) = run_point(1,1:3); % Wind and Air Dens
    vector(1,5:22)= run_point(1,4:21);% Erosion

    % Set up the test
    TestID = remake_head();
    
    % As we go, write down the result folder of each completed test to status file:
    if i==restart
        test_cell = cell(1,i-restart+1);
        test_cell{1,1} = ExperimentID+"/"+TestID;
    else
        test_cell = cell(1,i-restart+1);
        data = gather_up(StatusFileID);
        for j = 1:numel(data)
            test_cell{1,j} = data{1,j};
        end
        test_cell{1,j+1} = ExperimentID+"/"+TestID;
    end
    fileID = fopen(StatusFileID,'w');
    fprintf(fileID,'%s\n',test_cell{:});
    fclose(fileID);
    % Indicate the progress:
    display = ['Currently finished with test ',num2str(i)];
    disp(display)
end

%% Now make the summary tables etc.

trans0 = 45;% We will set the start of non-transitory behaviour to average over

data = gather_up(StatusFileID);

for i = 1:numel(data)
    trans = trans0;%reset on each iteration
    disp(data{i})
    line = split(data{i},"/");
    TestID = line{3};
    
    % Make big table
    test_out = ExperimentID + "/" + TestID + "/" + TestID + ".out";
    [test1outs,stat1] = create_mat_files(test_out);

    % Make the times series of the generator output
    stat = save_genpwr_ts();
    % Also, save some relevant time series.
    stat = save_smalltab();
    
    % Now make the summary files
    SumID = ExperimentID + "/" + TestID + "/" +"Sensor_Data";
    tablename = "SensorDataT.txt";
    
    % Make this part adaptive in case of test failure
    proc = 0;
    while proc < 1
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
%% Now we can see if the summary tables were made correctly
for i =1:numel(datacheck)
    ftext = "Test "+num2str(i)+" lasted "+num2str(datacheck(i)/160)+ " seconds with trans = " + num2str(alphas(i));
    if datacheck(i)/160 < test_dur
        disp("WARNING-TEST ENDED PREMATURELY")
    end
    disp(ftext)
end
%% Don't run this until all the summary tables are successfully made

for i = 1:numel(data)
    disp(data{i})
    line = split(data{i},"/");
    TestID = line{3};
    % Delete the data table
    oldfolder = cd(ExperimentID+"/"+TestID+ "/" +"Sensor_Data");
    delete SensorDataT.txt
    cd(oldfolder)
    message = "deleted table " + TestID;
    disp(message)
end
