function status = chg_bld_chd(readfile_ID,writefile_ID,bladex_vec)
%CHG_BL_CHD Changes the Edgewise Stiffnes, Flapwise Stiffnes, ,and blade mass
%density
%   Input: 
%       readfile_ID: the file to copy
%       writefile_ID: the file to write to
%       input: the erosion levels for the given blade
%   Outfile:
%       status: message about success
    data = gather_up(readfile_ID);
    % this cell will link each node with the corresponding erosion region
    Nodes = [1:19]';
    Erosion_Region = zeros();
    Erosion_Region(1:4) = 0;
    Erosion_Region(5:6) = 1;
    Erosion_Region(7:8) = 2;
    Erosion_Region(9:10) = 3;
    Erosion_Region(11:12) = 4;
    Erosion_Region(13:14) = 5;
    Erosion_Region(15:19) = 6;
    Erosion_Region = Erosion_Region';
    blade_regions = table(Nodes,Erosion_Region);
    for i =7:25
        row = i-6;
        er = blade_regions{row,2};
        if er == 0
            continue
        end
        columns = [5,6]; % column to edit (...,bldtwst,blchd)
        
        txt = split(data(i));
        txt1 = txt{1} + " " + txt{2} + " " + txt{3} + " " + ...
             txt{4} + "  ";
        txt2 = "        " + txt{7} + "      " +...
            txt{8} + "      " +txt{9} + "      " +txt{10};
        form_vector1 = [txt1,"BlTwist","  ","BlChord",txt2];
        formats = {form_vector1,[0,1,0,1,0]};
        
        % determine the factor:
        bltwst = 1-.05*bladex_vec(er);%erosion function
        blchdf = 1-.05*bladex_vec(er);% erosion function
        edit_type = {{"multiply",bltwst},{"multiply",blchdf}};
        data{i} = editor(formats , columns, edit_type, data{i},1);
    end 
    check = lay_down(data, writefile_ID);
    status = "Successful blade chord update";
end

