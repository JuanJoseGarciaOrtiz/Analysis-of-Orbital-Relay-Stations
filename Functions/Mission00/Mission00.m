function Mission00_results =  Mission00(InputData,Network,n_stations,mu)
%Solves prototype Mission00 according to input data in struct.
%       Mission data is loaded in InputData struct, Station data is laoded 
%       in Network struct. Returns expected trajectories and additional
%       output parameters on Mission00_results


n_operations = InputData.FinalStation - InputData.InitialStation;
Mission00_results.input = InputData;

for i = 1:n_stations
    Mission00_results.output.COE(i).initial.type = Network(i).type;
    Mission00_results.output.COE(i).initial.u = Network(i).u;
    Mission00_results.output.COE(i).initial.omega = Network(i).omega;
    Mission00_results.output.COE(i).initial.theta = Network(i).theta;
    Mission00_results.output.COE(i).initial.inc = Network(i).i;
    Mission00_results.output.COE(i).initial.OMEGA = Network(i).OMEGA;
    Mission00_results.output.COE(i).initial.a = Network(i).a;
    Mission00_results.output.COE(i).initial.e = Network(i).e;
end


Operation = struct('Waiting_tspan',cell(n_operations,1),'TOF_tspan',cell(n_operations,1));
for i = 1:n_operations
    Operation(i).PayloadCurrent = InputData.InitialStation + i - 1;
    Operation(i).Waiting_tspan = linspace(1,floor(InputData.WaitingTime(i)),floor(InputData.WaitingTime(i)));
    Operation(i).TOF_tspan = linspace(1,floor(InputData.TimeOfFlight(i)),floor(InputData.TimeOfFlight(i)));
end


