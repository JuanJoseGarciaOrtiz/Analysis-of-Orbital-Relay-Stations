function a = StationSpacing(a_i,DV,n_stations,mu)
%SEcond station spacing strategy, forcing Hohmann arcs for launches
%prescribing initial orbit (a_i), DeltaV (DV) and the number of desired
%stations (n_stations).

a = zeros(n_stations,1);
a(1) = a_i;
for i = 2:n_stations
    a(i) = (mu/a(i-1) - (DV + sqrt(mu/a(i-1)))^2/2)^-1*mu - a(i-1);
end
end