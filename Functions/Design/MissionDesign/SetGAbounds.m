function [T,LB,A,b] = SetGAbounds(InputData,Network,n_stations,n_raise,n_descent,mu)
n_payloads = n_raise + n_descent;
n_operations = n_stations-1;
m = 0.02;%margin
%Preallocations
T = zeros(n_payloads*n_operations*2,1);
LB = ones(n_payloads*n_operations*2,1)*5;
margin = zeros(1,n_payloads*n_operations*2);
b = zeros(n_payloads*n_operations*2,1);
A = zeros(n_payloads*n_operations*2*2,n_payloads*n_operations*2);

%Orbital periods
tau = zeros(n_stations,1);
for i = 1:n_stations
    tau(i) = 2*pi*sqrt(Network(i).a^3/mu);
end

% Set margins and central value
i_cont = 0;
k_cont = 0;
op_cont = 0;
n_operations = n_stations-1;
for i = 1:n_raise
    i_cont = i_cont + 1;
    for j = 1:n_operations
        op_cont = op_cont + 1;
        %Waiting time
        k_cont = k_cont + 1;
        T(k_cont) = InputData.Payload(i_cont).Operation(j).WaitingTime;
        margin(k_cont) = m*tau(InputData.Payload(i_cont).Operation(j).TargetStation);
        for it = 1:k_cont
            A(2*k_cont-1,it) = -1;
            A(2*k_cont,it)   = +1;
        end
        b(2*k_cont-1) = -(sum(T) - margin(k_cont));
        b(2*k_cont  ) =  (sum(T) + margin(k_cont));
        
        %Time of flight
        k_cont = k_cont + 1;
        T(k_cont) = InputData.Payload(i_cont).Operation(j).TimeOfFlight;
        margin(k_cont) = m*tau(InputData.Payload(i_cont).Operation(j).TargetStation);
        for it = 1:(k_cont)
            A(2*k_cont-1,it) = -1;
            A(2*k_cont,it)   = +1;
        end
       b(2*k_cont-1) = -(sum(T) - margin(k_cont));
       b(2*k_cont  ) =  (sum(T) + margin(k_cont));
    end
end

for i = 1:n_descent
    i_cont = i_cont + 1;
    for j = 1:n_operations
        %Waiting time
        k_cont = k_cont + 1;
        T(k_cont) = InputData.Payload(i_cont).Operation(j).WaitingTime;
        margin(k_cont) = m*tau(InputData.Payload(i_cont).Operation(j).TargetStation);
        for it = 1:k_cont
            A(2*k_cont-1,it) = -1;
            A(2*k_cont,it)   = +1;
        end
        b(2*k_cont-1) = -(sum(T) - margin(k_cont));
        b(2*k_cont  ) =  (sum(T) + margin(k_cont));
        
        %Time of flight
        k_cont = k_cont + 1;
        T(k_cont) = InputData.Payload(i_cont).Operation(j).TimeOfFlight;
        margin(k_cont) = m*tau(InputData.Payload(i_cont).Operation(j).TargetStation);
        for it = 1:k_cont
            A(2*k_cont-1,it) = -1;
            A(2*k_cont,it)   = +1;
        end
        b(2*k_cont-1) = -(sum(T) - margin(k_cont));
        b(2*k_cont  ) =  (sum(T) + margin(k_cont));
    end
end
b = round(b);
end