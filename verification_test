clc;close;clear;
%% We have to test if the setup is working

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
test_dur = 150;

% blade pitch control (0=off, 1=on)
bld_fix = 1;

% Where do we want to start averaging?
trans = 50; % this will take the maxtime-trans seconds

% Make sure that we have the right trajectories
M = readmatrix('Morris_Test_2.txt');

% Run the Simulations

% As we go, write down the result folder of each completed test to a file
% that tracks the progress of the simulation
for i = 1:1%numel(test_points)
    % Set the vector input
    vector = [0,11.4,0,1225,...
        0,0,0,0,0,0,...
            0,0,0,0,0,0,...
                0,0,0,0,0,0];

    run_point = M(i,:);

    % translate each input into the relevant range
    vector(1,1) = 30*run_point(1,1);% wind direction
    vector(1,2) = 3+22*run_point(1,2);% wind speed
    vector(1,3) = 0;% start the blade pitch at 0;
    vector(1,4) = 1225*.95 + 1225*(0.1)*run_point(1,3);
    vector(1,5:22) = run_point(1,4:21);

    % Set up the test
    [status,TestID] = set_up(vector, i, "Template_NREL5MW",...
    "Simulate_NREL5MW",test_dur,bld_fix);
    
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
