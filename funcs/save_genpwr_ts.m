function status = save_genpwr_ts(tablewithgnpwrID)
    data = readtable(tablewithgnpwrID);
    y = data.Gen_Pwr.Variables;
    x = data.Time.Variables;
    
    plot(x,y)
    title
    

end
