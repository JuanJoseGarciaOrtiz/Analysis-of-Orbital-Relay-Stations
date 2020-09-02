function theta = E2theta(E,e)
% Provides true anomaly of a point with an eccentric anomaly of E in an
% elliptic orbit of eccentricity e. Solves quadrant ambiguity.

sin_theta = (sqrt(1-e^2)*sin(E))/(1 - e*cos(E));
cos_theta = (cos(E) - e)/(1 - e*cos(E));
theta = acos(cos_theta);
if sin_theta < 0
    theta = 2*pi - theta;
end
end