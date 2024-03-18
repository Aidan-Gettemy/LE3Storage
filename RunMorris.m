clc;close;clear
%% This will run the Morris Method Jobs
% We will engage the blade controller 

% Link the helper function
addpath funcs/

% Make sure that we have the right test points to run
M = readmatrix('Experiment_Points\Morris21_5T.txt');

%%
% ExperimentID: Where results will be held.
ExperimentID = "Data/Morris215t";

% StatusFileID: This stores which tests have already run
StatusFileID = "Morris215t_Status.txt";

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
bld_fix = 1;

% we average last seconds
trans = 40;


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

    % translate each input into the relevant range (inputs are between 0 and 1)
    vector(1,1) = 15*run_point(1,1);% wind direction
    vector(1,2) = 3+17*run_point(1,2);% wind speed
    vector(1,3) = 0;% start the blade pitch at 0;
    vector(1,4) = 1225*.95 + 1225*(0.1)*run_point(1,3); %air density
    vector(1,5:22) = run_point(1,4:21);
    
    % make erosion realistic

    for b = 1:3
        %region1-2
        vector(1,5+6*(b-1)) = .25*vector(1,5+6*(b-1));
        vector(1,6+6*(b-1)) = .25*vector(1,6+6*(b-1));
        %region3-4
        vector(1,7+6*(b-1)) = .5*vector(1,7+6*(b-1));
        vector(1,8+6*(b-1)) = .5*vector(1,8+6*(b-1));
        %region5-6
        vector(1,9+6*(b-1)) = vector(1,9+6*(b-1));
        vector(1,10+6*(b-1)) = vector(1,10+6*(b-1));
    end

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
M = readmatrix('Experiment_Points\Morris21_5T.txt');

% ExperimentID: Where results will be held.
ExperimentID = "Data/Morris215t";

% StatusFileID: This stores which tests have already run
StatusFileID = "Morris215t_Status.txt";

% This shows what each entry in the input vector holds

% Go ahead and make all the prep-folders and files
status = mkdir(ExperimentID);

% We must set the test duration:
test_dur = 180;

% blade pitch control (0=off, 1=on)
bld_fix = 1;

% we average last seconds
trans = 40;

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
    vector(1,1) = 15*run_point(1,1);% wind direction
    vector(1,2) = 3+17*run_point(1,2);% wind speed
    vector(1,3) = 0;% start the blade pitch at 0;
    vector(1,4) = 1225*.95 + 1225*(0.1)*run_point(1,3); %air density
    vector(1,5:22) = run_point(1,4:21);
    
    % make erosion realistic

    for b = 1:3
        %region1-2
        vector(1,5+6*(b-1)) = .25*vector(1,5+6*(b-1));
        vector(1,6+6*(b-1)) = .25*vector(1,6+6*(b-1));
        %region3-4
        vector(1,7+6*(b-1)) = .5*vector(1,7+6*(b-1));
        vector(1,8+6*(b-1)) = .5*vector(1,8+6*(b-1));
        %region5-6
        vector(1,9+6*(b-1)) = vector(1,9+6*(b-1));
        vector(1,10+6*(b-1)) = vector(1,10+6*(b-1));
    end

    % Set up the test
    [status,TestID] = set_up(vector, i, "Template_NREL5MW",...
    "Simulate_NREL5MW",test_dur,bld_fix);
    
    
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
trans0 = 40;% We will set the start of non-transitory behaviour to average over
data = gather_up(StatusFileID);
for i = 1:numel(data)
    trans = trans0;%reset on each iteration
    disp(data{i})
    line = split(data{i},"/");
    TestID = line{3};
    
    % Make big table
    % test_out = ExperimentID + "/" + TestID + "/" + TestID + ".out";
    % [test1outs,stat1] = create_mat_files(test_out);
    
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
