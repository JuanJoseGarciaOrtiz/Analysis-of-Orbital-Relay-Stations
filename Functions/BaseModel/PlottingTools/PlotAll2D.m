function PlotAll2D(Network,n_stations,n_points)
for i = 1:n_stations
    figure
    PlotOrbit2D(Network(i),n_points)
    title(['Orbit of station ',num2str(i)])
end