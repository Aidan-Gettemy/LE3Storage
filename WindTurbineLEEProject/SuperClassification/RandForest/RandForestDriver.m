clc;close;clear;
%% Designate Folder for plot results
% Subfolder for plots
plotID = "";

%% Load in Data Inputs and Outputs 

IntableID = "../../InTable_Train_1700.txt";
OuttableID = "../../OutTable_Train_1700.txt";

In = readtable(IntableID);
Out_all = readtable(OuttableID);

Out = categorical(Out_all(:,19).Variables);

% Testing Percentage = 15%
p = 0.15;
cvpart = cvpartition(Out,'holdout',p);

In_train = In(training(cvpart),:);
Out_train = Out(training(cvpart),:);

In_test = In(test(cvpart),:);
Out_test = Out(test(cvpart),:);

InNames = In.Properties.VariableNames;
OutName = 'ErosionClass';

%% Set up the Model/Train the Model
Mdl = fitcensemble(In_train,Out_train,...
    'PredictorNames',InNames,...
    'ResponseName',OutName,...
    'OptimizeHyperparameters',{'NumLearningCycles','MaxNumSplits','LearnRate'}, ...
    'HyperparameterOptimizationOptions',struct('Repartition',true, ...
    'AcquisitionFunctionName','expected-improvement-plus',...
    'UseParallel',false ...
    )...
   );
%% Save the Model
save("RF_class.mat",'Mdl');
%% Evaluate the Model and save the stats

Out_predict = Mdl.predict(In_test);

%% Plot and Save as .png files
figure
cm = confusionchart(Out_test,Out_predict);
cm.Title = 'Erosion Class Detection (4-classes): RandomForest';
cm.FontSize = 20;


%% Predictor Importance
imp = predictorImportance(Mdl);
[sorted_imp,isorted_imp] = sort(imp,'descend');

figure;
barh(imp(isorted_imp(1:20)));hold on;grid on;
barh(imp(isorted_imp(1:5)),'y');
barh(imp(isorted_imp(1:3)),'r');
title('Predictor Importance Estimates');
xlabel('Estimates with Curvature Tests');ylabel('Predictors');
set(gca,'FontSize',20);
set(gca,'TickDir','out');
set(gca,'LineWidth',2);
ax = gca;ax.YDir='reverse';ax.XScale = 'log';
%xlim([0.08 4])
%ylim([.25 24.75])
% label the bars
for i=1:20%length(Mdl.PredictorNames)
    text(...
        1.05*imp(isorted_imp(i)),i,...
        strrep(Mdl.PredictorNames{isorted_imp(i)},'_',''),...
        'FontSize',14 ...
    )
end


%%
t = randi(12,1,12);

a = linspace(1,100,12);

b = a([t]);
t
a
b