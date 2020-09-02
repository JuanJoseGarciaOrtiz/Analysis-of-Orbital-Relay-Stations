function InputData = BuildInput(T,InputData,n_stations,n_raise,n_descent)
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
end