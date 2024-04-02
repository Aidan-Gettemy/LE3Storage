function stat = init_rtspeed_sep(windspeed, template_directory,...
    simulation_directory)
    
    readfile_ID = template_directory + "/modules/NRELOffshrBsline5MW_Onshore_ElastoDyn.dat";
    writefile_ID = simulation_directory + "/modules/NRELOffshrBsline5MW_Onshore_ElastoDyn.dat";

    form_vector = ["          ","entry_one",...
        "   RotSpeed  - Initial or fixed rotor speed (rpm)"];
    formats = {form_vector,[0,1,0]};
    columns = [1];
    rt_speed_init = fix_in_rt_speed(windspeed)-1;
    edit_type = {{"replace",rt_speed_init}};
    data{33} = editor(formats,columns,edit_type,data{33},0);
    stat = "Fixed the initial rotor speed";
end
