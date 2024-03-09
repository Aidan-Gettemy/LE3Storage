function [mean_exp_table, std_exp_table] = full_exp_table(collection)
%FULL_EXP_TABLE Creates a table of outputs from each experiment test (in
%order), one for means and one for std.  The table will have each row
%labeled by variable name.  Collection will be a cell with each entry a
%file address for the mean_std table
    mean_exp_table = table();
    std_exp_table = table();
    for i = 1:numel(collection)
        data = readtable(collection{1,i},ReadRowNames=true);
        test_str = "Test" + num2str(i);
        command1 = "mean_exp_table."+test_str+ " = data.Means";
        command2 = "std_exp_table."+test_str +" = data.Stds";
        eval(command1)
        eval(command2)
        if i == 1
            output_vars = data.Properties.RowNames;
            std_exp_table.Properties.RowNames = output_vars;
            mean_exp_table.Properties.RowNames = output_vars;
        end
    end
end

