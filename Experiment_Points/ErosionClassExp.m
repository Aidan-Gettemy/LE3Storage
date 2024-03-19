% The goal of this code is to generate a data set with several different
% classes of erosion.  For this first experiment we will define 3 different
% states of erosion.  
% - Mild
% - Moderate
% - Severe
% For each state, we will erode all 3 blades the same.

% For Mild, we define the mild multiplier as positive numbers less than 1 
% drawn from a normal distribution centered at 0.25

% For Moderate, we define the moderate multiplier as positive numbers
% less than 1 drawn from a normal distribution centered at 0.5

% For Severe, we define the severe multiplier as positive numbers less than
% 1 drawn from a normal distribution centered at 0.75

% For Each class the STD will be .125


% We will also include a fully "clean" set 

% We will set up all the points here, so that when we run the test, no
% further changes are needed

% input space dimension
dim = 3;

% number of test points
num = 240;

X = lhsdesign(num,dim,'Criterion','correlation','iterations',7);

%% Set the Multipliers
mildm = normrnd(.25,.125,[60,18]);
moderatem = normrnd(.5,.125,[60,18]);
severem = normrnd(.75,.125,[60,18]);

mildm = trnct_dist(mildm);
moderatem = trnct_dist(moderatem);
severem = trnct_dist(severem);

M = zeros(numel(X(:,1)),21);

% Iterate through the design, and set each column appropriately 
for i =1:numel(X(:,1))
    M(i,1) = 15*X(i,1); % Set wind direction
    M(i,2) = 3+17*X(i,2); % Set wind speed
    M(i,3) = 1225*.95+.1*1225*X(i,3); % Set the air density

    % Then we set the erosion.
    if i<61
        M(i,4:21) = zeros(1,18); % Control Group
    else
        if i<121
            mult = mildm;% Mild group 61-120
        elseif i < 181
            mult = moderatem; % Moderate group 121-180
        else
            mult = severem; % Severe group 181-240
        end

        for b = 1:3 % Set up realistic erosion
            %region1-2 are least eroded
            M(i,4+6*(b-1)) = mult(mod(i-1,60)+1,1+6*(b-1))*.25;
            M(i,5+6*(b-1)) = mult(mod(i-1,60)+1,2+6*(b-1))*.25;
            %region3-4 are mildly eroded
            M(i,6+6*(b-1)) = mult(mod(i-1,60)+1,3+6*(b-1))*.5;
            M(i,7+6*(b-1)) = mult(mod(i-1,60)+1,4+6*(b-1))*.5;
            %region5-6 are most eroded
            M(i,8+6*(b-1)) = mult(mod(i-1,60)+1,5+6*(b-1));
            M(i,9+6*(b-1)) = mult(mod(i-1,60)+1,6+6*(b-1));
        end
    end

end

save("Erosion4Classes.txt","M","-ascii")

%%
function boxed_in = trnct_dist(mildm)
    for k = 1:numel(mildm(:,1))
        for i =1:numel(mildm(k,:))
            if mildm(k,i) < 0
                mildm(k,i) = 0;
            end
            if mildm(k,i) > 1
                mildm(k,i) = 1;
            end
        end
    end
    boxed_in = mildm;
end