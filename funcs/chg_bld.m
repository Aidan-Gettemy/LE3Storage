function blade_regions = chg_bld(readfile_ID,writefile_ID,bladex_vec)
%CHG_AF Changes the Edgewise Stiffnes, Flapwise Stiffnes, ,and blade mass
%density
%   Input: 
%       readfile_ID: the file to copy
%       writefile_ID: the file to write to
%       input: the erosion levels for the given blade
%   Outfile:
%       status: message about success
    data = gather_up(readfile_ID);
    % this cell will link each node with the corresponding erosion region
    Nodes = [1:49]';
    Erosion_Region = zeros();
    Erosion_Region(1:11) = 0;
    Erosion_Region(12:18) = 1;
    Erosion_Region(19:22) = 2;
    Erosion_Region(23:27) = 3;
    Erosion_Region(28:31) = 4;
    Erosion_Region(32:35) = 5;
    Erosion_Region(36:49) = 6;
    Erosion_Region = Erosion_Region';
    blade_regions = table(Nodes,Erosion_Region);
    for i =17:65
        row = i-16;
        er = blade_regions{row,2};
        if er == 0
            continue
        end
        columns = [4,5,6]; % columns to edit (...,bmd,flpstf,edgstf)
        
        txt = split(data(i));
        txt = txt{1} + "  " + txt{2} + "  " + txt{3} + "  ";
        form_vector1 = [txt,"bmd","  ",...
                    "flpstf","  ","edgstf"];
        formats = {form_vector1,[0,1,0,1,0,1]};
        % determine the factors:
        
        bmdf = 1-.05*bladex_vec(er);% erosion def
        flpstff = 1-.1*bladex_vec(er);% erosion def
        edgstff = 1-.1*bladex_vec(er);% erosion def
        edit_type = {{"multiply",bmdf},...
            {"multiply",flpstff},{"multiply",edgstff}};
        data{i} = editor(formats , columns, edit_type, data{i},1);
    end 
    check = lay_down(data, writefile_ID);
    status = "Successful blade properties update";
end

