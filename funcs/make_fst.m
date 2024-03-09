function status = make_fst(readfile_ID,writefile_ID,in_val,header,test_dur)
%MAKE_FST This will save the name of the experiment into the fast file, and
%it will change the air density and test duration within the fast file
%   Input: 
%       readfile_ID: where to copy 
%       writefile_ID: where to write the file to
%       input: the value of air density
%   Outfile:
%       status: message about success
    data = gather_up(readfile_ID);
    % we must multiply the invalue by 10^-3 (we didn't want decimal in file
    % name)
    in_val = 10^-3*in_val;
    % Edit the 24th line
    form_vector1 = ["      ","entry_one",...
        "   AirDens         - Air density (kg/m^3)"];
    formats = {form_vector1,[0,1,0]};
    columns = [1];
    edit_type = {{"replace",in_val}};
    data{24} = editor(formats, columns, edit_type, data{24},0);

    ttl = "FAST Certification Test " + "#" + "  " + header;
    data{2} = ttl;

    % Change the test duration in the 6th line
    form_vector2 = ["         ","entry_one",...
        "   TMax            - Total run time (s)"];
    formats = {form_vector2,[0,1,0]};
    columns = [1];
    edit_type = {{"replace",test_dur}};
    data{6} = editor(formats, columns, edit_type, data{6},0);
    
    check = lay_down(data, writefile_ID);
    status = "Successful fst update";
end

