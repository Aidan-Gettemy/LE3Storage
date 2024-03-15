function stat = special_wind(readfile_ID,writefile_ID,numb,...
    start_speed,end_speed,testdur)
%SPECIAL_WIND This will set up a ramp-type wind condition.  Run this after
%running the general set up
%  inputs: readfile_ID: the file to use as the template
%           writefile_D: where to save the changed file
%           numb: the number of wind speeds to use
    data = gather_up(readfile_ID);
    % Edit from the fifth data line on...
    newdata=cell(5+numb*2);
    % We will start at the start speed, and end at the end speed
    % We will divide the total time into 2*numb many segments
    % We will divide the difference in speed into numb many speeds
    % Then we will alternate between set speed and increasing speed
    inct = linspace(0,testdur,2*numb+2);
    incs = linspace(start_speed,end_speed,numb+1);
    % Here is where we could set the wind directions, too
    incw = linspace(0,0,numb+1);
    for k = 1:4
        newdata{k} = data{k};
    end
    
    form_vector1 = ["0.000	 ","windspeed","   ","winddirection",...
        "	 0.000	 0.000	 0.000	 0.000	 0.000"];
    formats = {form_vector1,[0,1,0,1,0]};
    columns = [2,3];
    edit_type1 = {{"replace",incs(1)},{"replace",incw(1)}};
    newdata{5} = editor(formats, columns, edit_type1, data{5},0);
   
    for i = 1:numb
        t1 = inct(2*i);
        t2 = inct(2*i+1);
        form_vector1 = ["t1","	 ","windspeed","   ","winddirection",...
        "	 0.000	 0.000	 0.000	 0.000	 0.000"];
        if t1>99
            form_vector1 = ["t1"," ","windspeed","   ","winddirection",...
        "	 0.000	 0.000	 0.000	 0.000	 0.000"];
        end
        form_vector2 = ["t2","	 ","windspeed","   ","winddirection",...
        "	 0.000	 0.000	 0.000	 0.000	 0.000"];
        if t2>99
            form_vector2 = ["t2"," ","windspeed","   ","winddirection",...
        "	 0.000	 0.000	 0.000	 0.000	 0.000"];
        end

        formats1 = {form_vector1,[1,0,1,0,1,0]};
        formats2 = {form_vector2,[1,0,1,0,1,0]};
        columns = [1,2,3];
        edit_type1 = {{"replace",t1},{"replace",incs(i)},{"replace",incw(i)}};
        edit_type2 = {{"replace",t2},{"replace",incs(i+1)},{"replace",incw(i+1)}};
        newdata{6+2*(i-1)} = editor(formats1, columns, edit_type1, data{6},0);
        newdata{7+2*(i-1)} = editor(formats2, columns, edit_type2, data{6},0);
    end
    form_vector2 = ["t2","	 ","windspeed","   ","winddirection",...
        "	 0.000	 0.000	 0.000	 0.000	 0.000"];
    if inct(end)>99
        form_vector2 = ["t2"," ","windspeed","   ","winddirection",...
    "	 0.000	 0.000	 0.000	 0.000	 0.000"];
    end
    formats2 = {form_vector2,[1,0,1,0,1,0]};
    edit_type3 = {{"replace",inct(end)},{"replace",incs(i+1)},{"replace",incw(i+1)}};
    newdata{8+2*(i-1)} = editor(formats2, columns, edit_type3, data{6},0);
    check = lay_down(newdata, writefile_ID);
    stat = "Special Wind Condition is set up";
end
