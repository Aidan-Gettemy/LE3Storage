%% Experiment with the Classifier App
% First, use the data table build with `JoinDataTables.mlx` to create a
% data set on which to do Machine Learning.  Then, once the appropriate
% dataset with a good class structure (designed into the experiment) has
% been made, run the Classifier App.  Next, export the best models to the
% workspace, and save them.

save('RF_Opt_4Class_TrainedModel.mat','-struct','RandFor_4ClassErModel');
save('Tree_4Class_TrainedModel.mat','-struct','TreeEr4Class');
save('NN_4Class_TrainedModel.mat','-struct','NN_ER4Class');

%% We can load in the model
clc;close;clear;
load("RF_Opt_4Class_TrainedModel.mat");
predImp = ClassificationEnsemble.predictorImportance;
y = array2table(ClassificationEnsemble.predictorImportance');
y.Properties.RowNames = ClassificationEnsemble.ExpandedPredictorNames;
ysorted = sortrows(y);

labels = ysorted.Properties.RowNames(200:end);
vals = ysorted(200:end,1).Variables;

barh(labels,vals);
title("Most Important Predictors")

%% Play around with it:

HowToPredict
DataT = readtable("/Volumes/ARG2024/4Class_ExpDataTable.txt");

DataT(:,616:634) = [];


% Perform cross-validation
partitionedModel = crossval(ClassificationEnsemble, 'KFold', 5);

% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');



Out = ClassificationEnsemble.Y;
% 
% 
% validation_fraction = .5;
% ipointer=1:length(DataT(:,1).Variables);
% cvpart=cvpartition(Out,'holdout',validation_fraction);
% 
% DataT_Test = DataT(test(cvpart),:);
% Out_True = Out(test(cvpart),1);
% 
% [Out_Predict,score] = ClassificationEnsemble.predict(DataT_Test);
%%
figure
plotconfusion(validationPredictions,Out)
saveas(gcf,'4ClassConfusion_Clean.png')
classNames = ClassificationEnsemble.ClassNames;
rocObj = rocmetrics(Out,validationScores,classNames);
rocObj.AUC
figure
plot(rocObj)
saveas(gcf,'4ClassROC_Clean.png')

%% Or, if we saved the train process as a function, call that here
[trainedclassifier,acc] = Er4ClassRFAdaboost(readtable("4Class_ExpDataTable.txt"));
%% Save figures
% title("Random Forest 94.5% Accuracy (5-fold)")
% saveas(gcf,'4ClassConfusionMatrix.png')
% title("Random Forest 94.5% Accuracy (5-fold)")
% saveas(gcf,'4ClassROC.png')
% title("NN 84.6% Accuracy (5-fold)")
% saveas(gcf,'4ROCNN.png')


