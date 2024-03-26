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
    status = mean(y(end-30*160:end));
end
