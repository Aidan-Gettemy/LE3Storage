function header = remake_head(input_vector,iter)
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
end
