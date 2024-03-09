% EXPERIMENT 5: EROSION BLADE 1 REGION 1
%% Step One: Simulation
clc;close;clear;
% first without blade pitch control

% Link the helper function
addpath funcs/

% ExperimentID: Where results will be held.
ExperimentID = "Data/ErB1R1";

% StatusFileID: This stores which tests have already run
StatusFileID = "ErB1R1_Status.txt";

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
test_points = linspace(0,.2,11);

% Run the Simulations

% As we go, write down the result folder of each completed test to a file
% that tracks the progress of the simulation
for i = 1:numel(test_points)
    % Set the vector input
    vector = [0,11.4,0,1225,...
        test_points(i),0,0,0,0,0,...
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