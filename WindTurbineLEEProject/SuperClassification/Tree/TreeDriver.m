clc;close;clear;
%% Designate Folder for plot results
% Subfolder for plots
plotID = "Evaluation/";
mkdir("Evaluation/")

%% Load in Data Inputs and Outputs 

InTraintableID = "../../InTable_Train_1700.txt";
InTesttableID = "../../InTable_Test_1700.txt";

OutTraintableID = "../../OutTable_Train_1700.txt";
OutTesttableID = "../../OutTable_Test_1700.txt";

In_train = readtable(InTraintableID);

In_test = readtable(InTesttableID);

Out_train = readtable(OutTraintableID);

Out_test = readtable(OutTesttableID);

% Just predict the class
Out_train = categorical(Out_train(:,19).Variables);
Out_test = categorical(Out_test(:,19).Variables);

InNames = In_train.Properties.VariableNames;
OutName = "ErosionAgeClass";

% Now, assemble a matrix of the selected predictors for each output
%predimpID = "../../FeatureSelection/.txt";
%Importances=readmatrix(predimpID); (:,Importances(i,1:20))

%% Set up the Model/Train the Model
Mdl = fitctree(In_train,Out_train,...
    'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus'));

% Save the Model
save("tree_class.mat",'Mdl');
%% Evaluate the Model

[Out_predict_train,scores_train] = Mdl.predict(In_train);

[Out_predict_test,scores_test] = Mdl.predict(In_test);

rocObj_train = rocmetrics(Out_train,scores_train,Mdl.ClassNames);

rocObj_test = rocmetrics(Out_test,scores_test,Mdl.ClassNames);

AUC_train = rocObj_train.AUC;
AUC_test = rocObj_test.AUC;

line1 = "Train: ";
line2 = "Test: ";
cats = categories(Mdl.ClassNames);
for i = 1:numel(cats)
    line1 = line1+"("+cats(i)+", "+num2str(AUC_train(i))+") ";
    line2 = line2+"("+cats(i)+", "+num2str(AUC_test(i))+") ";
end
disp(line1)
disp(line2)
% Save the AUC metrics: table with the average AUC training, AUC testing
results = [mean(AUC_train),mean(AUC_test)];
T = array2table(results,'VariableNames',{'avg AUC train','avg AUC test'});
writetable(T,'ScoreTable.txt');
%% Plot and Save as .png files

% Training
figure
cm = confusionchart(Out_train,Out_predict_train);
cm.Title = 'Tree: Training';
cm.FontSize = 20;
saveID = plotID+"CM_train.png";
print('-dpng',saveID)

% Grab the internal data
n = numel(Mdl.ClassNames);
x = get(rocObj_train.plot);
turbocustom=turbo(n);
colors = interp1(linspace(0, 24, n), turbocustom, linspace(0,24,n));
f = figure;
f.Position = [100 100 800 500];
set(gca, 'ColorOrder', colors , 'NextPlot', 'replacechildren');
hold on
vals = linspace(0,24,17);
for i = 1:numel(x)
    lgd{i} = [num2str(vals(i))+" (AUC = "+num2str(AUC_train(i))+")"];
    xdats = x(i).XData;
    ydats = x(i).YData;
    plot(xdats,ydats,'LineWidth',3)
end
grid on
plot([0,1],[0,1],'LineStyle','--','LineWidth',4)
lgd{i+1} = ["1:1"];
xlabel("Flase Positive Rate")
ylabel("True Positive Rate")
title("Tree: ROC Training")
fontsize(16,"points")
legend(lgd,'Location','eastoutside')
colormap(turbo(n))
cb = colorbar;
saveID = plotID+"ROC_train.png";
print('-dpng',saveID)

% Testing
figure
cm = confusionchart(Out_test,Out_predict_test);
cm.Title = 'Tree: Testing';
cm.FontSize = 20;
saveID = plotID+"CM_test.png";
print('-dpng',saveID)

% Grab the internal data
n = numel(Mdl.ClassNames);
x = get(rocObj_test.plot);
turbocustom=turbo(n);
colors = interp1(linspace(0, 24, n), turbocustom, linspace(0,24,n));
f = figure;
f.Position = [100 100 800 500];
set(gca, 'ColorOrder', colors , 'NextPlot', 'replacechildren');
hold on
vals = linspace(0,24,17);
for i = 1:numel(x)
    lgd{i} = [num2str(vals(i))+" (AUC = "+num2str(AUC_test(i))+")"];
    xdats = x(i).XData;
    ydats = x(i).YData;
    plot(xdats,ydats,'LineWidth',3)
end
grid on
plot([0,1],[0,1],'LineStyle','--','LineWidth',4)
lgd{i+1} = ["1:1"];
xlabel("Flase Positive Rate")
ylabel("True Positive Rate")
title("Tree: ROC Testing")
fontsize(16,"points")
legend(lgd,'Location','eastoutside')
colormap(turbo(n))
cb = colorbar;
saveID = plotID+"ROC_test.png";
print('-dpng',saveID)
