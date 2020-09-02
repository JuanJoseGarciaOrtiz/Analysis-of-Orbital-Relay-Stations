function Output = SimulateMissionIteration(InputData,Event,Network,n_stations,configuration)
step = configuration.step;
mu = configuration.mu;
t_prev = 0;
numel_accum = 1;
n_payloads = InputData.n_payloads;
Payload = InputData.Payload;

%Instantaneous state vector of stations
SV_stations = struct('r',cell(1,n_stations),'v',cell(1,n_stations));
for j = 1:n_stations
    SV_stations(j).r = Network(j).r;
    SV_stations(j).v = Network(j).v;
end
    
%Instantaneous state vector of payloads
SV_payloads = struct('r',cell(1,n_payloads),'v',cell(1,n_payloads));
for j = 1:n_payloads
    SV_payloads(j).r = SV_stations(InputData.Payload(j).InitialStation).r;
    SV_payloads(j).v = SV_stations(InputData.Payload(j).InitialStation).v;
    Payload(j).CurrentStation = InputData.Payload(j).InitialStation;
end

%Preallocation
Stations = struct('r',cell(1,n_stations),'v',cell(1,n_stations));
for j = 1:n_stations
    Stations(j).r = zeros(numel(InputData.tspan),3);
    Stations(j).v = zeros(numel(InputData.tspan),3);
end
Payloads = struct('r',cell(1,n_payloads),'v',cell(1,n_payloads));
for j = 1:n_payloads
    Payloads(j).r = zeros(numel(InputData.tspan),3);
    Payloads(j).v = zeros(numel(InputData.tspan),3);
end

for i = 1:numel(Event)
    %Declare event tspan
    tspan = Event(i).tspan;
    
    %Propagate Stations
    StationsHandler = PropagateAllStations(SV_stations,n_stations,tspan,mu);
    
    for j = 1:n_stations
        Stations(j).r(Event(i).FirstElement:Event(i).LastElement,:) = StationsHandler(j).r;
        Stations(j).v(Event(i).FirstElement:Event(i).LastElement,:) = StationsHandler(j).v;
        Stations(j).r(Event(i).LastElement+1,:) = Stations(j).r(Event(i).LastElement,:);
        Stations(j).v(Event(i).LastElement+1,:) = Stations(j).v(Event(i).LastElement,:);
    end
    
    %Propagate Payloads
    PayloadHandler = PropagateAllStations(SV_payloads,n_payloads,tspan,mu);
    for j = 1:n_payloads
        Payloads(j).r(Event(i).FirstElement:Event(i).LastElement,:) = PayloadHandler(j).r;
        Payloads(j).v(Event(i).FirstElement:Event(i).LastElement,:) = PayloadHandler(j).v;
        Payloads(j).r(Event(i).LastElement+1,:) = Payloads(j).r(Event(i).LastElement,:);
        Payloads(j).v(Event(i).LastElement+1,:) = Payloads(j).v(Event(i).LastElement,:);
    end
    
    %Event occurs
    if strcmp(Event(i).type,'Ejection')
        CurrentStation = Payload(Event(i).Payload).CurrentStation;
        Network(Payload(Event(i).Payload).CurrentStation).mass = Network(Payload(Event(i).Payload).CurrentStation).mass - InputData.Payload(Event(i).Payload).mass;
        h = cross(Payloads(Event(i).Payload).r(Event(i).LastElement,:),Payloads(Event(i).Payload).v(Event(i).LastElement,:));
        %ref = ChooseShortArc(Payloads(Event(i).Payload).r(numel_data,:),Event(i).Target_r,h/norm(h));
        ref = h/norm(h);
        [v1,v2] = Lambert(Payloads(Event(i).Payload).r(Event(i).LastElement,:),Event(i).Target_r,Event(i).Dt,ref,mu);
        v_f = PerformEjection(Network(Payload(Event(i).Payload).CurrentStation).mass,InputData.Payload(Event(i).Payload).mass,Payloads(Event(i).Payload).v(Event(i).LastElement,:),v1);
        Payloads(Event(i).Payload).v(Event(i).LastElement+1,:) = v1;
        Stations(Payload(Event(i).Payload).CurrentStation).v(Event(i).LastElement+1,:) = v_f;
        Payload(Event(i).Payload).CurrentStation = NaN;
        for it = 1:n_payloads
            if Payload(it).CurrentStation == CurrentStation
                Payloads(it).v(Event(i).LastElement+1,:) = v_f;
            end
        end
        
    elseif strcmp(Event(i).type,'Attachment')
        v_station = Stations(Event(i).TargetStation).v(Event(i).LastElement,:);
        v_payload = Payloads(Event(i).Payload).v(Event(i).LastElement,:);
        v_f = PerformAttachment(Network(Event(i).TargetStation).mass,InputData.Payload(Event(i).Payload).mass,v_station,v_payload);
        Payloads(Event(i).Payload).r(Event(i).LastElement+1,:) = Stations(Event(i).TargetStation).r(Event(i).LastElement,:);
        Payloads(Event(i).Payload).v(Event(i).LastElement+1,:) = v_f;
        Stations(Event(i).TargetStation).v(Event(i).LastElement+1,:) = v_f;
        Payload(Event(i).Payload).CurrentStation = Event(i).TargetStation;
        Network(Event(i).TargetStation).mass = Network(Event(i).TargetStation).mass + InputData.Payload(Event(i).Payload).mass;
        for it = 1:n_payloads
            if Payload(it).CurrentStation == Event(i).TargetStation
                Payloads(it).v(Event(i).LastElement+1,:) = v_f;
            end
        end
    end
    
    %Define new instantaneous state vectors
    for j = 1:n_stations
        SV_stations(j).r = Stations(j).r(Event(i).LastElement+1,:);
        SV_stations(j).v = Stations(j).v(Event(i).LastElement+1,:);
    end
    for j = 1:n_payloads
        SV_payloads(j).r = Payloads(j).r(Event(i).LastElement+1,:);
        SV_payloads(j).v = Payloads(j).v(Event(i).LastElement+1,:);
    end
end
Output.Payloads = Payloads;
Output.Stations = Stations;
end