function Mission01_results = Mission01(InputData,Network,n_stations,mu)
%Solves prototype Mission01 according to input data in struct.
%       Mission data is loaded in InputData struct, Station data is laoded 
%       in Network struct. Returns expected trajectories and additional
%       output parameters on Mission01_results

%% Estimate Time od Flight and waiting time for close-to-hohmann transfers
InputData = Estimator01(InputData,Network,n_stations,mu);

%% Simulate the mission
Mission01_results = Mission00(InputData,Network,n_stations,mu);
end