clc;close;clear;
%% Designate Folder for plot results
% Subfolder for plots
plotID = "Plots/";
mkdir Plots
%% Load in Data Inputs and Outputs 

IntableID = "../InTable_Train_1700.txt";
OuttableID = "../OutTable_Train_1700.txt";

In = readtable(IntableID);
Out_all = readtable(OuttableID);

Out = Out_all(:,1:18); % Regression for blade erosion levels

% Testing Percentage = 25%
p = 0.25;
cvpart = cvpartition(numel(Out(:,1)),'holdout',p);

In_train = In(training(cvpart),:);
Out_train = Out(training(cvpart),:);

In_test = In(test(cvpart),:);
Out_test = Out(test(cvpart),:);

% Scale the variables
[In_train_scale,C,S] = normalize(In_train);
In_test_scale = normalize(In_test,"center",C,"scale",S);

InNames = In.Properties.VariableNames;
OutNames = Out.Properties.VariableNames;

%% Set up the Model/Train the Model

% For each output, train the model, and then get the best predictors
for i = 1:numel(OutNames)
    disp(OutNames{i})
    OutName = OutNames{i};
    Mdl = fitrensemble(In_train_scale,Out_train(:,i).Variables,...
    'PredictorNames',InNames,...
      'ResponseName',OutName);
    % Save the Model
    %save("RF_reg.mat",'Mdl');
    Out_predict_train = Mdl.predict(In_train_scale);
    Out_predict_test = Mdl.predict(In_test_scale);

    R_train = corrcoef(Out_predict_train,Out_train(:,i).Variables);
    R_tr(1,i) = R_train(1,2);
    R_test = corrcoef(Out_predict_test,Out_test(:,i).Variables);
    R_te(1,i) = R_test(1,2);

    mseTrain(i) = sum((Out_predict_train - Out_train(:,1).Variables).^2)/length(Out_predict_train);
    mseTest(i) = sum((Out_predict_test - Out_test(:,1).Variables).^2)/length(Out_predict_test);
    
    % Save the Scatter Plot
    figure
    plot(Out_train(:,i).Variables,Out_train(:,i).Variables,'LineWidth',10)
    hold on
    scatter(Out_train(:,i).Variables,Out_predict_train,20,'og','filled')
    scatter(Out_test(:,i).Variables,Out_predict_test,20,'or','filled')
    hold off
    grid on
    legend_text = {...
        ['1:1'],...
        ['Training Data (R ' num2str(R_tr(1,i)) ')'],...
        ['Testing Data (R ' num2str(R_te(1,i)) ')']};
    legend(legend_text,'Location','southeast','FontSize',15);
    xlabel("Actual " + OutName,FontSize=20)
    ylabel("Estimated "+OutName,FontSize=20)
    title("Scatter Diagram for "+OutName, 'FontSize',25);
    set(gca,'FontSize',16);
    set(gca,'LineWidth',2);
    saveID = plotID+OutName+"scatter.png";
    print('-dpng',saveID)
    % Save the predictor importances
    % Save the predictor barchart
end
% 
% 

%% Evaluate the Model and save the stats

Out_predict = Mdl.predict(In_test_scale);

%% Plot and Save as .png files
figure



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

