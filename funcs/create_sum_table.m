function status = create_sum_table(directory,in_table,loc)
%CREATE_SUM_TABLE go to the directory and make the summary table
%   We will read the in table and save a table of the following form: 
% Row names     mean        stardard deviation
%   var1        ----            --------    
%
    table_fileIN = directory + "/" + in_table;
    % Read the data
    Table = readtable(table_fileIN);
    % Now we have all of the data, grab the column names
    variablenames = Table.Properties.VariableNames;

    Means = zeros(1,numel(variablenames));
    Stds = zeros(1,numel(variablenames));
    for i = 1:numel(variablenames)
        x = Table(:,variablenames{i});
        x = x.Variables;
        trans = numel(x)-loc*(1/.00625);
        Means(1,i) = mean(x(trans:end));
        Stds(1,i) = std(x(trans:end));
        name = variablenames{i};
        names(i) = string(name) ;
    end
    Means = Means';Stds = Stds';
    T = table(Means,Stds);
    T.Properties.RowNames = names;
    output_ID = directory + "/SensorData_Mean_Std.txt";
    writetable(T,output_ID,'WriteRowNames',true)
    status = "New Table made";
end

