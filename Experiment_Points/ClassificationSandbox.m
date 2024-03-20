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
load("RF_Opt_4Class_TrainedModel.mat")
%% Or, if we saved the train process as a function, call that here
[trainedclassifier,acc] = Er4ClassRFAdaboost(readtable("4Class_ExpDataTable.txt"));
%% Save figures
% title("Random Forest 94.5% Accuracy (5-fold)")
% saveas(gcf,'4ClassConfusionMatrix.png')
% title("Random Forest 94.5% Accuracy (5-fold)")
% saveas(gcf,'4ClassROC.png')
title("NN 84.6% Accuracy (5-fold)")
saveas(gcf,'4ROCNN.png')

