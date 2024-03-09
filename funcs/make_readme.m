function header = make_readme(input_vector,template_file,iter,test_dur,bld_fix)
%MAKE_README This function makes the readme to document this specific test
%   Input: 
%       input_vector: this holds the following in this order:
% [wind direction, wind speed, blade pitch, air density, blade_1_erosion_1,
% blade_1_erosion_2, blade_1_erosion_3,blade_1_erosion_4,
% blade_1_erosion_5, blade_1_erosion_6,blade_2_erosion_1,
% blade_2_erosion_2, blade_2_erosion_3,blade_2_erosion_4,
% blade_2_erosion_5, blade_2_erosion_6, blade_3_erosion_1,
% blade_3_erosion_2, blade_3_erosion_3,blade_3_erosion_4,
% blade_3_erosion_5, blade_3_erosion_6]
%       template_file: this is where to copy the data from
%       iter: this is the test number we are on
%       test_dur: this is the length of the simulation
%   Output:
%        header: this is the name for the experiment test

% Establish three levels of erosion: 
% > if the total erosion factor sums to <= 6 class mild
% > if the total erosion factor sums to 6 < x <= 12 class moderate
% > if the total erosion factor sums to > 12 class severe
% copy a file andd give it a new name

    % make the file name 
    name = "";
    for i = 1:4
        var = num2str(input_vector(1,i));
        name = name + "_" + var;
    end
    
    y = sum(input_vector(1,5:end));

    if y > 8
        suf = "_severe_";
    elseif y > 4
        suf = "_moderate_";
    else
        suf = "_mild_";
    end
    
    header = "Test" + num2str(iter) + name + suf;

    % gather_up the files lines into a cell
    data = gather_up(template_file);
    input_vector(4) = 10^-3*input_vector(4);%fix scale
    % change the lines
    formats = {["READ ME: ","entry"],[0,1]};
    columns = [2];
    edit_type = {{"replace",header}};
    data{2} = editor(formats,columns,edit_type,data{2},0);
    for i = 4:7
        ttle = split(data{i});
        formats = {[ttle(1),"entry"],[0,1]};
        columns = [2];
        edit_type = {{"replace",input_vector(1,i-3)}};
        data{i} = editor(formats,columns,edit_type,data{i},0);
    end

    for i = 12:17
        ttle = split(data{i});
        formats = {[ttle(1),"entry"],[0,1]};
        columns = [2];
        edit_type = {{"replace",input_vector(1,i-7)}};
        data{i} = editor(formats,columns,edit_type,data{i},0);
    end

    for i = 20:25
        ttle = split(data{i});
        formats = {[ttle(1),"entry"],[0,1]};
        columns = [2];
        edit_type = {{"replace",input_vector(1,i-9)}};
        data{i} = editor(formats,columns,edit_type,data{i},0);
    end


    for i = 28:33
        ttle = split(data{i});
        formats = {[ttle(1),"entry"],[0,1]};
        columns = [2];
        edit_type = {{"replace",input_vector(1,i-11)}};
        data{i} = editor(formats,columns,edit_type,data{i},0);
    end
    % change the lines at the end
    formats = {["Simulation_time: ","entry"],[0,1]};
    columns = [2];
    edit_type = {{"replace",test_dur}};
    data{36} = editor(formats,columns,edit_type,data{36},0);

    formats = {["Blade_pitch: ","entry"],[0,1]};
    columns = [2];
    edit_type = {{"replace",bld_fix}};
    data{37} = editor(formats,columns,edit_type,data{37},0);
    
    % save the results out
    showthis = ['Test Header ', header, '--Test Duration: ',test_dur];
    disp(showthis)
    save_name = "Simulate_NREL5MW/" + header + "README.txt";
    lay_down(data,save_name)

end

