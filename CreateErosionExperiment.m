clc;close;clear;
% Create the design points for the erosion vs windspeed etc experiment:

% Wind Speed Experiment, Wind Direction Experiment, Air Density Experiment
batches = {[5,10,15,20,25,30,35,40],[3,5,7,9,11,13,15,17,19,21],...
    1225*[.85,.9,.95,.1,1.05,1.1,1.15]};

% Set One: change 1 region at a time on 1 blade
A = zeros(6,18);
A(1:6,1:6) = eye(6);
sets{1} = A;
% Set Two: change 1 region at a time on all blades
B = zeros(6,18);
for i = 1:6
    B(i,[i,i+6,i+12]) = ones(1,3);
end
sets{2} = B;
% Set Three: uniform erosion 
sets{3} = ones(1,18);
% Set Four.1: erosion type 1
sets{4} = 1/4*[1,1,2,2,4,4,1,1,2,2,4,4,1,1,2,2,4,4];
% Set Four.2: erosion type 2
sets{5} = [1:6,1:6,1:6]*1/6;
% Set Four.3: erosion type 3 
sets{6} = ([1:6,1:6,1:6]*1/6).^2;

% Erosion levels 
erlevel{1} = [1,2,3]*1/3;
erlevel{2} = [1,2,3]*1/3;
erlevel{3} = [1,2,3]*1/3;
erlevel{4} = [0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1];
erlevel{5} = [0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1];
erlevel{6} = [0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1];
iter = 1;

Design = zeros(1,21);
nom = [0,11.4,1225]; % when we don't change it, leave the wind settings at baseline
for i = 1:3
    % for each experiment
    % select the points
    chg = batches{i};
    for j = 1:6
        % for each test
        % select the set
        Testset = sets{j};
        for h = 1:numel(Testset(:,1))
            % for each row in the test set
            for k = 1:numel(erlevel{j})
                for s = 1:numel(chg)
                    Design(iter,1:3) = nom;
                    Design(iter,i) = chg(s);
                    Design(iter,4:21) = Testset(h,:)*erlevel{j}(k);
                    iter = iter + 1;
                end
            end
        end
    end
end
%%
% Now this is a big data set to try to run.  Let us start by picking an
% experiment to actually run.
% For this experiment, we will pick the one region all blades, 4.1, and 4.3 patterns.  We will iterate through different erosion levels, 
% and for each level, we will iterate through 10 wind speeds -- 400 tests.give to 4 computers for 1 hour

% Run the code again but only on these inputs
Design = zeros(1,21);
iter = 1;
nom = [0,11.4,1225]; % when we don't change it, leave the wind settings at baseline
for i = 2 % wind speed
    % for each experiment
    % select the points
    chg = batches{i};
    for j = [2,4,6] % Two and Four.1 and Four.3
        % for each test
        % select the set
        Testset = sets{j};
        for h = 1:numel(Testset(:,1))
            % for each row in the test set
            for k = 1:numel(erlevel{j})
                for s = 1:numel(chg)
                    Design(iter,1:3) = nom;
                    Design(iter,i) = chg(s);
                    Design(iter,4:21) = Testset(h,:)*erlevel{j}(k);
                    iter = iter + 1;
                end
            end
        end
    end
end

save("WvEtest2.txt","Design","-ascii")
