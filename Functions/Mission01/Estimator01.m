function InputData = Estimator01(InputData,Network,n_stations,mu)
% Estimates the input time of flight and waiting time to have close to
% Hohmann transfers in the network to further simulate using Mission00.

n_operations = InputData.FinalStation - InputData.InitialStation;
%Check if theta is defined
n = zeros(n_stations,1);
for i = 1:n_stations
    if isnan(Network(i).theta)
        Network(i).theta = Network(i).u;
    end
    n(i) = sqrt(mu/(Network(i).a^3));
end
clear i;
theta = zeros(1,n_stations);
time = 0;
InputData.WaitingTime = zeros(1,n_operations);
InputData.TimeOfFlight = zeros(1,n_operations);
for j = 1:n_operations
    %Time of Flight estimation assuming hohmann transfer between circular
    %orbits
    i_A = InputData.InitialStation + j - 1;
    i_B = i_A + 1;
    a_A = Network(i_A).a;
    a_B = Network(i_B).a;
    tf = pi*sqrt(((a_A + a_B)/2)^3/mu);
    InputData.TimeOfFlight(j) = round(tf);
    
    %Waiting Time estimation
    n_A = n(i_A);
    n_B = n(i_B);
    if j ==1
        theta_A_0 = Network(i_A).theta;
        theta_B_0 = Network(i_B).theta;
    else
        theta_A_0 = rem(theta(i_A),2*pi);
        theta_B_0 = rem(theta(i_B),2*pi);
    end
    tw = (pi - theta_B_0 + theta_A_0 - n_B*tf)/(n_B - n_A);
    if tw <0
        tw = abs(2*pi/(n_B - n_A)) + (pi - theta_B_0 + theta_A_0 - n_B*tf)/(n_B - n_A);
    end
    InputData.WaitingTime(j) = round(tw);
    
    time = time + InputData.WaitingTime(j) + InputData.TimeOfFlight(j);
    %Kepler propagation
    for i = 1:n_stations
        theta(i) = Network(i).theta + n(i)*time;
    end
end