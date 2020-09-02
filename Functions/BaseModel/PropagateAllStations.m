function Stations = PropagateAllStations(Network,n_stations,tspan,mu)
Stations = struct('r',cell(n_stations,1),'v',cell(n_stations,1));
for i = 1:n_stations
    q0 = [Network(i).r(:)',Network(i).v(:)'];
    [t,q] = OrbitalPropagator(tspan,q0,mu);
    
    if numel(t) == numel(tspan)
        Stations(i).r = q(:,1:3);
        Stations(i).v = q(:,4:6);
    else
        Stations(i).r(:,1) = interp1(t,q(:,1),tspan);
        Stations(i).r(:,2) = interp1(t,q(:,2),tspan);
        Stations(i).r(:,3) = interp1(t,q(:,3),tspan);
        Stations(i).v(:,1) = interp1(t,q(:,4),tspan);
        Stations(i).v(:,2) = interp1(t,q(:,5),tspan);
        Stations(i).v(:,3) = interp1(t,q(:,6),tspan);
    end
end
end