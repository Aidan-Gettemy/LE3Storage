clc;close;clear;
% Create the design points for the Blade Pitch vs Wind Speed Experiment
% We have added some code to better set the initial rotor speed and blade pitch
% The rotorspeed is set in the chg bld pitch setup function
% We added an additional function that we call after plugging in the run point
% Thus it will automatically read the wind speed and set pitch to the right level

windspeeds = [3:26,linspace(10,14,20),linspace(10,14,20)]

erosion_profiles = {1/2*[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],...
    0*[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]};

Design = zeros(1,22);
noms = [0,11.4,0,1225];

iter = 1;
for g = 1:2
    for j = 1:numel(erosion_profiles)
        for i = 1:numel(windspeeds)
            ws = windspeeds(i);
            Design(iter,1:4) = noms;
            Design(iter,[2]) = [ws];
            if i > 24
                Design(iter,[3]) = 1;
            end
            if i > 24
                Design(iter,[3]) = 2;
            end
            Design(iter,5:end) = erosion_profiles{j};
            if g == 2
                Design(iter,1) = 1;
            end
            iter=iter+1;
        end
    end
end

save("BldptchvsWindSpeed3.txt","Design","-ascii")

% Run the design points and then explore the resulting behaviour of the turbine
% Did we fix all of the strange behaviour?
% Check if any of the profiles are 'breaking' the model--will need to get multiple computers
