function status = save_genpwr_ts(tablewithgnpwrID, testnum, testfolder)
    data = readtable(tablewithgnpwrID);
    y = data.GenPwr;
    x = data.Time;
    f = figure(Visible="off");
    plot(x,y)
    xlabel("Time (s)");
    ylabel("Generator Power (kW)");
    trl = "Generator Power vs Time for Test # " + num2str(testnum);
    title(trl);
    
    prt = testfolder + "/" + "GenPwrvsTimeTest"+num2str(testnum)+".pdf";   
    print(f,prt,"-dpdf")
    alpha = round(numel(y)/5)
    status = mean(y(end-alpha:end));
end
