function f = MissionFunctionHandle(T,InputData,Network,n_stations,n_raise,n_descent,costFunction)
T = round(T);
%% Input Assignment
i_cont = 0;
k_cont = 0;
n_operations = n_stations-1;
for i = 1:n_raise
    i_cont = i_cont + 1;
    for j = 1:n_operations
        k_cont = k_cont + 1;
        InputData.Payload(i_cont).Operation(j).WaitingTime = T(k_cont);
        k_cont = k_cont + 1;
        InputData.Payload(i_cont).Operation(j).TimeOfFlight = T(k_cont);
    end
end

for i = 1:n_descent
    i_cont = i_cont + 1;
    for j = 1:n_operations
        k_cont = k_cont + 1;
        InputData.Payload(i_cont).Operation(j).WaitingTime = T(k_cont);
        k_cont = k_cont + 1;
        InputData.Payload(i_cont).Operation(j).TimeOfFlight = T(k_cont);
    end
end

%% Function call
[Output,Event] = Mission(InputData,Network,n_stations);
Stations = Output.Stations;
Payloads = Output.Payloads;
configuration = Output.configuration;
mu = configuration.mu;

%% Cost function
switch costFunction
    case 'MechanicalEnergy'
        xi_i = zeros(n_stations,1);
        xi_f = zeros(n_stations,1);
        Dxi = zeros(n_stations,1);
        for i = 1:n_stations
            [~,~,~,~,~,~,a,e] = rv2COE(Stations(i).r(end,:),Stations(i).v(end,:),mu);
            xi_i(i) = -mu/(2*(Network(i).a));
            xi_f(i) = -mu/(2*a);
            Dxi(i) = xi_f(i) - xi_i(i);
        end
        f = sqrt(sum(Dxi.^2));
    case 'Eccentricity'
        e_i = zeros(n_stations,1);
        e_f = zeros(n_stations,1);
        De = zeros(n_stations,1);
        for i = 1:n_stations
            [~,~,~,~,~,~,a,e_f(i)] = rv2COE(Stations(i).r(end,:),Stations(i).v(end,:),mu);
            e_i(i) = Network(i).e;
            De(i) = e_f(i) - e_i(i);
        end
        f = sqrt(sum(De.^2));
    case 'Apsis'
        Drp = zeros(n_stations,1);
        Dra = zeros(n_stations,1);
        for i = 1:n_stations
            [~,~,~,~,~,~,a,e_f] = rv2COE(Stations(i).r(end,:),Stations(i).v(end,:),mu);
            rp0 = Network(i).a*(1-Network(i).e);
            rpf = a*(1-e_f);
            ra0 = Network(i).a*(1+Network(i).e);
            raf = a*(1+e_f);
            Drp(i) = rpf - rp0;
            Dra(i) = raf - ra0;
        end
        f = sqrt(sum(Drp.^2) + sum(Dra.^2));
        
end
end