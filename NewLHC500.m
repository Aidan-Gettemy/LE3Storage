clc;close;clear;

rng("default")  % Set the random seed for reproducibility

num = 500;
dim = 9; % Three env. vars, and one var for each blade erosion region

X = lhsdesign(num,dim,'Criterion','correlation','iterations',30);

% Now map the first three variables to the appropriate ranges.
% and change it to the right input format (blades are identical)
for i =1:numel(X(:,1))
    M(i,1) = 25*X(i,1); % Set wind direction
    M(i,2) = 3+22*X(i,2); % Set wind speed
    M(i,3) = 1225*.9+.2*1225*X(i,3); % Set the air density

    % Then we set the erosion.
    for j = 1:6
        M(i,3+[j,j+6,j+12]) = X(i,3+j);
    end
        
end

save("LHC500.txt","M","-ascii")