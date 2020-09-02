function [Output,Event] = Mission(InputData,Network,n_stations)
%Solves Mission according to input data in struct.
%       Mission data is loaded in InputData struct, Station data is laoded 
%       in Network struct. Outputs expected trajectories on Output struct
%       and intermediate variable Event containing information relative to
%       the timestamps with payload-station interactions.


%% Settings
configuration.mu = 3.986*10^5; %km^3/s^2
configuration.step = 100; %s
configuration.epsilon = 0.5; %s
configuration.r_precission = 0.01; %km
configuration.LogFilename = 'MissionLogger.txt';
configuration.DisplayLog = 0;
configuration.max_iterations = 10;


%% Data Pre processing
%Declare events in which operations occur
[Event,InputData.tspan] = SplitTimeEvents(InputData.Payload,InputData.n_payloads,configuration);
InputData.MissionTime = Event(end).time;

%% First iteration
%Propagate all stations
for i = 1:n_stations
    [Network(i).r,Network(i).v] = COE2rv(Network(i).type,Network(i).omega,Network(i).theta,Network(i).i,Network(i).OMEGA,Network(i).a,Network(i).e,Network(i).u,configuration.mu);
end

Stations = PropagateAllStations(Network,n_stations,InputData.tspan,configuration.mu);

%Set target directions
Event = SetTarget_r(Stations,Event);
n_events = numel(Event);

%% Mission iteration
% Prepare logger
fid = fopen(configuration.LogFilename,'w');
fclose(fid);
% Initialize variables
converged = 0;
n_iterations = 0;
while ~converged && n_iterations < configuration.max_iterations
    n_iterations = n_iterations + 1;
    %Call function
    Output = SimulateMissionIteration(InputData,Event,Network,n_stations,configuration);
    Stations = Output.Stations;
    Payloads = Output.Payloads;
    
    %Load previous target r
    Target_r_prev = cell(1,n_events);
    for i = 1:n_events
        if strcmp(Event(i).type,'Ejection')
            Target_r_prev{i} = Event(i).Target_r;
        end
    end
    
    % Determine actual position of stations
    Event = SetTarget_r(Stations,Event);
    
    % Compare actual position with target r
    converged = 1;
    for i = 1:n_events
        if strcmp(Event(i).type,'Ejection')
            log.r_target = Target_r_prev{i};
            log.r_actual = Event(i).Target_r;
            log.Event = Event(i);
            if norm(Target_r_prev{i} - Event(i).Target_r) > configuration.r_precission
                converged = 0;
                log.valid = 0;
                MissionLogger(configuration.LogFilename,'EventPosition',log,configuration.DisplayLog);
            else
                log.valid = 1;
                MissionLogger(configuration.LogFilename,'EventPosition',log,configuration.DisplayLog);
            end
        end
    end
    
    
    % Determine succesful convergence
    log.converged = converged;
    log.n_iterations = n_iterations;
    MissionLogger(configuration.LogFilename,'Iteration',log,configuration.DisplayLog);
end

% Extra outputs
Output.configuration = configuration;
end