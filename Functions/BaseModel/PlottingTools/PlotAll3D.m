function PlotAll3D(Network,n_stations,mu,n_points)
for i = 1:n_stations
    figure
    PlotOrbit3D(Network(i).type,Network(i).omega,Network(i).i,Network(i).OMEGA,Network(i).a,Network(i).e,mu,n_points)
    title(['Orbit of station ',num2str(i)])
end