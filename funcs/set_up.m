function [status,header] = set_up(input_vector, test_num, template_directory,...
    simulation_directory,test_dur,bld_fix)
%SET_UP This function drives all of the general text edit functions.  It
%will run them in order so that the files in the .fst dependency change
%have the correct parameters as specified by the input vector.  Once this
%program runs, we will be ready to run the simulation, and then move the
%resulting files once it is done.
%   Input: input_vector, test_num, template directory (read in),
%   simulation_directory (push out), test_dur - how long to simulate
%   bld_fix: if == 0, fix blades, if == 1, allow control of blades;
%   Output: did it work? and header -> the file to run the simulation on
    % Make the README file
    template_file = template_directory+"/README_TEMPLATE.txt";
    header = make_readme(input_vector,template_file,test_num,test_dur,bld_fix);
    
    % Fix the wind direction and wind speed
    readfile_ID = template_directory + "/modules/wind/steady_wind.wnd";
    writefile_ID = simulation_directory + "/modules/wind/steady_wind.wnd";
    status = chg_wnd(readfile_ID,writefile_ID,input_vector(1:2),test_dur);
    
    % Fix the blade pitch - prime rotor speed, too
    readfile_ID = template_directory + "/modules/NRELOffshrBsline5MW_Onshore_ElastoDyn.dat";
    writefile_ID = simulation_directory + "/modules/NRELOffshrBsline5MW_Onshore_ElastoDyn.dat";
    status = chg_pitch(readfile_ID,writefile_ID,input_vector(3),input_vector(2));

    % Allow servo-control of blades or not:
    readfile_ID = template_directory + "/modules/NRELOffshrBsline5MW_Onshore_ServoDyn.dat";
    writefile_ID = simulation_directory + "/modules/NRELOffshrBsline5MW_Onshore_ServoDyn.dat";
    if bld_fix == 0
        bld_fix = 0; % we keep blades fixed at initial starting pitch
    else
        bld_fix = 5; % allow the DLL to control it
    end
    data = gather_up(readfile_ID);
    form_vector1 = ["          ","entry_one",...
        "   PCMode       - Pitch control mode {0: none, 3: user-defined from routine PitchCntrl, 4: user-defined from Simulink/Labview, 5: user-defined from Bladed-style DLL} (switch)"];
    formats = {form_vector1,[0,1,0]};
    columns = [1];
    edit_type = {{"int",bld_fix}};
    data{7} = editor(formats, columns, edit_type, data{7},0);
    
    check = lay_down(data, writefile_ID);
    
    % Fix the Air density - change the name at line 2 of the fst file
    % -- also: change the test duration --
    readfile_ID = template_directory + "/5MW_Land_DLL_WTurb.fst";
    writefile_ID = simulation_directory + "/" + header + ".fst";
    status = make_fst(readfile_ID,writefile_ID,input_vector(4),header,test_dur);
    
    % Iterate through each blade
    for i = 1:3
        folder = "blade" + num2str(i);
        %   Change all the airfoils
        
        % here is a cell that contains all of the airfoils we need and the
        % erosion region linked to them {airfoil,erosion region}
        airfoils = {
            {"DU40_A17.dat",1},{"DU35_A17_1.dat",1},...
            {"DU35_A17_2.dat",2},{"DU30_A17.dat",2},...
            {"DU25_A17_1.dat",3},{"DU25_A17_2.dat",3},...
            {"DU21_A17_1.dat",4},{"DU21_A17_2.dat",4},...
            {"NACA64_A17_1.dat",5},{"NACA64_A17_2.dat",5},...
            {"NACA64_A17_3.dat",6},...
            {"NACA64_A17_4.dat",6},{"NACA64_A17_5.dat",6},...
            {"NACA64_A17_6.dat",6},{"NACA64_A17_7.dat",6}};
        readfile_ID = cell(1,15);
        writefile_ID = cell(1,15);
        for j = 1:15
            aircell{1} = template_directory + ...
                "/modules/" + folder + "/airfoils/" + airfoils{1,j}{1};
            aircell{2} = airfoils{1,j}{2};
            readfile_ID{1,j} = aircell;
            writefile_ID{1,j} = simulation_directory + ...
                "/modules/" + folder + "/airfoils/" + airfoils{1,j}{1};
        end
        er_ind = 5 + (i-1)*6;
        erosion = input_vector(er_ind:er_ind+5);
        status = chg_af(readfile_ID,writefile_ID,erosion);
 
        %   Change the the blade
        % For now, we are not doing this
        read_ID = template_directory + ...
                "/modules/" + folder + "/NRELOffshrBsline5MW_Blade.dat";
        write_ID = simulation_directory + ...
                "/modules/" + folder + "/NRELOffshrBsline5MW_Blade.dat";
        %status = chg_bld(read_ID,write_ID,erosion);
        
        %   Change the chord and the twist
        % For now, we are also not doing this
        read_ID = template_directory + ...
                "/modules/" + folder + "/NRELOffshrBsline5MW_AeroDyn_blade.dat";
        write_ID = simulation_directory + ...
                "/modules/" + folder + "/NRELOffshrBsline5MW_AeroDyn_blade.dat";
        %status = chg_bld_chd(read_ID,write_ID,erosion);
    end
    status = "All files updated";
end

