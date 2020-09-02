function a = NetworkSpacing(a_i,a_f,n_stations,mu)
%First station spacing strategy, equispacing stations with mechanical
%energy. Prescribe initial (a_i) and final (a_f) orbits and the number of 
% stations between them (n_stations) couting the orbits in the ends.
% Returns a vector of semimajor axis of size n_stations.

%% Trivial case
if n_stations <= 2
    a = [a_i;a_f];
    return
end

%% Preallocate
a = zeros(n_stations,1);
xi = zeros(n_stations,1);

%% Equispace mechanical energy
xi(1) = -mu/(2*a_i);
xi(end) = -mu/(2*a_f);
step = (xi(end)-xi(1))/(n_stations-1);
for i = 2:(n_stations-1)
    xi(i) = xi(i-1) + step;
end

%% Reconvert to semimajor axis
a = -mu./(2*xi);

%% Figures
figure
plot(a,xi,'LineWidth',1)
hold on
for i = 1:numel(xi)
    yline(xi(i),'LineStyle','--','color','#A9A9A9');
end
for i = 1:numel(a)
    xline(a(i),'LineStyle','--','color','#A9A9A9');
end
xlabel('Semimajor axis (km)')
ylabel('Specific mechanical energy (km^2/s^2)')
hold off 
end