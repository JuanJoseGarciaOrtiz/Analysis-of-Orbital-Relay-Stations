function E =  theta2E(theta,e)
% Provides eccentric anomaly of a point with a true anomaly of theta in an
% elliptic orbit of eccentricity e. Solves quadrant ambiguity.

sin_E = (sqrt(1-e^2)*sin(theta))/(1 + e*cos(theta));
cos_E = (e + cos(theta))/(1 + e*cos(theta));
E = acos(cos_E);
if sin_E < 0
    E = 2*pi - E;
end
end