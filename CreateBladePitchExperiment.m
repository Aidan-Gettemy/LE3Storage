clc;close;clear;
% Create the design points for the Blade Pitch vs Wind Speed Experiment
% First we will try to run the tests with the blade pitch controller
% See if for wind speeds above 11.4 m/s, will setting the blades at a
% higher pitch prevent them from stalling.  In this experiment we will run
% the clean turbine and the strongly eroded turbine.  If I lessen the
% maximum erosion definition, I am going to see if I can try uniform
% erosion

windspeeds = 3:26;

erosion_profiles = {1/4*[1,1,2,2,4,4,1,1,2,2,4,4,1,1,2,2,4,4],...
    0*[1,1,2,2,4,4,1,1,2,2,4,4,1,1,2,2,4,4];};

Design = zeros(1,22);
noms = [0,11.4,0,1225];

iter = 1;
for j = 1:numel(erosion_profiles)
    for i = 1:numel(windspeeds)
        ws = windspeeds(i);
        bldptch = 0;
        if j == 1
            if ws>11.4
                bldptch = 10;
            end
        end
        Design(iter,1:4) = noms;
        Design(iter,[2,3]) = [ws,bldptch];
        Design(iter,5:end) = erosion_profiles{j};
        iter=iter+1;
    end
end

save("BldptchvsWindSpeed.txt","Design","-ascii")