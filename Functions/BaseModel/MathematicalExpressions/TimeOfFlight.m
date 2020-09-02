function [TOF,TOF_prime,TOF_prime2] = TimeOfFlight(k,tau,S)
%Computes the time of flight between two points of the orbit defined by
%       parameter k. The points of the orbit are implicit in input
%       parameters tau and S which only depend on geometry.
%       
%       For additional information on TAU and S, see function LAMBERT.

[W,W_prime,W_prime2] = WauxFunction(k);
c = (1 - k*tau)/tau;
% Time of flight and derivatives
TOF = S*sqrt(1 - k*tau)*(tau + (1 - k*tau)*W);
TOF_prime = (-TOF/(2*c)) + S*tau*sqrt(c*tau)*(W_prime*c - W);
TOF_prime2 = (-TOF/(4*c^2)) + S*tau*sqrt(c*tau)*(W/c + c*W_prime2 - 3*W_prime);
end