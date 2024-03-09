function status = chg_wnd(readfile_ID,writefile_ID,input,testdur)
%CHG_WND Changes the wind direction and the wind speed
%   Input: 
%       readfile_ID: where to copy 
%       writefile_ID: where to write the file to
%       input: the vector of the input wind direction and wind speed
%   Outfile:
%       status: message about success
    data = gather_up(readfile_ID);
    % Edit the 5th and 6th lines
    form_vector1 = ["0.000	 ","windspeed","   ","winddirection",...
        "	 0.000	 0.000	 0.000	 0.000	 0.000"];
    form_vector2 = ["testdur","	 ","entry_one","   ","entry_two",...
        "	 0.000	 0.000	 0.000	 0.000	 0.000"];
    formats = {form_vector1,[0,1,0,1,0]};
    columns = [2,3];
    edit_type1 = {{"replace",input(2)},{"replace",input(1)}};
    data{5} = editor(formats, columns, edit_type1, data{5},0);
    columns = [1,2,3];
    edit_type2 = {{"replace",testdur},{"replace",input(2)},{"replace",input(1)}};
    formats = {form_vector2,[1,0,1,0,1,0]};
    data{6} = editor(formats, columns, edit_type2, data{6},0);

    check = lay_down(data, writefile_ID);
    status = "Successful wind update";
end

