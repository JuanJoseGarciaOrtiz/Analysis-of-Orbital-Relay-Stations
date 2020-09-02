function Input = SimultaneousEstimator(Input,Network,n_stations,n_raise,n_descent,mu)

%Preallocate
n = zeros(n_stations,1);
theta0 = zeros(n_stations,1);
TOF = zeros(n_stations-1,1); %TOF(i) is TOF to go from i to i+1 or viceversa

%Check if theta is defined
for i = 1:n_stations
    if isnan(Network(i).theta)
        Network(i).theta = Network(i).u;
    end
    theta0(i) = Network(i).theta;
    n(i) = sqrt(mu/(Network(i).a^3));
end
%Calculate TOF
for i = 1:(n_stations-1)
    TOF(i) = pi*sqrt(((Network(i).a + Network(i+1).a)/2)^3/mu);
end
% Calculate twait and assign all parameters
%Raising payloads
t_init = 0;
for it = 1:n_raise
    i = it;
    t = t_init;
    for j = 1:Input.Payload(i).n_operations
        Input.Payload(i).Operation(j).TargetStation = j+1;
        Input.Payload(i).Operation(j).TimeOfFlight = round(TOF(j));
        
        %Waiting time
        n_A = n(j);
        n_B = n(j+1);
        theta_A_0 = rem(theta0(j) + n_A*t,2*pi);
        theta_B_0 = rem(theta0(j+1) + n_B*t,2*pi);
        tw = (pi - theta_B_0 + theta_A_0 - n_B*TOF(j))/(n_B - n_A);
        if tw <0
            tw = abs(2*pi/(n_B - n_A)) + tw;
        end
        Input.Payload(i).Operation(j).WaitingTime = round(tw);
        if it ~= 1 && j==1
            Input.Payload(i).Operation(j).WaitingTime = round(tw+t);
        end
        t = t + tw + TOF(j);
        if j == 1
            t_init = t + 0.3*TOF(j);
        end
    end
end

%Descending payloads
t_init = 0;
for it = 1:n_descent
    i = it + n_raise;
    t = t_init;
    for j = 1:Input.Payload(i).n_operations
        Input.Payload(i).Operation(j).TargetStation = n_stations-j;
        Input.Payload(i).Operation(j).TimeOfFlight = round(TOF(n_stations-j));
        
        %Waiting time
        n_A = n(n_stations-j+1);
        n_B = n(n_stations-j);
        theta_A_0 = rem(theta0(n_stations-j+1) + n_A*t,2*pi);
        theta_B_0 = rem(theta0(n_stations-j) + n_B*t,2*pi);
        tw = (pi - theta_B_0 + theta_A_0 - n_B*TOF(n_stations-j))/(n_B - n_A);
        if tw <0
            tw = abs(2*pi/(n_B - n_A)) + tw;
        end
        Input.Payload(i).Operation(j).WaitingTime = round(tw);
        if it ~= 1 && j==1
            Input.Payload(i).Operation(j).WaitingTime = round(tw+t);
        end
        t = t + tw + TOF(n_stations-j);
        if j == 1
            t_init = t + 0.3*TOF(n_stations-j);
        end
    end
end
end