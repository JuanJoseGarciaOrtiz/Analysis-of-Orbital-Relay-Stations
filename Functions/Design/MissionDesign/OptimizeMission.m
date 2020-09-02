%Calls genetic algorithm for optimizing a particular Mission design.
%       The number of ascending and descending payloads can be tuned with
%       other parameters in the user input block.

clc
clear
close all

%% User input
n_raise = 1;
n_descent = 1;
m_payload = 10;
[Network,n_stations] = ReadStationData('RelayStationsInput.txt');
mu = 3.986*10^5; %km^3/s^2

n_payloads = n_raise + n_descent;
n_operations = n_stations-1;
%% Preallocate
Input.n_payloads = n_payloads;
Input.Payload(n_payloads).mass = 0;
Input.Payload(n_payloads).InitialStation = 0;
Input.Payload(n_payloads).n_operations = 0;
for i = 1:n_payloads
    Input.Payload(i).mass = m_payload;
    Input.Payload(i).InitialStation = 1;
    Input.Payload(i).n_operations = n_operations;
    if i>n_raise
        Input.Payload(i).InitialStation = n_stations;
    end
    Input.Payload(i).Operation(Input.Payload(i).n_operations).WaitingTime = 0;
    Input.Payload(i).Operation(Input.Payload(i).n_operations).TimeOfFlight = 0;
    Input.Payload(i).Operation(Input.Payload(i).n_operations).TargetStation = 0;
end

%% Estimator
Input = StaggeredEstimator(Input,Network,n_stations,n_raise,n_descent,mu);
%Input = SimultaneousEstimator(Input,Network,n_stations,n_raise,n_descent,mu);

%% TESTCALL
InputData = Input;
save('InputData','InputData')

%T = rand(n_payloads*n_operations*2,1);
%MissionFunctionHandle(T,InputData,Network,n_stations,n_raise,n_descent)

%% Set bounds
[T,LB,A,b] = SetGAbounds(InputData,Network,n_stations,n_raise,n_descent,mu);

%% Genetic algorithm call
rng shuffle
%options = optimoptions(@ga,'CrossoverFcn','crossoverheuristic');{'crossoverintermediate',1}
options = optimoptions(@ga,'CrossoverFcn',{'crossoverintermediate',1},'Display','iter','MaxGenerations',25,'PopulationSize',25,...
    'MaxStallGenerations',4,'FunctionTolerance',1e-5,'MutationFcn','mutationadaptfeasible');
T_opt = ga(@(T) MissionFunctionHandle(T,InputData,Network,n_stations,n_raise,n_descent,'MechanicalEnergy'),numel(T),A,b,[],[],LB,[],[],options);
T_opt = T_opt';

%% Build and save input
InputData = BuildInput(T_opt,InputData,n_stations,n_raise,n_descent);
save('InputOpt','InputData','T_opt')