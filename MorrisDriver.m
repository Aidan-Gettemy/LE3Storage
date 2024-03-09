clc;close;clear
%% This will run the Morris Experiments
% We will engage the blade controller 

% Link the helper function
addpath funcs/

% Make sure that we have the right trajectories
M = readmatrix('Morris_Test_2.txt');

% ExperimentID: Where results will be held.
ExperimentID = "Data/Morris2";

% StatusFileID: This stores which tests have already run
StatusFileID = "Morris2_Status.txt";

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
test_dur = 200;

% blade pitch control (0=off, 1=on)
bld_fix = 1;

% we average last seconds
trans = 50;


% Run the Simulations

% As we go, write down the result folder of each completed test to a file
% that tracks the progress of the simulation
for i = 69:69%numel(M(:,1))
    % Pick up where we left off:
    % try
    %     data = gather_up(StatusFileID); % see if we already have the status file
    %     i = numel(data)+ 1;
    % catch
    %     i = i;
    % end

    % Set the vector input
    vector = [0,11.4,0,1225,...
            0,0,0,0,0,0,...
                0,0,0,0,0,0,...
                    0,0,0,0,0,0];
    run_point = M(i,:);

    % translate each input into the relevant range
    vector(1,1) = 30*run_point(1,1);% wind direction
    vector(1,2) = 4+20*run_point(1,2);% wind speed
    vector(1,3) = 0;% start the blade pitch at 0;
    vector(1,4) = 1225*.95 + 1225*(0.1)*run_point(1,3);
    vector(1,5:22) = run_point(1,4:21);

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
    if i>1
        test_cell = cell(1,i);
        data = gather_up(StatusFileID);
        for j = 1:numel(data)
            test_cell{1,j} = data{1,j};
        end
        test_cell{1,i} = ExperimentID+"/"+TestID;
    else
        test_cell = cell(1,i);
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
trans = .5;
data = gather_up(StatusFileID);
for i = 69:69%numel(data)
    disp(data{i})
    line = split(data{i},"/");
    TestID = line{3};
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
end

%%
% This is the address of the out file
test_out = ExperimentID + "/" + TestID + "/" + TestID + ".out";
[test1outs,stat1] = create_mat_files(test_out);

% Now make the summary files
SumID = ExperimentID + "/" + TestID + "/" +"Sensor_Data";
tablename = "SensorDataT.txt";
status = create_sum_table(SumID,tablename);

% Delete the .out files  
oldfolder = cd(ExperimentID+"/"+TestID);
delete *out
delete *outb
cd(oldfolder)
