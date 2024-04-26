clc;close;clear;
%% Designate Folder for plot results
% Subfolder for plots
plotID = "Evaluation";
mkdir("Evaluation")

%% Load in Data Inputs and Outputs 

tableID = "../../4Class_ExpDataTable.txt";

rawTable = readtable(tableID);

In = rawTable(:,1:310);
Out = categorical(rawTable(:,634).Variables);

% Testing Percentage = 20%
p = 0.2;
cvpart = cvpartition(Out,'holdout',p);

In_train = In(training(cvpart),:);
Out_train = Out(training(cvpart),:);

In_test = In(test(cvpart),:);
Out_test = Out(test(cvpart),:);

InNames = In.Properties.VariableNames;
OutName = 'ErosionClass';

%% Set up the Model/Train the Model/Load Model
tree = load(fileID);tree=tree.tree;
%tree = fitctree(In_train,Out_train);
%% Save the Model
save("tree_class.mat",'tree');
%% Evaluate the Model


[Out_predict_train,scores_train] = tree.predict(In_train);

[Out_predict_test,scores_test] = tree.predict(In_test);

rocObj_train = rocmetrics(Out_train,scores_train,tree.ClassNames);

rocObj_test = rocmetrics(Out_test,scores_test,tree.ClassNames);

AUC_train = rocObj_train.AUC;
AUC_test = rocObj_test.AUC;

line1 = "Train: ";
line2 = "Test: ";
cats = categories(tree.ClassNames);
for i = 1:numel(cats)
    line1 = line1+"("+cats(i)+", "+num2str(AUC_train(i))+") ";
    line2 = line2+"("+cats(i)+", "+num2str(AUC_test(i))+") ";
end
disp(line1)
disp(line2)
% E_train = rmse(Out_predict_train, Out_train);
% E_test = rmse(Out_predict_test, Out_test);
% 
% disp("RMSE Training: " + num2str(E_train));
% disp("RMSE Testing: " + num2str(E_test));
% 
% Cc_train = corrcoef(Out_predict_train, Out_train);
% Cc_test = corrcoef(Out_predict_test, Out_test);
% 
% disp("CC Training: " + num2str(Cc_train));
% disp("CC Testing: " + num2str(Cc_test));
file_cell = {line1,line2};
file_name = plotID+"/summary_stats.txt";
fileID = fopen(file_name,'w');
fprintf(fileID,'%s\n',file_cell{:});
fclose(fileID);
%% Plot and Save as .png files

figure
cm = confusionchart(Out_test,Out_predict_test);
cm.Title = 'Erosion Class Detection (4-classes): Tree';
cm.FontSize = 20;

figure
rocObj_test.plot

%% Try a Shapely Value test

explainer1 = shapley(tree.tree,In_test);

newExplainer = fit(explainer1,In_test(13,:));

plot(newExplainer)