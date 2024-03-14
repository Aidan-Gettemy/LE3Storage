% we want to select points in an input space via a latin hyper-cube design
% and then plot them against one another
%
% but allow for more input partitions

% input space dimension
dim = 21;

% number of test points
num = 220;

X = lhsdesign(num,dim,'Criterion','correlation','iterations',5);

% gplotmatrix(X,[])
% title("Plot of Input Variables Against Each Other")
for i=1:3
    figure
    hold on
    for j = i+1:21
        scatter(X(:,i),X(:,j),"filled")
        ttl = num2str(i) +" vs all other dimensions";
        title(ttl)
    end
end

%%
save("LHC_220.txt","X","-ascii")
%%
% Check that I can read the file generated 
M = readmatrix('LHC_220.txt');