%% SIMULATION
h = zeros(n_stations,3);
time = 0;
for j = 1:n_operations
    %---Propagate waiting time---
    %Stations
    for i = 1:n_stations
        if time == 0
            [r,v] = COE2rv(Network(i).type,Network(i).omega,Network(i).theta,Network(i).i,Network(i).OMEGA,Network(i).a,Network(i).e,Network(i).u,mu);
            h(i,:) = cross(r,v);
        else
            r = Mission00_results.output.Station(i).r(time,:);
            v = Mission00_results.output.Station(i).v(time,:);
        end
        q0 = [r(1);r(2);r(3);v(1);v(2);v(3)];
        tspan = Operation(j).Waiting_tspan;
        [~,q] = OrbitalPropagator(tspan,q0,mu);
        
        Mission00_results.output.Station(i).r((time+1):(time + InputData.WaitingTime(j)),:) = [q(:,1),q(:,2),q(:,3)];
        Mission00_results.output.Station(i).v((time+1):(time + InputData.WaitingTime(j)),:) = [q(:,4),q(:,5),q(:,6)];
    end
    %Payload
    Mission00_results.output.Payload.r((time+1):(time + InputData.WaitingTime(j)),:) = Mission00_results.output.Station(Operation(j).PayloadCurrent).r((time+1):(time + InputData.WaitingTime(j)),:);
    Mission00_results.output.Payload.v((time+1):(time + InputData.WaitingTime(j)),:) = Mission00_results.output.Station(Operation(j).PayloadCurrent).v((time+1):(time + InputData.WaitingTime(j)),:);
    %New time
    time = time + InputData.WaitingTime(j);
    
    %---Compute Lambert trajectory of payload---
    %Propagate target Station
    i_next = Operation(j).PayloadCurrent + 1;
    r = Mission00_results.output.Station(i_next).r(time,:);
    v = Mission00_results.output.Station(i_next).v(time,:);
    q0 = [r(1);r(2);r(3);v(1);v(2);v(3)];
    tspan = Operation(j).TOF_tspan;
    [~,q] = OrbitalPropagator(tspan,q0,mu);
    
    Mission00_results.output.Station(i_next).r((time+1):(time + InputData.TimeOfFlight(j)),:) = [q(:,1),q(:,2),q(:,3)];
    Mission00_results.output.Station(i_next).v((time+1):(time + InputData.TimeOfFlight(j)),:) = [q(:,4),q(:,5),q(:,6)];
    
    %Compute ejection velocity
    r_1 = Mission00_results.output.Payload.r(time,:);
    r_2 = Mission00_results.output.Station(i_next).r(time + InputData.TimeOfFlight(j),:);
    [v_ejection,v_destination] = Lambert(r_1,r_2,InputData.TimeOfFlight(j),h(i_next,:)/norm(h),mu);

    %---Perform Payload Ejection---
    v_station = PerformEjection(Network(i_next).mass,InputData.PayloadMass,Mission00_results.output.Station(i_next-1).v(time,:),v_ejection);
    Mission00_results.output.Payload.v(time + InputData.WaitingTime(j),:) = v_ejection;
    Mission00_results.output.Station(i_next-1).v(time,:) = v_station;
    
    %---Assign new COE---
    for i = 1:n_stations
        [type,u,omega,theta,inc,OMEGA,a,e] = rv2COE(Mission00_results.output.Station(i).r(time,:),Mission00_results.output.Station(i).v(time,:),mu);
        Mission00_results.output.COE(i).Operation(j).type = type;
        Mission00_results.output.COE(i).Operation(j).u = u;
        Mission00_results.output.COE(i).Operation(j).omega = omega;
        Mission00_results.output.COE(i).Operation(j).theta = theta;
        Mission00_results.output.COE(i).Operation(j).inc = inc;
        Mission00_results.output.COE(i).Operation(j).OMEGA = OMEGA;
        Mission00_results.output.COE(i).Operation(j).a = a;
        Mission00_results.output.COE(i).Operation(j).e = e;
    end
    
    %---Propagate time of flight of stations---
    for i = 1:n_stations
        if i ~= i_next
            r = Mission00_results.output.Station(i).r(time,:);
            v = Mission00_results.output.Station(i).v(time,:);
            q0 = [r(1);r(2);r(3);v(1);v(2);v(3)];
            tspan = Operation(j).TOF_tspan;
            [~,q] = OrbitalPropagator(tspan,q0,mu);
            
            Mission00_results.output.Station(i).r((time+1):(time + InputData.TimeOfFlight(j)),:) = [q(:,1),q(:,2),q(:,3)];
            Mission00_results.output.Station(i).v((time+1):(time + InputData.TimeOfFlight(j)),:) = [q(:,4),q(:,5),q(:,6)];
        end
    end
    
    %---Propagate payload---
    r = r_1;
    v = v_ejection;
    q0 = [r(1);r(2);r(3);v(1);v(2);v(3)];
    tspan = Operation(j).TOF_tspan;
    [~,q] = OrbitalPropagator(tspan,q0,mu);
    Mission00_results.output.Payload.r((time+1):(time + InputData.TimeOfFlight(j)),:) = [q(:,1),q(:,2),q(:,3)];
    Mission00_results.output.Payload.v((time+1):(time + InputData.TimeOfFlight(j)),:) = [q(:,4),q(:,5),q(:,6)];
    
    time = time + InputData.TimeOfFlight(j);
    
    %---Attach payload to new station---
    v_attachment = PerformAttachment(Network(i_next).mass,InputData.PayloadMass,Mission00_results.output.Station(i_next).v(time,:),v_destination);
    Mission00_results.output.Station(i_next).v(time,:) = v_attachment;
    
    %---Assign new COE---
    for i = 1:n_stations
        [type,u,omega,theta,inc,OMEGA,a,e] = rv2COE(Mission00_results.output.Station(i).r(time,:),Mission00_results.output.Station(i).v(time,:),mu);
        Mission00_results.output.COE(i).Operation(j).type = type;
        Mission00_results.output.COE(i).Operation(j).u = u;
        Mission00_results.output.COE(i).Operation(j).omega = omega;
        Mission00_results.output.COE(i).Operation(j).theta = theta;
        Mission00_results.output.COE(i).Operation(j).inc = inc;
        Mission00_results.output.COE(i).Operation(j).OMEGA = OMEGA;
        Mission00_results.output.COE(i).Operation(j).a = a;
        Mission00_results.output.COE(i).Operation(j).e = e;
    end
end
Mission00_results.output.Payload.r(time+1,:) = Mission00_results.output.Payload.r(time,:);
Mission00_results.output.Payload.v(time+1,:) = v_attachment;
for i = 1:n_stations
    Mission00_results.output.COE(i).final = Mission00_results.output.COE(i).Operation(n_operations);
end