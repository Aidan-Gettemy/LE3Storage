function status = save_genpwr_ts(tablewithgnpwrID, testnum,testfolder)
    data = readtable(tablewithgnpwrID);
    y = data.Gen_Pwr.Variables;
    x = data.Time.Variables;
    f = figure(Visible="off");
    plot(x,y)
    titlename = 
    xlabel("Time (s)");
    ylabel("Generator Power (kW)");
    trl = "Generator Power vs Time for Test # " + num2str(testnum);
    title(trl);
    
    prt = testfolder + "/" + "GenPwrvsTime.pdf";   
    print(gcf,prt,"-dpdf")

end
